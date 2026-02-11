#import "BleLockManager.h"

#import <HXJBLESDK/HXBluetoothLockHelper.h>
#import <HXJBLESDK/HXAddBluetoothLockHelper.h>
#import <HXJBLESDK/SHAdvertisementModel.h>
#import <HXJBLESDK/SHBLEHotelLockSystemParam.h>
#import <HXJBLESDK/HXBLEDeviceStatus.h>
#import <HXJBLESDK/HXKeyModel.h>

#import "BleScanManager.h"
#import "HxjBleClient.h"
#import "OneShotResult.h"
#import "PluginUtils.h"
#import "WAEventEmitter.h"

@interface BleLockManager ()
@property (nonatomic, strong) HxjBleClient *bleClient;
@property (nonatomic, strong) BleScanManager *scanManager;
@property (nonatomic, strong) HXAddBluetoothLockHelper *addHelper;
@end

@implementation BleLockManager

- (instancetype)initWithBleClient:(HxjBleClient *)bleClient scanManager:(BleScanManager *)scanManager {
    self = [super init];
    if (self) {
        _bleClient = bleClient;
        _scanManager = scanManager;
    }
    return self;
}

#pragma mark - Helpers

- (BOOL)validateArgs:(NSDictionary *)args method:(NSString *)method one:(OneShotResult *)one {
    if (![args isKindOfClass:[NSDictionary class]] || args.count == 0) {
        NSString *msg = [NSString stringWithFormat:@"Invalid args for %@", method ?: @"method"];
        [one error:@"ERROR" message:msg details:nil];
        return NO;
    }
    return YES;
}

/**
 * Prepare method: must be called before any HXBluetoothLockHelper operation.
 * Extracts device auth info from args and calls setDeviceAESKey.
 * Returns YES on success, NO if required auth data is missing.
 */
- (BOOL)prepare:(NSDictionary *)args error:(FlutterError * __autoreleasing *)errorOut {
    return [self configureLockFromArgs:args error:errorOut];
}

- (BOOL)configureLockFromArgs:(NSDictionary *)args error:(FlutterError * __autoreleasing *)errorOut {
    NSString *mac = [PluginUtils lockMacFromArgs:args];
    NSString *aesKey = [PluginUtils stringArg:args key:@"dnaAes128Key"];
    if (aesKey.length == 0) {
        aesKey = [PluginUtils stringArg:args key:@"dnaAes128Key"];
    }
    NSString *authCode = [PluginUtils stringArg:args key:@"authorizedRoot"];
    int keyGroupId = [PluginUtils intFromArgs:args key:@"keyGroupId" defaultValue:900];

    // Android supports either `bleProtocolVer` or `protocolVer`.
    int bleProtocolVer = 0;
    if (args[@"bleProtocolVer"] != nil) {
        bleProtocolVer = [PluginUtils intFromArgs:args key:@"bleProtocolVer" defaultValue:0];
    } else {
        bleProtocolVer = [PluginUtils intFromArgs:args key:@"protocolVer" defaultValue:0];
    }

    if (mac.length == 0) {
        if (errorOut) *errorOut = [FlutterError errorWithCode:@"ERROR" message:@"mac is required" details:nil];
        return NO;
    }

    // If auth fields are not present, try to resolve them from the cache.
    if (aesKey.length == 0 || authCode.length == 0) {
        NSDictionary *cached = [self.bleClient authForMac:mac];
        if ([cached isKindOfClass:[NSDictionary class]]) {
            if (aesKey.length == 0) {
                NSString *c = [PluginUtils stringArg:cached key:@"dnaAes128Key"];
                if (c.length == 0) c = [PluginUtils stringArg:cached key:@"dnaAes128Key"];
                aesKey = c ?: @"";
            }
            if (authCode.length == 0) {
                NSString *c = [PluginUtils stringArg:cached key:@"authorizedRoot"];
                authCode = c ?: @"";
            }
            // Prefer cached protocolVer/keyGroupId when caller didn't supply them.
            if (keyGroupId == 900 && cached[@"keyGroupId"] != nil) {
                keyGroupId = [PluginUtils intFromArgs:cached key:@"keyGroupId" defaultValue:keyGroupId];
            }
            if (bleProtocolVer == 0) {
                if (cached[@"bleProtocolVer"] != nil) {
                    bleProtocolVer = [PluginUtils intFromArgs:cached key:@"bleProtocolVer" defaultValue:bleProtocolVer];
                } else {
                    bleProtocolVer = [PluginUtils intFromArgs:cached key:@"protocolVer" defaultValue:bleProtocolVer];
                }
            }
        }
    }

    if (aesKey.length == 0) {
        if (errorOut) *errorOut = [FlutterError errorWithCode:@"ERROR" message:@"dnaKey is required (call addDevice first on iOS, or provide dnaKey/authCode)" details:nil];
        return NO;
    }

    if (authCode.length == 0) {
        if (errorOut) *errorOut = [FlutterError errorWithCode:@"ERROR" message:@"authorizedRoot is required (call addDevice first on iOS, or provide dnaKey/authCode)" details:nil];
        return NO;
    }

    [HXBluetoothLockHelper setDeviceAESKey:aesKey
                                 authCode:authCode
                               keyGroupId:keyGroupId
                        bleProtocolVersion:bleProtocolVer
                                  lockMac:mac];

    self.bleClient.lastConnectedMac = mac;
    return YES;
}

