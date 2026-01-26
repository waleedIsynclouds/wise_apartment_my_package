//
//  WiseApartmentPlugin.m
//  wise_apartment
//
//  Main plugin implementation bridging Flutter ↔ Native SDK
//

#import "WiseApartmentPlugin.h"
#import "WAEventEmitter.h"
#import "WAScanManager.h"
#import "WABluetoothStateManager.h"
#import "WAErrorHandler.h"

#import "BleScanManager.h"
#import "BleLockManager.h"
#import "DeviceInfoManager.h"
#import "LockRecordManager.h"
#import "HxjBleClient.h"

#import <HXJBLESDK/HXJBLESDKHeader.h>
#import <HXJBLESDK/SHBLENetworkConfigParam.h>

// Channel names (MUST match Flutter side exactly)
static NSString *const kMethodChannelName = @"wise_apartment/methods";
static NSString *const kEventChannelName = @"wise_apartment/events";

@interface WiseApartmentPlugin ()

@property (nonatomic, strong) FlutterMethodChannel *methodChannel;
@property (nonatomic, strong) FlutterEventChannel *eventChannel;
@property (nonatomic, strong) WAEventEmitter *eventEmitter;

// Manager instances
@property (nonatomic, strong) WAScanManager *scanManager;
@property (nonatomic, strong) WABluetoothStateManager *bluetoothStateManager;

// Android-parity manager instances
@property (nonatomic, strong) HxjBleClient *bleClient;
@property (nonatomic, strong) BleScanManager *bleScanManager;
@property (nonatomic, strong) DeviceInfoManager *deviceInfoManager;
@property (nonatomic, strong) BleLockManager *lockManager;
@property (nonatomic, strong) LockRecordManager *recordManager;

@property (nonatomic, copy, nullable) NSString *lastConnectedMac;

@end

@implementation WiseApartmentPlugin

#pragma mark - Plugin Registration

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    NSLog(@"[WiseApartmentPlugin] registerWithRegistrar called");
    WiseApartmentPlugin *instance = [[WiseApartmentPlugin alloc] init];
    
    // Setup MethodChannel
    instance.methodChannel = [FlutterMethodChannel
                             methodChannelWithName:kMethodChannelName
                             binaryMessenger:[registrar messenger]];
    [registrar addMethodCallDelegate:instance channel:instance.methodChannel];
    
    // Setup EventChannel
    instance.eventChannel = [FlutterEventChannel
                            eventChannelWithName:kEventChannelName
                            binaryMessenger:[registrar messenger]];
    [instance.eventChannel setStreamHandler:instance];
}

#pragma mark - Lifecycle

- (instancetype)init {
    NSLog(@"[WiseApartmentPlugin] Initializing plugin instance");
    self = [super init];
    if (self) {
        [self setupComponents];
    }
    NSLog(@"[WiseApartmentPlugin] Plugin instance initialized successfully");
    return self;
}

- (void)setupComponents {
    NSLog(@"[WiseApartmentPlugin] Setting up components");
    // Initialize event emitter (shared by all managers)
    self.eventEmitter = [[WAEventEmitter alloc] init];
    NSLog(@"[WiseApartmentPlugin] Event emitter initialized");
    
    // Initialize managers
    self.bluetoothStateManager = [[WABluetoothStateManager alloc] initWithEventEmitter:self.eventEmitter];
    NSLog(@"[WiseApartmentPlugin] Bluetooth state manager initialized");
    self.scanManager = [[WAScanManager alloc] initWithEventEmitter:self.eventEmitter];
    NSLog(@"[WiseApartmentPlugin] Scan manager initialized");

    // Android-parity managers
    self.bleClient = [[HxjBleClient alloc] init];
    self.bleScanManager = [[BleScanManager alloc] init];
    self.deviceInfoManager = [[DeviceInfoManager alloc] init];
    self.lockManager = [[BleLockManager alloc] initWithBleClient:self.bleClient scanManager:self.bleScanManager];
    self.recordManager = [[LockRecordManager alloc] initWithBleClient:self.bleClient];
    NSLog(@"[WiseApartmentPlugin] All components setup complete");
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    NSLog(@"[WiseApartmentPlugin] Detaching from engine");
    [self cleanup];
}

- (void)cleanup {
    NSLog(@"[WiseApartmentPlugin] Starting cleanup");
    // Stop all ongoing operations
    [self.scanManager stopScan];
    [self.bleScanManager stopScan];
    
    // Clear event sink
    [self.eventEmitter clearEventSink];
    
    // Nullify channels
    self.methodChannel = nil;
    self.eventChannel = nil;
    NSLog(@"[WiseApartmentPlugin] Cleanup complete");
}

