#import "BleLockManager.h"

#import <HXJBLESDK/HXBluetoothLockHelper.h>
#import <HXJBLESDK/HXAddBluetoothLockHelper.h>
#import <HXJBLESDK/SHAdvertisementModel.h>
#import <HXJBLESDK/SHBLEHotelLockSystemParam.h>

#import "BleScanManager.h"
#import "HxjBleClient.h"
#import "OneShotResult.h"
#import "PluginUtils.h"

@interface BleLockManager ()
@property (nonatomic, strong) HxjBleClient *bleClient;
@property (nonatomic, strong) BleScanManager *scanManager;
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

- (BOOL)configureLockFromArgs:(NSDictionary *)args error:(FlutterError * __autoreleasing *)errorOut {
    NSString *mac = [PluginUtils lockMacFromArgs:args];
    NSString *aesKey = [PluginUtils stringArg:args key:@"dnaKey"];
    NSString *authCode = [PluginUtils stringArg:args key:@"authCode"];
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

    if (aesKey.length == 0) {
        // Mirror Android local error constant meaning (DNA key empty)
        if (errorOut) *errorOut = [FlutterError errorWithCode:@"ERROR" message:@"dnaKey is required" details:nil];
        return NO;
    }

    if (authCode.length == 0) {
        if (errorOut) *errorOut = [FlutterError errorWithCode:@"ERROR" message:@"authCode is required" details:nil];
        return NO;
    }

    [HXBluetoothLockHelper setDeviceAESKey:aesKey authCode:authCode keyGroupId:keyGroupId bleProtocolVersion:bleProtocolVer lockMac:mac];
    self.bleClient.lastConnectedMac = mac;
    return YES;
}

- (void)openLock:(NSDictionary *)args result:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];

    FlutterError *cfgErr = nil;
    if (![self configureLockFromArgs:args error:&cfgErr]) {
        [one error:cfgErr.code message:cfgErr.message details:cfgErr.details];
        return;
    }

    NSString *mac = [PluginUtils lockMacFromArgs:args];

    [HXBluetoothLockHelper unlockWithMac:mac synchronizeTime:NO completionBlock:^(KSHStatusCode statusCode, NSString *reason, NSString *macOut, int power, int unlockingDuration) {
        (void)macOut; (void)power; (void)unlockingDuration;
        if (statusCode == KSHStatusCode_Success) {
            [one success:@YES];
        } else {
            NSString *msg = [NSString stringWithFormat:@"Code: %ld", (long)statusCode];
            [one error:@"FAILED" message:msg details:nil];
        }
        [self.bleClient disConnectBle:nil];
    }];
}

- (void)closeLock:(NSDictionary *)args result:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];

    FlutterError *cfgErr = nil;
    if (![self configureLockFromArgs:args error:&cfgErr]) {
        [one error:cfgErr.code message:cfgErr.message details:cfgErr.details];
        return;
    }

    NSString *mac = [PluginUtils lockMacFromArgs:args];

    [HXBluetoothLockHelper closeLockWithMac:mac completionBlock:^(KSHStatusCode statusCode, NSString *reason, NSString *macOut) {
        (void)reason; (void)macOut;
        if (statusCode == KSHStatusCode_Success) {
            [one success:@YES];
        } else {
            NSString *msg = [NSString stringWithFormat:@"Code: %ld", (long)statusCode];
            [one error:@"FAILED" message:msg details:nil];
        }
    }];
}

- (void)setKeyExpirationAlarmTime:(NSDictionary *)args result:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];

    FlutterError *cfgErr = nil;
    if (![self configureLockFromArgs:args error:&cfgErr]) {
        [one error:cfgErr.code message:cfgErr.message details:cfgErr.details];
        return;
    }

    int time = [PluginUtils intFromArgs:args key:@"time" defaultValue:0];
    NSString *mac = [PluginUtils lockMacFromArgs:args];

    SHBLEHotelLockSystemParam *param = [[SHBLEHotelLockSystemParam alloc] init];
    param.lockMac = mac;
    param.expirationAlarmTime = time;

    [HXBluetoothLockHelper setHotelLockSystemParam:param completionBlock:^(KSHStatusCode statusCode, NSString *reason) {
        (void)reason;
        if (statusCode == KSHStatusCode_Success) {
            [one success:@YES];
        } else {
            NSString *msg = [NSString stringWithFormat:@"Code: %ld", (long)statusCode];
            [one error:@"FAILED" message:msg details:nil];
        }
    }];
}

- (void)deleteLock:(NSDictionary *)args result:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];

    FlutterError *cfgErr = nil;
    if (![self configureLockFromArgs:args error:&cfgErr]) {
        [one error:cfgErr.code message:cfgErr.message details:cfgErr.details];
        return;
    }

    NSString *mac = [PluginUtils lockMacFromArgs:args];

    [HXBluetoothLockHelper deleteDeviceWithMac:mac completionBlock:^(KSHStatusCode statusCode, NSString *reason) {
        (void)reason;
        [self.bleClient disConnectBle:nil];
        if (statusCode == KSHStatusCode_Success) {
            [one success:@YES];
        } else {
            NSString *msg = [NSString stringWithFormat:@"Code: %ld", (long)statusCode];
            [one error:@"FAILED" message:msg details:nil];
        }
    }];
}

- (void)getDna:(NSDictionary *)args result:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];

    FlutterError *cfgErr = nil;
    if (![self configureLockFromArgs:args error:&cfgErr]) {
        [one error:cfgErr.code message:cfgErr.message details:cfgErr.details];
        return;
    }

    NSString *mac = [PluginUtils lockMacFromArgs:args];

    [HXBluetoothLockHelper getDNAInfoWithLockMac:mac completionBlock:^(KSHStatusCode statusCode, NSString *reason, HXBLEDeviceBase *deviceBase) {
        (void)reason; (void)deviceBase;
        if (statusCode == KSHStatusCode_Success) {
            // Android only returns a map with mac.
            [one success:@{ @"mac": mac ?: @"" }];
        } else {
            NSString *msg = [NSString stringWithFormat:@"Code: %ld", (long)statusCode];
            [one error:@"FAILED" message:msg details:nil];
        }
    }];
}

- (void)addDevice:(NSDictionary *)args result:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];
    NSLog(@"[BleLockManager] addDevice called with args: %@", args);
    NSString *mac = [PluginUtils lockMacFromArgs:args];
    if (mac.length == 0) {
        [one error:@"ERROR" message:@"mac is required" details:nil];
        return;
    }

    SHAdvertisementModel *ad = [self.scanManager advertisementForMac:mac];
    if (!ad) {
        [one error:@"FAILED" message:@"addDevice failed: Code -800009" details:nil];
        return;
    }

    HXAddBluetoothLockHelper *helper = [[HXAddBluetoothLockHelper alloc] init];
    [helper startAddDeviceWithAdvertisementModel:ad completionBlock:^(KSHStatusCode statusCode, NSString *reason, HXBLEDevice *device, HXBLEDeviceStatus *deviceStatus) {
        (void)reason; (void)device; (void)deviceStatus;
        if (statusCode == KSHStatusCode_Success) {
            // Android: returns boolean true on success.
            [one success:@YES];
        } else {
            NSString *msg = [NSString stringWithFormat:@"addDevice failed: Code %ld", (long)statusCode];
            [one error:@"FAILED" message:msg details:nil];
        }
    }];

    // TODO: Android flow: add -> getSysParam -> pairSuccessInd (+ rfModulePairing). HXJBLESDK has no direct equivalent for pairSuccessInd/rfModulePairing.
}

@end