- (NSString *)ackMessageForCode:(NSInteger)code {
    switch (code) {
        case 0x00: return @"Operation successful";
        case 0x01: return @"Operation successful";
        case 0x02: return @"Password error";
        case 0x03: return @"Remote unlocking not enabled";
        case 0x04: return @"Parameter error";
        case 0x05: return @"Operation prohibited (add administrator first)";
        case 0x06: return @"Operation not supported by lock";
        case 0x07: return @"Repeat adding (already exists)";
        case 0x08: return @"Index/number error";
        case 0x09: return @"Reverse locking not allowed";
        case 0x0A: return @"System is locked";
        case 0x0B: return @"Prohibit deleting administrators";
        case 0x0E: return @"Storage full";
        case 0x0F: return @"Follow-up data packets available";
        case 0x10: return @"Door locked, cannot open/unlock";
        case 0x11: return @"Exit and add key status";
        case 0x23: return @"RF module busy";
        case 0x2B: return @"Electronic lock engaged (unlock not allowed)";
        case 0xE1: return @"Authentication failed";
        case 0xE2: return @"Device busy, try again later";
        case 0xE4: return @"Incorrect encryption type";
        case 0xE5: return @"Session ID incorrect";
        case 0xE6: return @"Device not in pairing mode";
        case 0xE7: return @"Command not allowed";
        case 0xE8: return @"Please add the device first (pairing error)";
        case 0xEA: return @"Already has permission (pair repeat)";
        case 0xEB: return @"Insufficient permissions";
        case 0xEC: return @"Invalid command version / protocol mismatch";
        case 0xFF00: return @"DNA key empty";
        case 0xFF01: return @"Session ID empty";
        case 0xFF02: return @"AES key empty";
        case 0xFF03: return @"Authentication code empty";
        case 0xFF04: return @"Scan/connection timeout";
        case 0xFF05: return @"Bluetooth disconnected";
        case 0xFF07: return @"Decryption failed";
        default:
            return [NSString stringWithFormat:@"Unknown status code: 0x%lX", (long)code];
    }
}

- (NSDictionary *)responseMapWithCode:(NSInteger)code
                              message:(NSString *)message
                              lockMac:(NSString *)lockMac
                                 body:(id)body {
    NSMutableDictionary *response = [NSMutableDictionary dictionary];
    
    response[@"code"] = @(code);
    response[@"message"] = message ?: @"";
    response[@"ackMessage"] = [self ackMessageForCode:code];
    response[@"isSuccessful"] = @(code == KSHStatusCode_Success);
    response[@"isError"] = @(code != KSHStatusCode_Success);
    response[@"lockMac"] = lockMac ?: @"";
    response[@"body"] = body ?: [NSNull null];
    
    return response;
}

#pragma mark - Public API (called from channel handler)

- (void)openLock:(NSDictionary *)args result:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];
    if (![self validateArgs:args method:@"openLock" one:one]) return;

    // Per requirement: initialize addHelper before any steps.
    if (!self.addHelper) {
        self.addHelper = [[HXAddBluetoothLockHelper alloc] init];
    }

    FlutterError *cfgErr = nil;
    if (![self configureLockFromArgs:args error:&cfgErr]) {
        [one error:cfgErr.code message:cfgErr.message details:cfgErr.details];
        return;
    }

    NSString *mac = [PluginUtils lockMacFromArgs:args];

    @try {
        [HXBluetoothLockHelper unlockWithMac:mac
                            synchronizeTime:NO
                           completionBlock:^(KSHStatusCode statusCode,
                                             NSString *reason,
                                             NSString *macOut,
                                             int power,
                                             int unlockingDuration) {
            @try {
                [self.bleClient disConnectBle:nil];
                
                NSDictionary *response = [self responseMapWithCode:statusCode
                                                            message:reason
                                                            lockMac:macOut
                                                               body:@{
                    @"power": @(power),
                    @"unlockingDuration": @(unlockingDuration)
                }];
                
                if (statusCode == KSHStatusCode_Success) {
                    [one success:response];
                } else {
                    [one error:@"FAILED" message:reason ?: @"Operation failed" details:response];
                }
            } @catch (NSException *exception) {
                NSLog(@"[BleLockManager] Exception in openLock callback: %@", exception);
                [one error:@"ERROR" message:exception.reason ?: @"Exception in openLock" details:nil];
            }
        }];
    } @catch (NSException *exception) {
        NSLog(@"[BleLockManager] Exception calling openLock: %@", exception);
        [one error:@"ERROR" message:exception.reason ?: @"Exception calling openLock" details:nil];
    }
}

- (void)closeLock:(NSDictionary *)args result:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];
    if (![self validateArgs:args method:@"closeLock" one:one]) return;

    // Per requirement: initialize addHelper before any steps.
    if (!self.addHelper) {
        self.addHelper = [[HXAddBluetoothLockHelper alloc] init];
    }

    FlutterError *cfgErr = nil;
    if (![self configureLockFromArgs:args error:&cfgErr]) {
        [one error:cfgErr.code message:cfgErr.message details:cfgErr.details];
        return;
    }

    NSString *mac = [PluginUtils lockMacFromArgs:args];

    @try {
        [HXBluetoothLockHelper closeLockWithMac:mac
                               completionBlock:^(KSHStatusCode statusCode,
                                                 NSString *reason,
                                                 NSString *macOut) {
            @try {
                NSDictionary *response = [self responseMapWithCode:statusCode
                                                            message:reason
                                                            lockMac:macOut
                                                               body:nil];
                
                if (statusCode == KSHStatusCode_Success) {
                    [one success:response];
                } else {
                    [one error:@"FAILED" message:reason ?: @"Operation failed" details:response];
                }
            } @catch (NSException *exception) {
                NSLog(@"[BleLockManager] Exception in closeLock callback: %@", exception);
                [one error:@"ERROR" message:exception.reason ?: @"Exception in closeLock" details:nil];
            }
        }];
    } @catch (NSException *exception) {
        NSLog(@"[BleLockManager] Exception calling closeLock: %@", exception);
        [one error:@"ERROR" message:exception.reason ?: @"Exception calling closeLock" details:nil];
    }
}

/**
 * Get system parameters and status information from lock
 * Uses iOS SDK method: getDeviceStatusWithMac:completionBlock:
 * Returns HXBLEDeviceStatus with comprehensive lock status
 */