#pragma mark - FlutterStreamHandler (EventChannel)

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events {
    NSLog(@"[WiseApartmentPlugin] Event channel onListen called");
    // Store event sink for streaming events to Flutter
    [self.eventEmitter setEventSink:events];
    return nil;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    NSLog(@"[WiseApartmentPlugin] Event channel onCancel called");
    // Clear event sink when Flutter stops listening
    [self.eventEmitter clearEventSink];
    return nil;
}

#pragma mark - FlutterPlugin (MethodChannel)

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *method = call.method;
    id args = call.arguments;
    NSLog(@"[WiseApartmentPlugin] handleMethodCall: %@ with args: %@", method, args);
    
    // Platform/Device Info Methods
    if ([@"getPlatformVersion" isEqualToString:method]) {
        [self handleGetPlatformVersion:result];
    }
    else if ([@"getDeviceInfo" isEqualToString:method]) {
        [self handleGetDeviceInfo:result];
    }
    else if ([@"getAndroidBuildConfig" isEqualToString:method]) {
        [self handleGetAndroidBuildConfig:result];
    }
    // BLE Initialization & Scanning
    else if ([@"initBleClient" isEqualToString:method]) {
        [self handleInitBleClient:result];
    }
    else if ([@"startScan" isEqualToString:method]) {
        [self handleStartScan:args result:result];
    }
    else if ([@"stopScan" isEqualToString:method]) {
        [self handleStopScan:result];
    }
    // Device Management
    else if ([@"addDevice" isEqualToString:method]) {
        [self handleAddDevice:args result:result];
    }
    else if ([@"deleteLock" isEqualToString:method]) {
        [self handleDeleteLock:args result:result];
    }
    else if ([@"getDna" isEqualToString:method]) {
        [self handleGetDna:args result:result];
    }
    // Lock Operations
    else if ([@"openLock" isEqualToString:method]) {
        [self handleOpenLock:args result:result];
    }
    else if ([@"closeLock" isEqualToString:method]) {
        [self handleCloseLock:args result:result];
    }
    // WiFi Configuration
    else if ([@"regWifi" isEqualToString:method]) {
        [self handleRegisterWifi:args result:result];
    }
    // BLE Connection
    else if ([@"connectBle" isEqualToString:method]) {
        [self handleConnectBle:args result:result];
    }
    else if ([@"disconnectBle" isEqualToString:method]) {
        [self handleDisconnectBle:result];
    }
    else if ([@"disconnect" isEqualToString:method]) {
        [self handleDisconnect:args result:result];
    }
    // Network Info
    else if ([@"getNBIoTInfo" isEqualToString:method]) {
        [self handleGetNBIoTInfo:args result:result];
    }
    else if ([@"getCat1Info" isEqualToString:method]) {
        [self handleGetCat1Info:args result:result];
    }
    // Lock Configuration
    else if ([@"setKeyExpirationAlarmTime" isEqualToString:method]) {
        [self handleSetKeyExpirationAlarmTime:args result:result];
    }
    else if ([@"syncLockRecords" isEqualToString:method]) {
        [self handleSyncLockRecords:args result:result];
    }
    else if ([@"syncLockRecordsPage" isEqualToString:method]) {
        [self handleSyncLockRecordsPage:args result:result];
    }
    else if ([@"addLockKey" isEqualToString:method]) {
        [self handleAddLockKey:args result:result];
    }
    else if ([@"syncLockKey" isEqualToString:method]) {
        [self handleSyncLockKey:args result:result];
    }
    else if ([@"syncLockTime" isEqualToString:method]) {
        [self handleSyncLockTime:args result:result];
    }
    else if ([@"getSysParam" isEqualToString:method]) {
        [self handleGetSysParam:args result:result];
    }
    // SDK State
    else if ([@"clearSdkState" isEqualToString:method]) {
        [self handleClearSdkState:result];
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - Method Handlers

// Platform/Device Info Methods

- (void)handleGetPlatformVersion:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleGetPlatformVersion called");
    NSString *version = [NSString stringWithFormat:@"iOS %@", [[UIDevice currentDevice] systemVersion]];
    NSLog(@"[WiseApartmentPlugin] Returning platform version: %@", version);
    result(version);
}

- (void)handleGetDeviceInfo:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleGetDeviceInfo called");
    [self.deviceInfoManager getDeviceInfo:result];
}

- (void)handleGetAndroidBuildConfig:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleGetAndroidBuildConfig called (returning nil for iOS)");
    [self.deviceInfoManager getAndroidBuildConfig:result];
}

// BLE Initialization & Scanning

