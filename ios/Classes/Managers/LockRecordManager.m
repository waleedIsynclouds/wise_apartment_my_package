#import "LockRecordManager.h"

#import "WAEventEmitter.h"

#import <objc/runtime.h>

#import <HXJBLESDK/HXBluetoothLockHelper.h>
#import <HXJBLESDK/HXBLEDeviceBase.h>

#import "HxjBleClient.h"
#import "OneShotResult.h"
#import "PluginUtils.h"
#import "WiseStatusCode.h"

@interface LockRecordManager ()
@property (nonatomic, strong) HxjBleClient *bleClient;
@property (nonatomic, weak) WAEventEmitter *eventEmitter;
@end

@implementation LockRecordManager

- (instancetype)initWithBleClient:(HxjBleClient *)bleClient eventEmitter:(WAEventEmitter *)eventEmitter {
    self = [super init];
    if (self) {
        _bleClient = bleClient;
        _eventEmitter = eventEmitter;
    }
    return self;
}

- (void)syncLockRecordsStream:(NSDictionary *)args {
    if (![args isKindOfClass:[NSDictionary class]]) args = @{};

    NSString *mac = [PluginUtils lockMacFromArgs:args];
    if (mac.length == 0) {
        [self.eventEmitter emitEvent:@{
            @"type": @"syncLockRecordsError",
            @"message": @"mac is required",
            @"code": @(-1),
        }];
        return;
    }

    // Configure lock auth if present, otherwise attempt to use cached auth.
    NSDictionary *resolved = args;
    NSString *aesKey = [PluginUtils stringArg:args key:@"dnaKey"];
    if (aesKey.length == 0) {
        aesKey = [PluginUtils stringArg:args key:@"aesKey"];
    }
    NSString *authCode = [PluginUtils stringArg:args key:@"authCode"];
    if (aesKey.length == 0 || authCode.length == 0) {
        NSDictionary *cached = [self.bleClient authForMac:mac];
        if ([cached isKindOfClass:[NSDictionary class]]) {
            resolved = cached;
            if (aesKey.length == 0) {
                NSString *c = [PluginUtils stringArg:cached key:@"dnaKey"];
                if (c.length == 0) c = [PluginUtils stringArg:cached key:@"aesKey"];
                aesKey = c ?: @"";
            }
            if (authCode.length == 0) {
                NSString *c = [PluginUtils stringArg:cached key:@"authCode"];
                authCode = c ?: @"";
            }
        }
    }
    int keyGroupId = [PluginUtils intFromArgs:resolved key:@"keyGroupId" defaultValue:900];
    int bleProtocolVer = 0;
    if (resolved[@"bleProtocolVer"] != nil) {
        bleProtocolVer = [PluginUtils intFromArgs:resolved key:@"bleProtocolVer" defaultValue:0];
    } else {
        bleProtocolVer = [PluginUtils intFromArgs:resolved key:@"protocolVer" defaultValue:0];
    }
    if (aesKey.length > 0 && authCode.length > 0) {
        [HXBluetoothLockHelper setDeviceAESKey:aesKey authCode:authCode keyGroupId:keyGroupId bleProtocolVersion:bleProtocolVer lockMac:mac];
        self.bleClient.lastConnectedMac = mac;
    }

    // Infer logVersion per Android logic.
    int logVersion = 1;
    if (args[@"logVersion"] != nil) {
        logVersion = [PluginUtils intFromArgs:args key:@"logVersion" defaultValue:1];
    } else if (args[@"menuFeature"] != nil) {
        int menuFeature = [PluginUtils intFromArgs:args key:@"menuFeature" defaultValue:0];
        if ((menuFeature & 0x4) != 0) logVersion = 2;
    }
    if (logVersion != 1 && logVersion != 2) logVersion = 1;

    __weak typeof(self) weakSelf = self;
    __block int total = 0;
    __block int currentIndex = 0;
    __block NSMutableArray<NSDictionary *> *all = [NSMutableArray array];

    [HXBluetoothLockHelper getOperationRecordCountWithLockMac:mac completionBlock:^(KSHStatusCode statusCode, NSString *reason, int totalOut) {
        (void)reason;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        if (statusCode != KSHStatusCode_Success) {
            [strongSelf.eventEmitter emitEvent:@{
                @"type": @"syncLockRecordsError",
                @"message": [NSString stringWithFormat:@"Get Record Num Failed: %ld", (long)statusCode],
                @"code": @((NSInteger)statusCode),
            }];
            return;
        }

        total = totalOut;
        if (total <= 0) {
            [strongSelf.eventEmitter emitEvent:@{
                @"type": @"syncLockRecordsDone",
                @"items": @[],
                @"total": @(0),
            }];
            return;
        }

        void (^fetchNext)(void) = ^{
            [HXBluetoothLockHelper getOperationRecordListWithLockMac:mac startIndex:currentIndex count:10 logVersion:logVersion completionBlock:^(KSHStatusCode s, NSString *r, NSArray *logArray, BOOL moreData, int lv) {
                (void)r;
                __strong typeof(weakSelf) strongSelf2 = weakSelf;
                if (!strongSelf2) return;

                if (s != KSHStatusCode_Success) {
                    [strongSelf2.eventEmitter emitEvent:@{
                        @"type": @"syncLockRecordsError",
                        @"message": [NSString stringWithFormat:@"Sync Failed: %ld", (long)s],
                        @"code": @((NSInteger)s),
                    }];
                    return;
                }

                NSMutableArray<NSDictionary *> *chunk = [NSMutableArray arrayWithCapacity:logArray.count];
                for (id rec in logArray) {
                    NSMutableDictionary *m = [[strongSelf2 mapRecord:rec] mutableCopy];
                    m[@"logVersion"] = @(lv);
                    [all addObject:m];
                    [chunk addObject:m];
                }

                currentIndex += (int)logArray.count;
                BOOL isMore = (moreData && currentIndex < total);

                [strongSelf2.eventEmitter emitEvent:@{
                    @"type": @"syncLockRecordsChunk",
                    @"items": chunk,
                    @"totalSoFar": @(all.count),
                    @"isMore": @(isMore),
                }];

                if (!isMore) {
                    [strongSelf2.eventEmitter emitEvent:@{
                        @"type": @"syncLockRecordsDone",
                        @"items": all,
                        @"total": @(all.count),
                    }];
                } else {
                    fetchNext();
                }
            }];
        };

        fetchNext();
    }];
}