- (void)getSysParam:(NSDictionary *)args result:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];
    if (![self validateArgs:args method:@"getSysParam" one:one]) return;

    // Per requirement: initialize addHelper before any steps.
    if (!self.addHelper) {
        self.addHelper = [[HXAddBluetoothLockHelper alloc] init];
    }

    FlutterError *cfgErr = nil;
    if (![self configureLockFromArgs:args error:&cfgErr]) {
        [one error:cfgErr.code message:cfgErr.message details:cfgErr.details];
        return;
    }

    NSString *mac = [PluginUtils lockMacFromArgs:args];

    @try {
        [HXBluetoothLockHelper getDeviceStatusWithMac:mac
                                     completionBlock:^(KSHStatusCode statusCode,
                                                       NSString *reason,
                                                       HXBLEDeviceStatus *deviceStatus) {
            @try {
                [self.bleClient disConnectBle:nil]; // Always disconnect

                NSMutableDictionary *params = nil;
                if (deviceStatus != nil) {
                    params = [NSMutableDictionary dictionary];

                    // Map device status fields to Dart SysParamResult keys
                    params[@"deviceStatusStr"] = deviceStatus.deviceStatusStr ?: @"";
                    params[@"lockMac"] = deviceStatus.lockMac ?: mac;

                    // Basic flags / modes
                    params[@"lockOpen"] = @(deviceStatus.openMode);
                    params[@"normallyOpen"] = @(deviceStatus.normallyOpenMode);
                    params[@"isSound"] = @(deviceStatus.volumeEnable);
                    params[@"sysVolume"] = @(deviceStatus.systemVolume);

                    // Tamper / core / cover / lock states
                    params[@"isTamperWarn"] = @(deviceStatus.tamperSwitchStatus);
                    params[@"isLockCoreWarn"] = @(deviceStatus.lockCylinderAlarmEnable);
                    params[@"isLock"] = @(deviceStatus.antiLockEnable);
                    params[@"isLockCap"] = @(deviceStatus.cylinderSwitchStatus);

                    // Initialization / time
                    // sysTime: human readable string from timestamp
                    NSDate *sysDate = [NSDate dateWithTimeIntervalSince1970:(deviceStatus.systemTimeTimestamp)];
                    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
                    [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSString *sysTimeStr = [fmt stringFromDate:sysDate] ?: @"";
                    params[@"sysTime"] = sysTimeStr;
                    params[@"sysTimestamp"] = @(deviceStatus.systemTimeTimestamp);
                    // Accept both capitalized and camelCase timezone keys on Dart side
                    params[@"TimezoneOffset"] = @(deviceStatus.timezoneOffset);
                    params[@"timezoneOffset"] = @(deviceStatus.timezoneOffset);

                    // Battery / unlock counts
                    params[@"electricNum"] = @(deviceStatus.power);
                    params[@"noPowerOpenNo"] = @(deviceStatus.lowPowerUnlockTimes);
                    params[@"noOpenKey"] = @(deviceStatus.enableKeyType);

                    // Flags
                    params[@"normallyOpenFlag"] = @(deviceStatus.normallyopenFlag);
                    params[@"isLockFlag"] = @(deviceStatus.antiLockStatues);
                    params[@"bigBoltFlag"] = @(deviceStatus.squareTongueStatues);
                    params[@"boltFlag"] = @(deviceStatus.obliqueTongueStatues);
                    params[@"isNoOpenFlag"] = @(deviceStatus.normallyopenFlag);
                    params[@"isCover"] = @(deviceStatus.lockCoverSwitchStatus);
                    params[@"isClose"] = @(deviceStatus.antiLockStatues);
                    params[@"coreFlag"] = @(deviceStatus.cylinderSwitchStatus);

                    // Language
                    params[@"systemLanguage"] = @(deviceStatus.systemLanguage);

                    // Fields not directly present on HXBLEDeviceStatus: provide safe defaults
                    params[@"initStatus"] = @(deviceStatus.openMode);
                    params[@"lockSystemFunction"] = @(0);
                    params[@"lockNetSystemFunction2"] = @(0);

                    // Add modelType for parity (optional)
                    params[@"modelType"] = @"HXBLEDeviceStatus";
                }
                
                NSDictionary *response = [self responseMapWithCode:statusCode
                                                            message:reason
                                                            lockMac:mac
                                                               body:params];
                
                if (statusCode == KSHStatusCode_Success) {
                    [one success:response];
                } else {
                    [one error:@"FAILED" message:reason ?: @"Operation failed" details:response];
                }
            } @catch (NSException *exception) {
                NSLog(@"[BleLockManager] Exception in getSysParam callback: %@", exception);
                [one error:@"ERROR" message:exception.reason ?: @"Exception in getSysParam" details:nil];
            }
        }];
    } @catch (NSException *exception) {
        NSLog(@"[BleLockManager] Exception calling getSysParam: %@", exception);
        [one error:@"ERROR" message:exception.reason ?: @"Exception calling getSysParam" details:nil];
    }
}

// Streaming version of getSysParam: emits events via the shared WAEventEmitter.
- (void)getSysParamStream:(NSDictionary *)args eventEmitter:(WAEventEmitter *)eventEmitter {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:^(id _Nullable r){ }];
    NSLog(@"[BleLockManager] getSysParamStream called with args: %@", args);

    if (!eventEmitter || ![eventEmitter hasActiveListener]) {
        NSLog(@"[BleLockManager] ✗ eventEmitter not available for getSysParamStream");
        return;
    }

    FlutterError *cfgErr = nil;
    if (![self configureLockFromArgs:args error:&cfgErr]) {
        [eventEmitter emitEvent:@{ @"type": @"sysParamError", @"message": cfgErr.message ?: @"Configuration error", @"code": @(-1) }];
        return;
    }

    NSString *mac = [PluginUtils lockMacFromArgs:args];
    if (mac.length == 0) {
        [eventEmitter emitEvent:@{ @"type": @"sysParamError", @"message": @"mac is required", @"code": @(-1) }];
        return;
    }

    @try {
        [HXBluetoothLockHelper getDeviceStatusWithMac:mac
                                     completionBlock:^(KSHStatusCode statusCode,
                                                       NSString *reason,
                                                       HXBLEDeviceStatus *deviceStatus) {
            @try {
                [self.bleClient disConnectBle:nil];

                NSMutableDictionary *params = nil;
                if (deviceStatus != nil) {
                    params = [NSMutableDictionary dictionary];
                    params[@"deviceStatusStr"] = deviceStatus.deviceStatusStr ?: @"";
                    params[@"lockMac"] = deviceStatus.lockMac ?: mac;
                    params[@"electricNum"] = @(deviceStatus.power);
                    // keep small set; full map can be assembled by getSysParam
                }

                NSDictionary *response = [self responseMapWithCode:statusCode
                                                            message:reason
                                                            lockMac:mac
                                                               body:params];

                [eventEmitter emitEvent:@{ @"type": @"sysParam", @"response": response }];

                if (statusCode == KSHStatusCode_Success) {
                    [eventEmitter emitEvent:@{ @"type": @"sysParamDone", @"response": response }];
                } else {
                    [eventEmitter emitEvent:@{ @"type": @"sysParamError", @"response": response }];
                }
            } @catch (NSException *exception) {
                NSLog(@"[BleLockManager] Exception in getSysParamStream callback: %@", exception);
                [eventEmitter emitEvent:@{ @"type": @"sysParamError", @"message": exception.reason ?: @"Exception" }];
            }
        }];
    } @catch (NSException *exception) {
        NSLog(@"[BleLockManager] Exception calling getSysParamStream: %@", exception);
        [eventEmitter emitEvent:@{ @"type": @"sysParamError", @"message": exception.reason ?: @"Exception starting stream" }];
    }
}

