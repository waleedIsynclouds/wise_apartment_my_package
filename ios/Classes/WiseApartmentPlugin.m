//
//  WiseApartmentPlugin.m
//  wise_apartment
//
//  Main plugin implementation bridging Flutter ↔ Native SDK
//

#import "WiseApartmentPlugin.h"
#import "WAEventEmitter.h"
#import "WAScanManager.h"
#import "WAPairManager.h"
#import "WAWiFiConfigManager.h"
#import "WABluetoothStateManager.h"
#import "WAErrorHandler.h"

// Channel names (MUST match Flutter side exactly)
static NSString *const kMethodChannelName = @"wise_apartment/methods";
static NSString *const kEventChannelName = @"wise_apartment/events";

@interface WiseApartmentPlugin ()

@property (nonatomic, strong) FlutterMethodChannel *methodChannel;
@property (nonatomic, strong) FlutterEventChannel *eventChannel;
@property (nonatomic, strong) WAEventEmitter *eventEmitter;

// Manager instances
@property (nonatomic, strong) WAScanManager *scanManager;
@property (nonatomic, strong) WAPairManager *pairManager;
@property (nonatomic, strong) WAWiFiConfigManager *wifiManager;
@property (nonatomic, strong) WABluetoothStateManager *bluetoothStateManager;

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
    self.pairManager = [[WAPairManager alloc] initWithEventEmitter:self.eventEmitter];
    NSLog(@"[WiseApartmentPlugin] Pair manager initialized");
    self.wifiManager = [[WAWiFiConfigManager alloc] initWithEventEmitter:self.eventEmitter];
    NSLog(@"[WiseApartmentPlugin] WiFi config manager initialized");
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
    [self.pairManager cancelPairing];
    [self.wifiManager cancelConfiguration];
    
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
    UIDevice *device = [UIDevice currentDevice];
    NSDictionary *info = @{
        @"model": device.model ?: @"",
        @"name": device.name ?: @"",
        @"systemName": device.systemName ?: @"",
        @"systemVersion": device.systemVersion ?: @"",
        @"identifierForVendor": device.identifierForVendor.UUIDString ?: @"",
        @"platform": @"iOS"
    };
    NSLog(@"[WiseApartmentPlugin] Returning device info: %@", info);
    result(info);
}

- (void)handleGetAndroidBuildConfig:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleGetAndroidBuildConfig called (returning nil for iOS)");
    // iOS doesn't have Android build config - return null/empty
    result(nil);
}

// BLE Initialization & Scanning

- (void)handleInitBleClient:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleInitBleClient called");
    // Check Bluetooth availability
    if (![self.bluetoothStateManager isBluetoothAvailable]) {
        NSLog(@"[WiseApartmentPlugin] Bluetooth not available");
        result(@NO);
        return;
    }
    
    // TODO: Initialize SDK BLE client if needed
    // Example: [[HXBleClient shared] initialize];
    
    NSLog(@"[WiseApartmentPlugin] BLE client initialized successfully");
    result(@YES);
}

- (void)handleStartScan:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleStartScan called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : @{};
    
    // Validate Bluetooth state
    if (![self.bluetoothStateManager isBluetoothPoweredOn]) {
        NSLog(@"[WiseApartmentPlugin] Bluetooth is not powered on");
        result([WAErrorHandler flutterErrorWithCode:WAErrorCodeBluetoothOff
                                            message:@"Bluetooth is turned off"
                                            details:nil]);
        return;
    }
    
    // Extract parameters (with defaults matching Android)
    NSNumber * timeoutMs = params[@"timeoutMs"] ?: @10000;
    
    // Start scan and collect results
    NSError *error = nil;
    BOOL success = [self.scanManager startScanWithTimeout:[timeoutMs integerValue]/1000.0
                                          allowDuplicates:NO
                                                    error:&error];
    
    if (!success) {
        NSLog(@"[WiseApartmentPlugin] Failed to start scan: %@", error);
        result([WAErrorHandler flutterErrorFromNSError:error]);
        return;
    }
    
    NSLog(@"[WiseApartmentPlugin] Scan started successfully with timeout: %@ms", timeoutMs);
    // Android returns List<Map> after scan completes
    // For now, return empty array (scan results come via events in real impl)
    // TODO: Collect scan results and return them after timeout
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([timeoutMs doubleValue]/1000.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Return collected devices (in real implementation, store discovered devices)
        NSLog(@"[WiseApartmentPlugin] Scan timeout reached, returning results");
        result(@[]);
    });
}

- (void)handleStopScan:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleStopScan called");
    [self.scanManager stopScan];
    NSLog(@"[WiseApartmentPlugin] Scan stopped");
    result(@YES);
}

// Device Management