- (NSDictionary *)mapRecord:(id)record {
    NSMutableDictionary *out = [NSMutableDictionary dictionary];
    if (!record) return out;

    out[@"modelType"] = NSStringFromClass([record class]) ?: @"";

    Class clazz = [record class];
    while (clazz && clazz != [NSObject class]) {
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList(clazz, &count);
        for (unsigned int i = 0; i < count; i++) {
            const char *name = property_getName(properties[i]);
            if (!name) continue;
            NSString *key = [NSString stringWithUTF8String:name];
            if (key.length == 0) continue;
            id value = nil;
            @try {
                value = [record valueForKey:key];
            } @catch (__unused NSException *e) {
                value = nil;
            }
            if (!value || value == [NSNull null]) continue;

            if ([value isKindOfClass:[NSString class]] ||
                [value isKindOfClass:[NSNumber class]]) {
                out[key] = value;
            } else {
                out[key] = [value description] ?: @"";
            }
        }
        free(properties);
        clazz = class_getSuperclass(clazz);
    }

    return out;
}

- (void)syncLockRecords:(NSDictionary *)args result:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];

    NSString *mac = [PluginUtils lockMacFromArgs:args];
    if (mac.length == 0) {
        [one error:@"ERROR" message:@"mac is required" details:nil];
        return;
    }

    // Configure lock auth if present, otherwise attempt to use cached auth.
    NSDictionary *resolved = args;
    NSString *aesKey = [PluginUtils stringArg:args key:@"dnaKey"];
    if (aesKey.length == 0) {
        aesKey = [PluginUtils stringArg:args key:@"aesKey"];
    }
    NSString *authCode = [PluginUtils stringArg:args key:@"authCode"];
    if (aesKey.length == 0 || authCode.length == 0) {
        NSDictionary *cached = [self.bleClient authForMac:mac];
        if ([cached isKindOfClass:[NSDictionary class]]) {
            resolved = cached;
            if (aesKey.length == 0) {
                NSString *c = [PluginUtils stringArg:cached key:@"dnaKey"];
                if (c.length == 0) c = [PluginUtils stringArg:cached key:@"aesKey"];
                aesKey = c ?: @"";
            }
            if (authCode.length == 0) {
                NSString *c = [PluginUtils stringArg:cached key:@"authCode"];
                authCode = c ?: @"";
            }
        }
    }
    int keyGroupId = [PluginUtils intFromArgs:resolved key:@"keyGroupId" defaultValue:900];
    int bleProtocolVer = 0;
    if (resolved[@"bleProtocolVer"] != nil) {
        bleProtocolVer = [PluginUtils intFromArgs:resolved key:@"bleProtocolVer" defaultValue:0];
    } else {
        bleProtocolVer = [PluginUtils intFromArgs:resolved key:@"protocolVer" defaultValue:0];
    }
    if (aesKey.length > 0 && authCode.length > 0) {
        [HXBluetoothLockHelper setDeviceAESKey:aesKey authCode:authCode keyGroupId:keyGroupId bleProtocolVersion:bleProtocolVer lockMac:mac];
        self.bleClient.lastConnectedMac = mac;
    }

    // Infer logVersion per Android logic.
    int logVersion = 1;
    if (args[@"logVersion"] != nil) {
        logVersion = [PluginUtils intFromArgs:args key:@"logVersion" defaultValue:1];
    } else if (args[@"menuFeature"] != nil) {
        int menuFeature = [PluginUtils intFromArgs:args key:@"menuFeature" defaultValue:0];
        if ((menuFeature & 0x4) != 0) logVersion = 2;
    }
    if (logVersion != 1 && logVersion != 2) logVersion = 1;

    __block int total = 0;
    __block int currentIndex = 0;
    __block NSMutableArray<NSDictionary *> *all = [NSMutableArray array];

    [HXBluetoothLockHelper getOperationRecordCountWithLockMac:mac completionBlock:^(KSHStatusCode statusCode, NSString *reason, int totalOut) {
        (void)reason;
        if (statusCode != KSHStatusCode_Success) {
            NSDictionary *details = @{
                @"code": @((int)statusCode),
                @"ackMessage": [WiseStatusCode description:(int)statusCode],
            };
            NSString *msg = [NSString stringWithFormat:@"Get Record Num Failed: %ld", (long)statusCode];
            [one error:@"FAILED" message:msg details:details];
            return;
        }

        total = totalOut;
        if (total <= 0) {
            [one success:@[]];
            return;
        }

        void (^fetchNext)(void) = ^{
            [HXBluetoothLockHelper getOperationRecordListWithLockMac:mac startIndex:currentIndex count:10 logVersion:logVersion completionBlock:^(KSHStatusCode s, NSString *r, NSArray *logArray, BOOL moreData, int lv) {
                (void)r;
                if (s != KSHStatusCode_Success) {
                    NSDictionary *details = @{
                        @"code": @((int)s),
                        @"ackMessage": [WiseStatusCode description:(int)s],
                    };
                    NSString *msg = [NSString stringWithFormat:@"Sync Failed: %ld", (long)s];
                    [one error:@"FAILED" message:msg details:details];
                    return;
                }

                for (id rec in logArray) {
                    NSMutableDictionary *m = [[self mapRecord:rec] mutableCopy];
                    m[@"logVersion"] = @(lv);
                    [all addObject:m];
                }

                currentIndex += (int)logArray.count;

                if (!moreData || currentIndex >= total) {
                    [one success:all];
                } else {
                    fetchNext();
                }
            }];
        };

        fetchNext();
    }];
}

@end