- (void)synclockkeys:(NSDictionary *)args result:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];
    if (![self validateArgs:args method:@"synclockkeys" one:one]) return;

    // Per requirement: initialize addHelper before any steps.
    if (!self.addHelper) {
        self.addHelper = [[HXAddBluetoothLockHelper alloc] init];
    }

    FlutterError *cfgErr = nil;
    if (![self configureLockFromArgs:args error:&cfgErr]) {
        [one error:cfgErr.code message:cfgErr.message details:cfgErr.details];
        return;
    }

    NSString *mac = [PluginUtils lockMacFromArgs:args];
    if (mac.length == 0) {
        [one error:@"ERROR" message:@"mac is required" details:nil];
        return;
    }

    __weak typeof(self) weakSelf = self;
    __block NSMutableArray<NSDictionary *> *keys = [NSMutableArray array];
    __block int total = 0;

    @try {
        [HXBluetoothLockHelper getKeyListWithLockMac:mac completionBlock:^(KSHStatusCode statusCode, NSString *reason, HXKeyModel *keyObj, int totalOut, BOOL moreData) {
            @try {
                total = totalOut;

                if (statusCode != KSHStatusCode_Success) {
                    [weakSelf.bleClient disConnectBle:nil];
                    NSDictionary *response = [weakSelf responseMapWithCode:statusCode
                                                                   message:reason
                                                                   lockMac:mac
                                                                      body:@{
                        @"keys": keys,
                        @"total": @(total)
                    }];
                    [one error:@"FAILED" message:reason ?: @"Operation failed" details:response];
                    return;
                }

                if (keyObj != nil) {
                    NSDictionary *keyMap = [keyObj dicFromObject];
                    if ([keyMap isKindOfClass:[NSDictionary class]]) {
                        [keys addObject:keyMap];
                    }
                }

                if (!moreData) {
                    [weakSelf.bleClient disConnectBle:nil];

                    NSDictionary *response = [weakSelf responseMapWithCode:statusCode
                                                                   message:reason
                                                                   lockMac:mac
                                                                      body:@{
                        @"keys": keys,
                        @"total": @(total)
                    }];

                    NSMutableDictionary *out = [NSMutableDictionary dictionaryWithDictionary:response];
                    // Back-compat fields (previous stub returned {success, keys}).
                    out[@"success"] = @YES;
                    out[@"keys"] = keys;
                    out[@"total"] = @(total);
                    [one success:out];
                }
            } @catch (NSException *exception) {
                NSLog(@"[BleLockManager] Exception in synclockkeys callback: %@", exception);
                [weakSelf.bleClient disConnectBle:nil];
                [one error:@"ERROR" message:exception.reason ?: @"Exception in synclockkeys" details:nil];
            }
        }];
    } @catch (NSException *exception) {
        NSLog(@"[BleLockManager] Exception calling synclockkeys: %@", exception);
        [self.bleClient disConnectBle:nil];
        [one error:@"ERROR" message:exception.reason ?: @"Exception calling synclockkeys" details:nil];
    }
}

#pragma mark - Streaming Sync Lock Keys

/**
 * Streaming version of synclockkeys that emits incremental updates via eventEmitter.
 * This method is designed for use with EventChannel to send partial results
 * to Flutter as they arrive from the BLE SDK.
 *
 * Pattern matches syncLockRecordsStream: SDK callback fires multiple times,
 * emitting events directly to eventEmitter until moreData=NO.
 * When moreData=NO or on error, the connection is closed.
 *
 * @param args Dictionary containing baseAuth
 * @param eventEmitter Event emitter to send events to Flutter
 */
