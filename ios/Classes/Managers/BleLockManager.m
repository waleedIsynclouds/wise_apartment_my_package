#import "BleLockManager.h"

#import <HXJBLESDK/HXBluetoothLockHelper.h>
#import <HXJBLESDK/HXAddBluetoothLockHelper.h>
#import <HXJBLESDK/SHAdvertisementModel.h>
#import <HXJBLESDK/SHBLEHotelLockSystemParam.h>
#import <HXJBLESDK/HXBLEDeviceStatus.h>

#import "BleScanManager.h"
#import "HxjBleClient.h"
#import "OneShotResult.h"
#import "PluginUtils.h"

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
        if (errorOut) *errorOut = [FlutterError errorWithCode:@"ERROR" message:@"dnaKey is required" details:nil];
        return NO;
    }

    if (authCode.length == 0) {
        if (errorOut) *errorOut = [FlutterError errorWithCode:@"ERROR" message:@"authCode is required" details:nil];
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
    response[@"isSuccessful"] = @(code == 0x01); // KSHStatusCode_Success = 1
    response[@"isError"] = @(code != 0x01);
    response[@"lockMac"] = lockMac ?: @"";
    response[@"body"] = body ?: [NSNull null];
    
    return response;
}

#pragma mark - Public API (called from channel handler)

- (void)openLock:(NSDictionary *)args result:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];
    if (![self validateArgs:args method:@"openLock" one:one]) return;

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
                    params[@"deviceStatusStr"] = deviceStatus.deviceStatusStr ?: @"";
                    params[@"lockMac"] = deviceStatus.lockMac ?: mac;
                    params[@"openMode"] = @(deviceStatus.openMode);
                    params[@"normallyOpenMode"] = @(deviceStatus.normallyOpenMode);
                    params[@"normallyopenFlag"] = @(deviceStatus.normallyopenFlag);
                    params[@"volumeEnable"] = @(deviceStatus.volumeEnable);
                    params[@"shackleAlarmEnable"] = @(deviceStatus.shackleAlarmEnable);
                    params[@"tamperSwitchStatus"] = @(deviceStatus.tamperSwitchStatus);
                    params[@"lockCylinderAlarmEnable"] = @(deviceStatus.lockCylinderAlarmEnable);
                    params[@"cylinderSwitchStatus"] = @(deviceStatus.cylinderSwitchStatus);
                    params[@"antiLockEnable"] = @(deviceStatus.antiLockEnable);
                    params[@"antiLockStatues"] = @(deviceStatus.antiLockStatues);
                    params[@"lockCoverAlarmEnable"] = @(deviceStatus.lockCoverAlarmEnable);
                    params[@"lockCoverSwitchStatus"] = @(deviceStatus.lockCoverSwitchStatus);
                    params[@"systemTimeTimestamp"] = @(deviceStatus.systemTimeTimestamp);
                    params[@"timezoneOffset"] = @(deviceStatus.timezoneOffset);
                    params[@"systemVolume"] = @(deviceStatus.systemVolume);
                    params[@"power"] = @(deviceStatus.power);
                    params[@"lowPowerUnlockTimes"] = @(deviceStatus.lowPowerUnlockTimes);
                    params[@"enableKeyType"] = @(deviceStatus.enableKeyType);
                    params[@"squareTongueStatues"] = @(deviceStatus.squareTongueStatues);
                    params[@"obliqueTongueStatues"] = @(deviceStatus.obliqueTongueStatues);
                    params[@"systemLanguage"] = @(deviceStatus.systemLanguage);
                    params[@"menuFeature"] = @"";
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

- (void)setKeyExpirationAlarmTime:(NSDictionary *)args result:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];
    if (![self validateArgs:args method:@"setKeyExpirationAlarmTime" one:one]) return;

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

    if (args[@"name"] || args[@"RSSI"] || args[@"chipType"] || args[@"lockType"]) {
        advertisementModel = [[SHAdvertisementModel alloc] init];
        advertisementModel.mac = mac;

        if (args[@"name"]) advertisementModel.name = args[@"name"];

        // ✅ FIX #1: RSSI must be assigned to advertisementModel.RSSI (NSNumber*)
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
        // ✅ FIX #2: use self.addHelper (strong property) like the demo
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
                    // Build DNA info map
                    NSMutableDictionary *dnaMap = [NSMutableDictionary dictionary];
                    dnaMap[@"mac"] = device.lockMac ?: mac;
                    dnaMap[@"authCode"] = device.adminAuthCode ?: @"";
                    dnaMap[@"dnaKey"] = device.aesKey ?: @"";
                    dnaMap[@"protocolVer"] = @(device.bleProtocolVersion);
                    dnaMap[@"deviceType"] = @(device.lockType);
                    dnaMap[@"hardwareVer"] = device.hardwareVersion ?: @"";
                    dnaMap[@"softwareVer"] = device.rfMoudleSoftwareVer ?: @"";
                    dnaMap[@"rFModuleType"] = @(device.rfModuleType);
                    dnaMap[@"rFModuleMac"] = device.rfModuleMac ?: @"";
                    dnaMap[@"deviceDnaInfoStr"] = device.deviceDnaInfoStr ?: @"";
                    dnaMap[@"keyGroupId"] = @900;
                    
                    // Build sysParam map
                    NSMutableDictionary *sysParamMap = [NSMutableDictionary dictionary];
                    if (deviceStatus != nil) {
                        sysParamMap[@"deviceStatusStr"] = deviceStatus.deviceStatusStr ?: @"";
                        sysParamMap[@"lockMac"] = deviceStatus.lockMac ?: mac;
                        sysParamMap[@"openMode"] = @(deviceStatus.openMode);
                        sysParamMap[@"power"] = @(deviceStatus.power);
                        sysParamMap[@"systemVolume"] = @(deviceStatus.systemVolume);
                        sysParamMap[@"menuFeature"] = @"";
                    }
                    
                    // Build response matching Android structure
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