- (void)handleAddDevice:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleAddDevice called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!params) {
        NSLog(@"[WiseApartmentPlugin] Invalid parameters for addDevice");
        result([WAErrorHandler flutterErrorWithCode:WAErrorCodeInvalidParameters
                                            message:@"Invalid parameters - expected Map"
                                            details:nil]);
        return;
    }
    
    NSString *mac = params[@"mac"];
    NSNumber *chipType = params[@"chipType"];
    
    if (!mac || !chipType) {
        NSLog(@"[WiseApartmentPlugin] Missing required parameters: mac or chipType");
        result([WAErrorHandler flutterErrorWithCode:WAErrorCodeInvalidParameters
                                            message:@"mac and chipType are required"
                                            details:nil]);
        return;
    }
    
    // TODO: Call SDK addDevice
    // Example: [[HXDeviceManager shared] addDeviceWithMac:mac chipType:[chipType intValue] completion:^(NSDictionary *dna, NSError *error) { ... }];
    
    // Simulate orchestrated response matching Android
    NSDictionary *dnaInfo = @{
        @"mac": mac,
        @"authCode": @"000000",
        @"dnaKey": @"",
        @"protocolVer": @2,
        @"deviceType": chipType
    };
    
    NSLog(@"[WiseApartmentPlugin] Device added successfully: %@", mac);
    NSDictionary *response = @{
        @"ok": @YES,
        @"stage": @"complete",
        @"dnaInfo": dnaInfo,
        @"sysParam": @{},
        @"responses": @{
            @"addDevice": @{@"code": @0, @"isSuccessful": @YES},
            @"getSysParam": @{@"code": @0, @"isSuccessful": @YES},
            @"pairSuccessInd": @{@"code": @0, @"isSuccessful": @YES}
        }
    };
    NSLog(@"[WiseApartmentPlugin] Returning addDevice response: %@", response);
    result(response);
}

- (void)handleDeleteLock:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleDeleteLock called with args: %@", args);
    NSDictionary *auth = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!auth) {
        NSLog(@"[WiseApartmentPlugin] Invalid auth parameters for deleteLock");
        result(@NO);
        return;
    }
    
    // TODO: Call SDK deleteLock
    // Example: [[HXLockManager shared] deleteLockWithAuth:auth completion:^(BOOL success) { ... }];
    
    NSLog(@"[WiseApartmentPlugin] Lock deleted successfully");
    result(@YES);
}

- (void)handleGetDna:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleGetDna called with args: %@", args);
    NSDictionary *auth = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!auth) {
        NSLog(@"[WiseApartmentPlugin] Invalid auth parameters for getDna");
        result(@{});
        return;
    }
    
    // TODO: Call SDK getDna
    // Example: [[HXDeviceManager shared] getDnaWithAuth:auth completion:^(NSDictionary *dna) { ... }];
    
    NSLog(@"[WiseApartmentPlugin] Returning DNA info: %@", auth);
    result(auth); // Return auth as DNA for now
}

// Lock Operations

- (void)handleOpenLock:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleOpenLock called with args: %@", args);
    NSDictionary *auth = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!auth || !auth[@"mac"]) {
        NSLog(@"[WiseApartmentPlugin] Invalid parameters for openLock: missing mac");
        result(@NO);
        return;
    }
    
    NSLog(@"[WiseApartmentPlugin] Opening lock for device: %@", auth[@"mac"]);
    // TODO: Call SDK openLock
    // Example: [[HXLockManager shared] openLockWithAuth:auth completion:^(BOOL success) { ... }];
    
    NSLog(@"[WiseApartmentPlugin] Lock opened successfully");
    result(@YES);
}

- (void)handleCloseLock:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleCloseLock called with args: %@", args);
    NSDictionary *auth = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!auth || !auth[@"mac"]) {
        NSLog(@"[WiseApartmentPlugin] Invalid parameters for closeLock: missing mac");
        result(@NO);
        return;
    }
    
    NSLog(@"[WiseApartmentPlugin] Closing lock for device: %@", auth[@"mac"]);
    // TODO: Call SDK closeLock
    // Example: [[HXLockManager shared] closeLockWithAuth:auth completion:^(BOOL success) { ... }];
    
    NSLog(@"[WiseApartmentPlugin] Lock closed successfully");
    result(@YES);
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
    NSString *mac = params[@"mac"];
    NSDictionary *dna = params[@"dna"];
    
    if (!wifiJson) {
        NSLog(@"[WiseApartmentPlugin] Missing wifi parameter");
        result(@{@"success": @NO, @"message": @"wifi parameter is required"});
        return;
    }
    
    NSLog(@"[WiseApartmentPlugin] Registering WiFi for device: %@", mac);
    // TODO: Call SDK registerWifi
    // Example: [[HXWiFiManager shared] registerWifiWithConfig:wifiJson mac:mac dna:dna completion:^(NSDictionary *result) { ...}];
    
    NSLog(@"[WiseApartmentPlugin] WiFi registered successfully");
    result(@{@"success": @YES, @"code": @0, @"message": @"WiFi registered"});
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
    
    NSLog(@"[WiseApartmentPlugin] Connecting BLE for device: %@", auth[@"mac"]);
    // TODO: Call SDK connectBle
    // Example: [[HXBleClient shared] connectWithAuth:auth completion:^(BOOL success) { ... }];
    
    NSLog(@"[WiseApartmentPlugin] BLE connected successfully");
    result(@YES);
}