- (void)syncLockKeyStream:(NSDictionary *)args eventEmitter:(WAEventEmitter *)eventEmitter {
    NSLog(@"[BleLockManager] ========================================");
    NSLog(@"[BleLockManager] syncLockKeyStream CALLED");
    NSLog(@"[BleLockManager] ========================================");
    NSLog(@"[BleLockManager] Args: %@", args);
    
    if (!eventEmitter) {
        NSLog(@"[BleLockManager] ✗ CRITICAL ERROR: eventEmitter is nil!");
        return;
    }
    NSLog(@"[BleLockManager] ✓ eventEmitter is valid");
    
    // Initialize addHelper if needed
    if (!self.addHelper) {
        self.addHelper = [[HXAddBluetoothLockHelper alloc] init];
        NSLog(@"[BleLockManager] ✓ addHelper initialized");
    }

    FlutterError *cfgErr = nil;
    if (![self configureLockFromArgs:args error:&cfgErr]) {
        NSLog(@"[BleLockManager] ✗ Configuration failed: %@", cfgErr.message);
        [eventEmitter emitEvent:@{
            @"type": @"syncLockKeyError",
            @"message": cfgErr.message ?: @"Configuration error",
            @"code": @(-1)
        }];
        return;
    }
    NSLog(@"[BleLockManager] ✓ Lock configured from args");

    NSString *mac = [PluginUtils lockMacFromArgs:args];
    if (mac.length == 0) {
        NSLog(@"[BleLockManager] ✗ ERROR: mac is missing or empty");
        [eventEmitter emitEvent:@{
            @"type": @"syncLockKeyError",
            @"message": @"mac is required",
            @"code": @(-1)
        }];
        return;
    }
    NSLog(@"[BleLockManager] ✓ Lock MAC: %@", mac);

    __weak typeof(self) weakSelf = self;
    __block NSMutableArray<NSDictionary *> *allKeys = [NSMutableArray array];
    __block int totalKeys = 0;
    __block BOOL hasReceivedData = NO;
    __block int callbackCount = 0;

    NSLog(@"[BleLockManager] ➤ Calling HXBluetoothLockHelper getKeyListWithLockMac...");
    
    @try {
        // SDK calls this block multiple times: once per key, then a final call with moreData=NO
        [HXBluetoothLockHelper getKeyListWithLockMac:mac completionBlock:^(KSHStatusCode statusCode, NSString *reason, HXKeyModel *keyObj, int totalOut, BOOL moreData) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                NSLog(@"[BleLockManager] ⚠️ WARNING: strongSelf is nil in callback");
                return;
            }
            
            callbackCount++;
            
            @try {
                NSLog(@"[BleLockManager] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
                NSLog(@"[BleLockManager] Callback #%d", callbackCount);
                NSLog(@"[BleLockManager]   statusCode: %d (%@)", (int)statusCode, statusCode == KSHStatusCode_Success ? @"SUCCESS" : @"ERROR");
                NSLog(@"[BleLockManager]   reason: %@", reason ?: @"(none)");
                NSLog(@"[BleLockManager]   keyObj: %@", keyObj ? @"PRESENT" : @"NIL");
                NSLog(@"[BleLockManager]   totalOut: %d", totalOut);
                NSLog(@"[BleLockManager]   moreData: %@", moreData ? @"YES (more keys coming)" : @"NO (last callback)");
                NSLog(@"[BleLockManager] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
                
                // Update total if provided
                if (totalOut > 0) {
                    totalKeys = totalOut;
                }
                
                // Handle error responses
                if (statusCode != KSHStatusCode_Success) {
                    NSLog(@"[BleLockManager] ✗ Error response detected, disconnecting BLE...");
                    
                    // Disconnect BLE on error
                    if (strongSelf.bleClient) {
                        [strongSelf.bleClient disConnectBle:nil];
                    }
                    
                    NSLog(@"[BleLockManager] ➤ Emitting syncLockKeyError event");
                    [eventEmitter emitEvent:@{
                        @"type": @"syncLockKeyError",
                        @"message": reason ?: @"Operation failed",
                        @"code": @((int)statusCode)
                    }];
                    return;
                }
                
                // Process key object if present
                if (keyObj != nil) {
                    hasReceivedData = YES;
                    NSDictionary *keyMap = [keyObj dicFromObject];
                    if ([keyMap isKindOfClass:[NSDictionary class]]) {
                        [allKeys addObject:keyMap];
                        
                        NSLog(@"[BleLockManager] ➤ Emitting syncLockKeyChunk event");
                        
                        // Emit chunk event with this single key
                        [eventEmitter emitEvent:@{
                            @"type": @"syncLockKeyChunk",
                            @"item": keyMap,
                            @"items": @[ keyMap ],
                            @"keyNum": keyMap[@"keyNum"] ?: @(0),
                            @"totalSoFar": @(allKeys.count),
                            @"total": @(totalKeys),
                            @"isMore": @(moreData)
                        }];
                        
                        NSLog(@"[BleLockManager]   ✓ Chunk emitted - keyNum: %@, totalSoFar: %lu",
                              keyMap[@"keyNum"], (unsigned long)allKeys.count);
                    }
                }
                
                // If no more data, close stream and disconnect
                if (!moreData) {
                    NSLog(@"[BleLockManager] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
                    NSLog(@"[BleLockManager] moreData=NO - Stream complete!");
                    NSLog(@"[BleLockManager]   Total callbacks: %d", callbackCount);
                    NSLog(@"[BleLockManager]   Keys received: %lu", (unsigned long)allKeys.count);
                    NSLog(@"[BleLockManager]   Expected total: %d", totalKeys);
                    NSLog(@"[BleLockManager] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
                    
                    NSLog(@"[BleLockManager] ➤ Disconnecting BLE...");
                    if (strongSelf.bleClient) {
                        [strongSelf.bleClient disConnectBle:nil];
                    }
                    
                    NSLog(@"[BleLockManager] ➤ Emitting syncLockKeyDone event");
                    
                    // Always emit done event
                    [eventEmitter emitEvent:@{
                        @"type": @"syncLockKeyDone",
                        @"items": allKeys,
                        @"total": @(allKeys.count),
                        @"expectedTotal": @(totalKeys)
                    }];
                    
                    NSLog(@"[BleLockManager] ✓ Done event emitted - sync complete!");
                }
            } @catch (NSException *exception) {
                NSLog(@"[BleLockManager] ✗ EXCEPTION in callback: %@", exception);
                
                if (strongSelf.bleClient) {
                    [strongSelf.bleClient disConnectBle:nil];
                }
                
                [eventEmitter emitEvent:@{
                    @"type": @"syncLockKeyError",
                    @"message": exception.reason ?: @"Internal error",
                    @"code": @(-1)
                }];
            }
        }];
        
        NSLog(@"[BleLockManager] ✓ getKeyListWithLockMac called successfully, waiting for callbacks...");
        
    } @catch (NSException *exception) {
        NSLog(@"[BleLockManager] ✗ EXCEPTION calling getKeyListWithLockMac: %@", exception);
        
        [eventEmitter emitEvent:@{
            @"type": @"syncLockKeyError",
            @"message": exception.reason ?: @"Failed to start sync",
            @"code": @(-1)
        }];
    }
}

- (void)syncLockTime:(NSDictionary *)args result:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];
    if (![self validateArgs:args method:@"syncLockTime" one:one]) return;

    // Initialize addHelper if needed
    if (!self.addHelper) {
        self.addHelper = [[HXAddBluetoothLockHelper alloc] init];
    }

    FlutterError *cfgErr = nil;
    if (![self configureLockFromArgs:args error:&cfgErr]) {
        [one error:cfgErr.code message:cfgErr.message details:cfgErr.details];
        return;
    }

    NSString *mac = [PluginUtils lockMacFromArgs:args];
    if (mac.length == 0) {
        [one error:@"ERROR" message:@"mac is required" details:nil];
        return;
    }

    NSLog(@"[BleLockManager] Synchronizing lock time for mac: %@", mac);

    __weak typeof(self) weakSelf = self;
    @try {
        [HXBluetoothLockHelper synchronizeTimeWithMac:mac completionBlock:^(KSHStatusCode statusCode, NSString *reason) {
            @try {
                [weakSelf.bleClient disConnectBle:nil];

                if (statusCode == KSHStatusCode_Success) {
                    NSLog(@"[BleLockManager] Lock time synchronized successfully");
                    [one success:@YES];
                } else {
                    NSLog(@"[BleLockManager] Failed to sync lock time - code: %d, reason: %@", (int)statusCode, reason);
                    NSDictionary *response = [weakSelf responseMapWithCode:statusCode
                                                                   message:reason
                                                                   lockMac:mac
                                                                      body:nil];
                    [one error:@"FAILED" message:reason ?: @"Failed to sync lock time" details:response];
                }
            } @catch (NSException *exception) {
                NSLog(@"[BleLockManager] Exception in syncLockTime callback: %@", exception);
                [weakSelf.bleClient disConnectBle:nil];
                [one error:@"ERROR" message:exception.reason ?: @"Exception in syncLockTime" details:nil];
            }
        }];
    } @catch (NSException *exception) {
        NSLog(@"[BleLockManager] Exception calling syncLockTime: %@", exception);
        [self.bleClient disConnectBle:nil];
        [one error:@"ERROR" message:exception.reason ?: @"Exception calling syncLockTime" details:nil];
    }
}