- (void)handleInitBleClient:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleInitBleClient called");
    // Android always returns true once client is available.
    if (self.bleClient == nil) {
        self.bleClient = [[HxjBleClient alloc] init];
    }
    result(@YES);
}

- (void)handleStartScan:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleStartScan called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : @{};

    NSNumber *timeoutMs = params[@"timeoutMs"] ?: @10000;
    [self.bleScanManager startScan:timeoutMs result:result];
}

- (void)handleStopScan:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleStopScan called");
    [self.bleScanManager stopScan:result];
    NSLog(@"[WiseApartmentPlugin] Scan stopped");
}

// Device Management

- (void)handleAddDevice:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleAddDevice called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : @{};
    [self.lockManager addDevice:params result:result];
}

- (void)handleDeleteLock:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleDeleteLock called with args: %@", args);
    NSDictionary *auth = [args isKindOfClass:[NSDictionary class]] ? args : @{};
    [self.lockManager deleteLock:auth result:result];
}

- (void)handleGetDna:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleGetDna called with args: %@", args);
    NSDictionary *auth = [args isKindOfClass:[NSDictionary class]] ? args : @{};
    [self.lockManager getDna:auth result:result];
}

// Lock Operations

- (void)handleOpenLock:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleOpenLock called with args: %@", args);
    NSDictionary *auth = [args isKindOfClass:[NSDictionary class]] ? args : @{};
    [self.lockManager openLock:auth result:result];
}

- (void)handleCloseLock:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleCloseLock called with args: %@", args);
    NSDictionary *auth = [args isKindOfClass:[NSDictionary class]] ? args : @{};
    [self.lockManager closeLock:auth result:result];
}

// WiFi Configuration

- (void)handleRegisterWifi:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleRegisterWifi called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!params) {
        NSLog(@"[WiseApartmentPlugin] Invalid parameters for regWifi");
        result(@{@"success": @NO, @"message": @"Invalid parameters - expected Map"});
        return;
    }
    
    NSString *wifiJson = params[@"wifi"];
    NSDictionary *dna = params[@"dna"];
    NSString *mac = params[@"mac"] ?: dna[@"mac"];
    
    if (!wifiJson) {
        NSLog(@"[WiseApartmentPlugin] Missing wifi parameter");
        result(@{@"success": @NO, @"message": @"wifi parameter is required"});
        return;
    }
    
    if (!mac || ![mac isKindOfClass:[NSString class]] || mac.length == 0) {
        result(@{ @"success": @NO, @"code": @-1, @"message": @"mac is required" });
        return;
    }

    if (![dna isKindOfClass:[NSDictionary class]] || dna.count == 0) {
        result(@{ @"success": @NO, @"code": @-1, @"message": @"dna is required" });
        return;
    }

    if (![self wa_configureDeviceForAuth:dna]) {
        result(@{ @"success": @NO, @"code": @-1, @"message": @"Missing auth fields for WiFi config" });
        return;
    }

    SHBLENetworkConfigParam *param = [self wa_parseRfCode:wifiJson lockMac:[mac lowercaseString]];
    if (!param) {
        result(@{ @"success": @NO, @"code": @-1, @"message": @"Invalid wifi rfCode format" });
        return;
    }

    [HXBluetoothLockHelper configWiFiLockNetworkWithParam:param completionBlock:^(KSHStatusCode statusCode, NSString *reason, NSString *macOut, int wifiStatus, NSString *rfModuleMac, NSString *originalRfModuleMac) {
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL ok = (statusCode == KSHStatusCode_Success);
            result(@{
                @"success": @(ok),
                @"code": @((NSInteger)statusCode),
                @"message": reason ?: @"",
                @"lockMac": macOut ?: [mac lowercaseString],
                @"wifiStatus": @(wifiStatus),
                @"rfModuleMac": rfModuleMac ?: @"",
                @"originalRfModuleMac": originalRfModuleMac ?: @"",
            });
        });
    }];
}

// BLE Connection

- (void)handleConnectBle:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleConnectBle called with args: %@", args);
    NSDictionary *auth = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!auth || !auth[@"mac"]) {
        NSLog(@"[WiseApartmentPlugin] Invalid parameters for connectBle: missing mac");
        result(@NO);
        return;
    }
    
    NSString *mac = [auth[@"mac"] lowercaseString];
    if (![self wa_configureDeviceForAuth:auth]) {
        result(@NO);
        return;
    }

    [HXBluetoothLockHelper connectPeripheralWithMac:mac completionBlock:^(KSHStatusCode statusCode, NSString *reason) {
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL ok = (statusCode == KSHStatusCode_Success);
            if (ok) self.lastConnectedMac = mac;
            result(@(ok));
        });
    }];
}