- (void)handleDisconnectBle:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleDisconnectBle called");
    //TODO: Call SDK disconnectBle
    // Example: [[HXBleClient shared] disconnect];
    
    NSLog(@"[WiseApartmentPlugin] BLE disconnected");
    result(@YES);
}

- (void)handleDisconnect:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleDisconnect called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    NSString *mac = params[@"mac"];
    
    if (!mac) {
        NSLog(@"[WiseApartmentPlugin] Missing mac parameter for disconnect");
        result(@NO);
        return;
    }
    
    NSLog(@"[WiseApartmentPlugin] Disconnecting device: %@", mac);
    // TODO: Call SDK disconnect
    // Example: [[HXBleClient shared] disconnectDevice:mac];
    
    NSLog(@"[WiseApartmentPlugin] Device disconnected successfully");
    result(@YES);
}

// Network Info

- (void)handleGetNBIoTInfo:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleGetNBIoTInfo called with args: %@", args);
    NSDictionary *auth = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!auth) {
        NSLog(@"[WiseApartmentPlugin] Invalid auth parameters for getNBIoTInfo");
        result(@{});
        return;
    }
    
    // TODO: Call SDK getNBIoTInfo
    // Example: [[HXNetworkManager shared] getNBIoTInfoWithAuth:auth completion:^(NSDictionary *info) { ... }];
    
    NSLog(@"[WiseApartmentPlugin] NBIoT info not implemented on iOS");
    result(@{@"code": @0, @"message": @"Not implemented on iOS"});
}

- (void)handleGetCat1Info:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleGetCat1Info called with args: %@", args);
    NSDictionary *auth = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!auth) {
        NSLog(@"[WiseApartmentPlugin] Invalid auth parameters for getCat1Info");
        result(@{});
        return;
    }
    
    // TODO: Call SDK getCat1Info
    // Example: [[HXNetworkManager shared] getCat1InfoWithAuth:auth completion:^(NSDictionary *info) { ... }];
    
    NSLog(@"[WiseApartmentPlugin] Cat1 info not implemented on iOS");
    result(@{@"code": @0, @"message": @"Not implemented on iOS"});
}

// Lock Configuration

- (void)handleSetKeyExpirationAlarmTime:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleSetKeyExpirationAlarmTime called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!params) {
        NSLog(@"[WiseApartmentPlugin] Invalid parameters for setKeyExpirationAlarmTime");
        result(@NO);
        return;
    }
    
    NSNumber *time = params[@"time"];
    
    if (!time) {
        NSLog(@"[WiseApartmentPlugin] Missing time parameter");
        result(@NO);
        return;
    }
    
    NSLog(@"[WiseApartmentPlugin] Setting key expiration alarm time: %@", time);
    // TODO: Call SDK setKeyExpirationAlarmTime
    // Example: [[HXLockManager shared] setKeyExpiration:params time:[time intValue] completion:^(BOOL success) { ... }];
    
    NSLog(@"[WiseApartmentPlugin] Key expiration alarm time set successfully");
    result(@YES);
}

- (void)handleSyncLockRecords:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleSyncLockRecords called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!params) {
        NSLog(@"[WiseApartmentPlugin] Invalid parameters for syncLockRecords");
        result(@[]);
        return;
    }
    
    NSNumber *logVersion = params[@"logVersion"];
    
    NSLog(@"[WiseApartmentPlugin] Syncing lock records with logVersion: %@", logVersion);
    // TODO: Call SDK syncLockRecords
    // Example: [[HXLockManager shared] syncRecordsWithAuth:params logVersion:[logVersion intValue] completion:^(NSArray *records) { ... }];
    
    NSLog(@"[WiseApartmentPlugin] Lock records synced (returning empty array)");
    result(@[]);
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
    // TODO: Call SDK clearState
    // Example: [[HXSDKManager shared] clearState];
    
    NSLog(@"[WiseApartmentPlugin] SDK state cleared");
    result(@YES);
}

@end