- (void)setKeyExpirationAlarmTime:(NSDictionary *)args result:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];
    if (![self validateArgs:args method:@"setKeyExpirationAlarmTime" one:one]) return;

    // Per requirement: initialize addHelper before any steps.
    if (!self.addHelper) {
        self.addHelper = [[HXAddBluetoothLockHelper alloc] init];
    }

    FlutterError *cfgErr = nil;
    if (![self configureLockFromArgs:args error:&cfgErr]) {
        [one error:cfgErr.code message:cfgErr.message details:cfgErr.details];
        return;
    }

    (void)[PluginUtils intFromArgs:args key:@"time" defaultValue:0];
    (void)[PluginUtils lockMacFromArgs:args];

    SHBLEHotelLockSystemParam *param = [[SHBLEHotelLockSystemParam alloc] init];
    param.lockMac = [PluginUtils lockMacFromArgs:args];
    (void)param;

    [one error:@"UNIMPLEMENTED"
        message:@"setKeyExpirationAlarmTime is not implemented yet on iOS."
        details:nil];
}

- (void)deleteLock:(NSDictionary *)args result:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];
    if (![self validateArgs:args method:@"deleteLock" one:one]) return;

    // Per requirement: initialize addHelper before any steps.
    if (!self.addHelper) {
        self.addHelper = [[HXAddBluetoothLockHelper alloc] init];
    }

    FlutterError *cfgErr = nil;
    if (![self configureLockFromArgs:args error:&cfgErr]) {
        [one error:cfgErr.code message:cfgErr.message details:cfgErr.details];
        return;
    }

    NSString *mac = [PluginUtils lockMacFromArgs:args];

    @try {
        [HXBluetoothLockHelper deleteDeviceWithMac:mac completionBlock:^(KSHStatusCode statusCode, NSString *reason) {
            @try {
                [self.bleClient disConnectBle:nil];

                if (statusCode == KSHStatusCode_Success) {
                    [self.bleClient clearAuthForMac:mac];
                }
                
                NSDictionary *response = [self responseMapWithCode:statusCode
                                                            message:reason
                                                            lockMac:mac
                                                               body:nil];
                
                if (statusCode == KSHStatusCode_Success) {
                    [one success:response];
                } else {
                    [one error:@"FAILED" message:reason ?: @"Operation failed" details:response];
                }
            } @catch (NSException *exception) {
                NSLog(@"[BleLockManager] Exception in deleteLock callback: %@", exception);
                [one error:@"ERROR" message:exception.reason ?: @"Exception in deleteLock" details:nil];
            }
        }];
    } @catch (NSException *exception) {
        NSLog(@"[BleLockManager] Exception calling deleteLock: %@", exception);
        [one error:@"ERROR" message:exception.reason ?: @"Exception calling deleteLock" details:nil];
    }
}

- (void)getDna:(NSDictionary *)args result:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];
    if (![self validateArgs:args method:@"getDna" one:one]) return;

    // Per requirement: initialize addHelper before any steps.
    if (!self.addHelper) {
        self.addHelper = [[HXAddBluetoothLockHelper alloc] init];
    }

    FlutterError *cfgErr = nil;
    if (![self configureLockFromArgs:args error:&cfgErr]) {
        [one error:cfgErr.code message:cfgErr.message details:cfgErr.details];
        return;
    }

    NSString *mac = [PluginUtils lockMacFromArgs:args];

    @try {
        [HXBluetoothLockHelper getDNAInfoWithLockMac:mac completionBlock:^(KSHStatusCode statusCode, NSString *reason, HXBLEDeviceBase *deviceBase) {
            @try {
                id body = nil;
                if (statusCode == KSHStatusCode_Success && deviceBase != nil) {
                    body = @{ @"mac": deviceBase.rfModuleMac ?: mac };
                }
                
                NSDictionary *response = [self responseMapWithCode:statusCode
                                                            message:reason
                                                            lockMac:mac
                                                               body:body];
                
                if (statusCode == KSHStatusCode_Success) {
                    [one success:response];
                } else {
                    [one error:@"FAILED" message:reason ?: @"Operation failed" details:response];
                }
            } @catch (NSException *exception) {
                NSLog(@"[BleLockManager] Exception in getDna callback: %@", exception);
                [one error:@"ERROR" message:exception.reason ?: @"Exception in getDna" details:nil];
            }
        }];
    } @catch (NSException *exception) {
        NSLog(@"[BleLockManager] Exception calling getDna: %@", exception);
        [one error:@"ERROR" message:exception.reason ?: @"Exception calling getDna" details:nil];
    }
}

// Helpers (keep in the same .m file, outside the method)
static inline id HXSafeKVC(id obj, NSString *key) {
    if (!obj || !key) return nil;
    @try {
        id v = [obj valueForKey:key];
        return (v == (id)[NSNull null]) ? nil : v;
    } @catch (__unused NSException *e) {
        return nil;
    }
}