- (void)handleDisconnectBle:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleDisconnectBle called");
    if (self.lastConnectedMac.length == 0) {
        result(@NO);
        return;
    }
    [HXBluetoothLockHelper tryDisconnectPeripheralWithMac:self.lastConnectedMac];
    result(@YES);
}

- (void)handleDisconnect:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleDisconnect called with args: %@", args);
    (void)args;
    [self.bleClient disConnectBle:nil];
    result(@YES);
}

#pragma mark - HXJBLESDK Helpers

- (BOOL)wa_configureDeviceForAuth:(NSDictionary *)auth {
    if (![auth isKindOfClass:[NSDictionary class]]) return NO;
    NSString *mac = auth[@"mac"];
    if (![mac isKindOfClass:[NSString class]] || mac.length == 0) return NO;

    NSString *authCode = auth[@"authCode"];
    NSString *dnaKey = auth[@"dnaKey"] ?: auth[@"aesKey"];
    NSNumber *keyGroupId = auth[@"keyGroupId"];
    NSNumber *bleProtocolVer = auth[@"bleProtocolVer"] ?: auth[@"bleProtocolVersion"] ?: auth[@"protocolVer"];

    if (![authCode isKindOfClass:[NSString class]] || authCode.length == 0) return NO;
    if (![dnaKey isKindOfClass:[NSString class]] || dnaKey.length == 0) return NO;
    if (![keyGroupId isKindOfClass:[NSNumber class]]) {
        if ([keyGroupId isKindOfClass:[NSString class]]) keyGroupId = @([(NSString *)keyGroupId intValue]);
    }
    if (![bleProtocolVer isKindOfClass:[NSNumber class]]) {
        if ([bleProtocolVer isKindOfClass:[NSString class]]) bleProtocolVer = @([(NSString *)bleProtocolVer intValue]);
    }
    if (![keyGroupId isKindOfClass:[NSNumber class]] || ![bleProtocolVer isKindOfClass:[NSNumber class]]) return NO;

    [HXBluetoothLockHelper setDeviceAESKey:dnaKey
                                 authCode:authCode
                               keyGroupId:[keyGroupId intValue]
                       bleProtocolVersion:[bleProtocolVer intValue]
                                  lockMac:[mac lowercaseString]];
    return YES;
}

- (nullable SHBLENetworkConfigParam *)wa_parseRfCode:(NSString *)rfCode lockMac:(NSString *)lockMac {
    if (![rfCode isKindOfClass:[NSString class]] || rfCode.length == 0) return nil;
    if (![lockMac isKindOfClass:[NSString class]] || lockMac.length == 0) return nil;

    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:@"\\\"([^\\\"]*)\\\"" options:0 error:nil];
    NSArray<NSTextCheckingResult *> *matches = [re matchesInString:rfCode options:0 range:NSMakeRange(0, rfCode.length)];
    if (matches.count < 12) return nil;

    NSMutableArray<NSString *> *parts = [NSMutableArray arrayWithCapacity:matches.count];
    for (NSTextCheckingResult *m in matches) {
        if (m.numberOfRanges < 2) continue;
        NSRange r = [m rangeAtIndex:1];
        [parts addObject:[rfCode substringWithRange:r]];
    }
    if (parts.count < 12) return nil;

    // Expected:
    // 0: "04" (prefix)
    // 1: updateToken ("01" update / "02" not)
    // 2: ssid
    // 3: password
    // 4: tokenId
    // 5: configType ("1"|"2"|"3")
    // 6: server host
    // 7: server port
    // 8: ipMode ("0" dhcp => autoGetIP YES; "1" manual => NO)
    // 9: manual ip
    // 10: subnet
    // 11: router

    SHBLENetworkConfigParam *p = [[SHBLENetworkConfigParam alloc] init];
    p.lockMac = lockMac;
    p.needListenCallbackStatus = YES;
    p.updateTokenId = [parts[1] isEqualToString:@"01"];
    p.tokenId = parts[4] ?: @"";
    p.configType = [parts[5] intValue];
    p.ssid = parts[2] ?: @"";
    p.password = parts[3] ?: @"";
    p.host = parts[6] ?: @"";
    p.port = [parts[7] intValue];

    NSString *ipMode = parts[8] ?: @"0";
    p.autoGetIP = [ipMode isEqualToString:@"0"];
    p.ip = parts[9] ?: @"";
    p.subnetwork = parts[10] ?: @"";
    p.routerIP = parts[11] ?: @"";
    return p;
}

// Network Info

- (void)handleGetNBIoTInfo:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleGetNBIoTInfo called with args: %@", args);
    NSDictionary *auth = [args isKindOfClass:[NSDictionary class]] ? args : @{};
    [self.deviceInfoManager getNBIoTInfo:auth result:result];
}

- (void)handleGetCat1Info:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleGetCat1Info called with args: %@", args);
    NSDictionary *auth = [args isKindOfClass:[NSDictionary class]] ? args : @{};
    [self.deviceInfoManager getCat1Info:auth result:result];
}

// Lock Configuration

- (void)handleSetKeyExpirationAlarmTime:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleSetKeyExpirationAlarmTime called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : @{};
    [self.lockManager setKeyExpirationAlarmTime:params result:result];
}

- (void)handleSyncLockRecords:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleSyncLockRecords called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : @{};
    [self.recordManager syncLockRecords:params result:result];
}

- (void)handleSyncLockRecordsPage:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleSyncLockRecordsPage called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!params) {
        NSLog(@"[WiseApartmentPlugin] Invalid parameters for syncLockRecordsPage");
        result(@{@"records": @[], @"total": @0});
        return;
    }
    
    NSNumber *startNum = params[@"startNum"];
    NSNumber *readCnt = params[@"readCnt"];
    
    NSLog(@"[WiseApartmentPlugin] Syncing lock records page - startNum: %@, readCnt: %@", startNum, readCnt);
    // TODO: Call SDK syncLockRecordsPage
    // Example: [[HXLockManager shared] syncRecordsPageWithAuth:params start:[startNum intValue] count:[readCnt intValue] completion:^(NSDictionary *result) { ... }];
    
    NSLog(@"[WiseApartmentPlugin] Lock records page synced (returning empty)");
    result(@{@"records": @[], @"total": @0});
}

- (void)handleAddLockKey:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleAddLockKey called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!params) {
        NSLog(@"[WiseApartmentPlugin] Invalid parameters for addLockKey");
        result(@{@"success": @NO});
        return;
    }
    
    NSLog(@"[WiseApartmentPlugin] Adding lock key with params: %@", params);
    // Parameters are within the dictionary itself
    // Example keys: mac, authCode, keyType, userType, etc.
    
    // TODO: Call SDK addLockKey
    // Example: [[HXKeyManager shared] addKeyWithParams:params completion:^(NSDictionary *result) { ... }];
    
    NSLog(@"[WiseApartmentPlugin] Lock key added successfully");
    result(@{@"success": @YES, @"code": @0});
}

- (void)handleSyncLockKey:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleSyncLockKey called with args: %@", args);
    NSDictionary *auth = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!auth) {
        NSLog(@"[WiseApartmentPlugin] Invalid auth parameters for syncLockKey");
        result(@{@"success": @NO});
        return;
    }
    
    NSLog(@"[WiseApartmentPlugin] Syncing lock keys");
    // TODO: Call SDK syncLockKey
    // Example: [[HXKeyManager shared] syncKeysWithAuth:auth completion:^(NSDictionary *result) { ... }];
    
    NSLog(@"[WiseApartmentPlugin] Lock keys synced successfully");
    result(@{@"success": @YES, @"keys": @[]});
}

- (void)handleSyncLockTime:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleSyncLockTime called with args: %@", args);
    NSDictionary *auth = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!auth) {
        NSLog(@"[WiseApartmentPlugin] Invalid auth parameters for syncLockTime");
        result(@NO);
        return;
    }
    
    NSLog(@"[WiseApartmentPlugin] Syncing lock time");
    // TODO: Call SDK syncLockTime
    // Example: [[HXLockManager shared] syncTimeWithAuth:auth completion:^(BOOL success) { ... }];
    
    NSLog(@"[WiseApartmentPlugin] Lock time synced successfully");
    result(@YES);
}

- (void)handleGetSysParam:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleGetSysParam called with args: %@", args);
    NSDictionary *auth = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!auth) {
        NSLog(@"[WiseApartmentPlugin] Invalid auth parameters for getSysParam");
        result(@{});
        return;
    }
    
    NSLog(@"[WiseApartmentPlugin] Getting system parameters");
    // TODO: Call SDK getSysParam
    // Example: [[HXLockManager shared] getSysParamWithAuth:auth completion:^(NSDictionary *params) { ... }];
    
    NSLog(@"[WiseApartmentPlugin] System parameters retrieved");
    result(@{@"code": @0, @"body": @{}});
}

// SDK State

- (void)handleClearSdkState:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleClearSdkState called");
    // Match Android: clear persisted state (best-effort)
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    if (bundleId.length > 0) {
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:bundleId];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    result(@YES);
}

@end