static inline void HXPut(NSMutableDictionary *m, NSString *key, id value) {
    if (!m || !key) return;
    if (value && value != (id)[NSNull null]) {
        m[key] = value;
    }
}

- (void)addDevice:(NSDictionary *)args result:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];
    NSLog(@"[BleLockManager] addDevice called with args: %@", args);

    if (![self validateArgs:args method:@"addDevice" one:one]) return;

    NSString *mac = [PluginUtils lockMacFromArgs:args];
    if (mac.length == 0) {
        [one error:@"ERROR" message:@"mac is required" details:nil];
        return;
    }

    SHAdvertisementModel *advertisementModel = nil;

    // Build advertisement model either from args or from scan cache
    if (args[@"name"] || args[@"RSSI"] || args[@"chipType"] || args[@"lockType"]) {
        advertisementModel = [[SHAdvertisementModel alloc] init];
        advertisementModel.mac = mac;

        if (args[@"name"]) advertisementModel.name = args[@"name"];

        // RSSI must be NSNumber*
        if (args[@"RSSI"] && args[@"RSSI"] != (id)[NSNull null]) {
            advertisementModel.RSSI = [args[@"RSSI"] isKindOfClass:[NSNumber class]]
                ? (NSNumber *)args[@"RSSI"]
                : @([args[@"RSSI"] intValue]);
        }

        if (args[@"chipType"]) advertisementModel.chipType = [args[@"chipType"] intValue];
        if (args[@"lockType"]) advertisementModel.lockType = [args[@"lockType"] intValue];
        if (args[@"isPairedFlag"]) advertisementModel.isPairedFlag = [args[@"isPairedFlag"] boolValue];
        if (args[@"discoverableFlag"]) advertisementModel.discoverableFlag = [args[@"discoverableFlag"] boolValue];
        if (args[@"modernProtocol"]) advertisementModel.modernProtocol = [args[@"modernProtocol"] boolValue];
        if (args[@"serviceUUIDs"]) advertisementModel.serviceUUIDs = args[@"serviceUUIDs"];
    } else {
        advertisementModel = [self.scanManager advertisementForMac:mac];
    }

    if (!advertisementModel) {
        [one error:@"FAILED" message:@"Device not found. Provide advertisementData or scan first." details:nil];
        return;
    }

    @try {
        // Use strong helper (same pattern as demo)
        if (!self.addHelper) {
            self.addHelper = [[HXAddBluetoothLockHelper alloc] init];
        }

        [self.addHelper startAddDeviceWithAdvertisementModel:advertisementModel
                                            completionBlock:^(KSHStatusCode statusCode,
                                                             NSString *reason,
                                                             HXBLEDevice *device,
                                                             HXBLEDeviceStatus *deviceStatus) {
            @try {
                NSMutableDictionary *finalMap = [NSMutableDictionary dictionary];

                if (statusCode == KSHStatusCode_Success && device != nil && deviceStatus != nil) {

                    // -------------------------
                    // DNA INFO (match lib/src/models/dna_info_model.dart keys and types)
                    // -------------------------
                      NSMutableDictionary *dnaMap = [NSMutableDictionary dictionary];
                      NSLog(@"[BleLockManager] Building DNA info (direct device properties)");

                      // mac (String)
                      HXPut(dnaMap, @"mac", device.lockMac ?: mac);

                      // initTag (String) - represent initFlag as string if present
                      if (device.initFlag != 0) {
                          HXPut(dnaMap, @"initTag", [@(device.initFlag) stringValue]);
                      }

                      // deviceType (int)
                      HXPut(dnaMap, @"deviceType", @(device.lockType));

                      // hardware / software (strings expected by Dart)
                      HXPut(dnaMap, @"hardWareVer", device.hardwareVersion ?: @"");
                      HXPut(dnaMap, @"softWareVer", device.firmwareVersion ?: @"");

                      // protocolVer (int)
                      HXPut(dnaMap, @"protocolVer", @(device.bleProtocolVersion));

                      // dnaAes128Key (String)
                      HXPut(dnaMap, @"dnaAes128Key", device.aesKey ?: @"");

                      // authorized fields (Strings)
                      HXPut(dnaMap, @"authorizedRoot", device.adminAuthCode ?: @"");
                      HXPut(dnaMap, @"authorizedUser", device.generalAuthCode ?: @"");
                      HXPut(dnaMap, @"authorizedTempUser", device.tempAuthCode ?: @"");

                      // rFModuleType (int)
                      HXPut(dnaMap, @"rFModuleType", @((int)device.rfModuleType));

                      // lockFunctionType (int)
                      HXPut(dnaMap, @"lockFunctionType", @((int)device.lockFunctionType));

                      // maximumVolume / maximumUserNum (ints)
                      HXPut(dnaMap, @"maximumVolume", @(device.maxVolume));
                      HXPut(dnaMap, @"maximumUserNum", @(device.maxUser));

                      // menuFeature (int)
                      HXPut(dnaMap, @"menuFeature", @((int)device.menuFeature));

                      // rFModuleMac (String)
                      HXPut(dnaMap, @"rFModuleMac", device.rfModuleMac ?: @"");

                      // MoudleFunction (int)
                      HXPut(dnaMap, @"MoudleFunction", @((int)device.rfModuleFunction));

                      // BleActiveTimes (int)
                      HXPut(dnaMap, @"BleActiveTimes", @(device.bleActiveTimes));

                      // ModuleSoftwareVer / ModuleHardwareVer: SDK exposes strings; include only when numeric
                      if (device.rfMoudleSoftwareVer && device.rfMoudleSoftwareVer.length > 0) {
                          NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
                          NSString *digits = [[device.rfMoudleSoftwareVer componentsSeparatedByCharactersInSet:nonDigits] componentsJoinedByString:@""];
                          if (digits.length > 0) {
                              HXPut(dnaMap, @"ModuleSoftwareVer", @([digits integerValue]));
                          }
                      }
                      if (device.rfMoudleHarewareVer && device.rfMoudleHarewareVer.length > 0) {
                          NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
                          NSString *digits = [[device.rfMoudleHarewareVer componentsSeparatedByCharactersInSet:nonDigits] componentsJoinedByString:@""];
                          if (digits.length > 0) {
                              HXPut(dnaMap, @"ModuleHardwareVer", @([digits integerValue]));
                          }
                      }

                      // passwordNumRange / OfflinePasswordVer / supportSystemLanguage (ints)
                      HXPut(dnaMap, @"passwordNumRange", @(device.passwordNumRange));
                      HXPut(dnaMap, @"OfflinePasswordVer", @(device.offlinePasswordVer));
                      HXPut(dnaMap, @"supportSystemLanguage", @((int)device.supportedSystemLanguage));

                      // lockSystemFunction / lockNetSystemFunction (longs)
                      HXPut(dnaMap, @"lockSystemFunction", @((long)device.lockSystemFunction));
                      HXPut(dnaMap, @"lockNetSystemFunction", @((long)device.lockNetSystemFunction));

                      // deviceDnaInfoStr (String)
                      HXPut(dnaMap, @"deviceDnaInfoStr", device.deviceDnaInfoStr ?: @"");

                      // Note: omit keys that are not present in the SDK rather than sending zero/placeholders

                    // Cache auth material so subsequent iOS calls can be mac-only.
                    [self.bleClient setAuth:dnaMap forMac:(device.lockMac ?: mac)];

                    // -------------------------
                    // SYS PARAM (device status) - keep as-is unless you have Android sysParam keys list
                    // -------------------------
                    NSMutableDictionary *sysParamMap = [NSMutableDictionary dictionary];
                    // Map device status to Dart SysParamResult keys (same mapping as getSysParam)
                    sysParamMap[@"deviceStatusStr"] = deviceStatus.deviceStatusStr ?: @"";
                    sysParamMap[@"lockMac"] = deviceStatus.lockMac ?: mac;
                    sysParamMap[@"lockOpen"] = @(deviceStatus.openMode);
                    sysParamMap[@"normallyOpen"] = @(deviceStatus.normallyOpenMode);
                    sysParamMap[@"isSound"] = @(deviceStatus.volumeEnable);
                    sysParamMap[@"sysVolume"] = @(deviceStatus.systemVolume);
                    sysParamMap[@"isTamperWarn"] = @(deviceStatus.tamperSwitchStatus);
                    sysParamMap[@"isLockCoreWarn"] = @(deviceStatus.lockCylinderAlarmEnable);
                    sysParamMap[@"isLock"] = @(deviceStatus.antiLockEnable);
                    sysParamMap[@"isLockCap"] = @(deviceStatus.cylinderSwitchStatus);
                    NSDate *sysDate2 = [NSDate dateWithTimeIntervalSince1970:(deviceStatus.systemTimeTimestamp)];
                    NSDateFormatter *fmt2 = [[NSDateFormatter alloc] init];
                    [fmt2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    sysParamMap[@"sysTime"] = [fmt2 stringFromDate:sysDate2] ?: @"";
                    sysParamMap[@"sysTimestamp"] = @(deviceStatus.systemTimeTimestamp);
                    sysParamMap[@"TimezoneOffset"] = @(deviceStatus.timezoneOffset);
                    sysParamMap[@"timezoneOffset"] = @(deviceStatus.timezoneOffset);
                    sysParamMap[@"electricNum"] = @(deviceStatus.power);
                    sysParamMap[@"noPowerOpenNo"] = @(deviceStatus.lowPowerUnlockTimes);
                    sysParamMap[@"noOpenKey"] = @(deviceStatus.enableKeyType);
                    sysParamMap[@"normallyOpenFlag"] = @(deviceStatus.normallyopenFlag);
                    sysParamMap[@"isLockFlag"] = @(deviceStatus.antiLockStatues);
                    sysParamMap[@"bigBoltFlag"] = @(deviceStatus.squareTongueStatues);
                    sysParamMap[@"boltFlag"] = @(deviceStatus.obliqueTongueStatues);
                    sysParamMap[@"isNoOpenFlag"] = @(deviceStatus.normallyopenFlag);
                    sysParamMap[@"isCover"] = @(deviceStatus.lockCoverSwitchStatus);
                    sysParamMap[@"isClose"] = @(deviceStatus.antiLockStatues);
                    sysParamMap[@"coreFlag"] = @(deviceStatus.cylinderSwitchStatus);
                    sysParamMap[@"systemLanguage"] = @(deviceStatus.systemLanguage);
                    sysParamMap[@"initStatus"] = @(deviceStatus.openMode);
                    sysParamMap[@"lockSystemFunction"] = @(0);
                    sysParamMap[@"lockNetSystemFunction2"] = @(0);

                    // -------------------------
                    // Response
                    // -------------------------
                    finalMap[@"ok"] = @YES;
                    finalMap[@"stage"] = @"addDevice";
                    finalMap[@"dnaInfo"] = dnaMap;
                    finalMap[@"sysParam"] = sysParamMap;

                    NSDictionary *addDeviceResp = [self responseMapWithCode:statusCode
                                                                     message:reason
                                                                     lockMac:mac
                                                                        body:dnaMap];
                    finalMap[@"responses"] = @{@"addDevice": addDeviceResp};

                    [one success:finalMap];
                } else {
                    finalMap[@"ok"] = @NO;
                    finalMap[@"stage"] = @"addDevice";
                    finalMap[@"dnaInfo"] = [NSNull null];
                    finalMap[@"sysParam"] = [NSNull null];

                    NSDictionary *addDeviceResp = [self responseMapWithCode:statusCode
                                                                     message:reason
                                                                     lockMac:mac
                                                                        body:nil];
                    finalMap[@"responses"] = @{@"addDevice": addDeviceResp};

                    [one error:@"FAILED" message:reason ?: @"addDevice failed" details:finalMap];
                }
            } @catch (NSException *exception) {
                NSLog(@"[BleLockManager] Exception in addDevice callback: %@", exception);
                [one error:@"ERROR" message:exception.reason ?: @"Exception in addDevice" details:nil];
            }
        }];
    } @catch (NSException *exception) {
        NSLog(@"[BleLockManager] Exception calling addDevice: %@", exception);
        [one error:@"ERROR" message:exception.reason ?: @"Exception calling addDevice" details:nil];
    }
}


@end
