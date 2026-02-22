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
#import <HXJBLESDK/HXAddBluetoothLockHelper.h>
#import <HXJBLESDK/SHBLENetworkConfigParam.h>
#import <HXJBLESDK/HXBLEAddPasswordKeyParams.h>
#import <HXJBLESDK/HXBLEAddOtherKeyParams.h>
#import <HXJBLESDK/HXKeyModel.h>
#import <HXJBLESDK/SHWiFiNetworkConfigReportParam.h>
#import <HXJBLESDK/JQBLEDefines.h>

// Channel names
// Primary MethodChannel name (per requirement)
static NSString *const kMethodChannelName = @"wise_apartment/ble";
// Backward-compatible alias used by existing Dart code in this repo
static NSString *const kLegacyMethodChannelName = @"wise_apartment/methods";
static NSString *const kEventChannelName = @"wise_apartment/ble_events";

@interface WiseApartmentPlugin ()

@property (nonatomic, strong) FlutterMethodChannel *methodChannel;
@property (nonatomic, strong) FlutterMethodChannel *legacyMethodChannel;
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
@property (nonatomic, strong) HXAddBluetoothLockHelper *addHelper;

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

    // Backward-compatible MethodChannel alias
    instance.legacyMethodChannel = [FlutterMethodChannel
                                   methodChannelWithName:kLegacyMethodChannelName
                                   binaryMessenger:[registrar messenger]];
    [registrar addMethodCallDelegate:instance channel:instance.legacyMethodChannel];
    
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
    self.recordManager = [[LockRecordManager alloc] initWithBleClient:self.bleClient eventEmitter:self.eventEmitter];
    
    // Register WiFi network config notification observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWiFiNetworkConfigNotification:)
                                                 name:KSHNotificationWiFiNetworkConfig
                                               object:nil];
    NSLog(@"[WiseApartmentPlugin] WiFi network config notification observer registered");
    
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

    // Remove WiFi network config observer
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KSHNotificationWiFiNetworkConfig
                                                  object:nil];
    NSLog(@"[WiseApartmentPlugin] WiFi network config notification observer removed");
    
    // Nullify channels
    self.methodChannel = nil;
    self.legacyMethodChannel = nil;
    self.eventChannel = nil;
    NSLog(@"[WiseApartmentPlugin] Cleanup complete");
}

#pragma mark - WiFi Network Config Notification

- (void)handleWiFiNetworkConfigNotification:(NSNotification *)notification {
    NSLog(@"[WiseApartmentPlugin] ========================================");
    NSLog(@"[WiseApartmentPlugin] WiFi Network Config Notification Received");
    NSLog(@"[WiseApartmentPlugin] ========================================");
    
    id notificationObject = notification.object;
    if (![notificationObject isKindOfClass:[SHWiFiNetworkConfigReportParam class]]) {
        NSLog(@"[WiseApartmentPlugin] ✗ Unexpected notification object type: %@", [notificationObject class]);
        return;
    }
    
    SHWiFiNetworkConfigReportParam *param = (SHWiFiNetworkConfigReportParam *)notificationObject;
    
    int wifiStatus = param.wifiStatus;
    NSString *rfModuleMac = param.rfModuleMac ?: @"";
    NSString *lockMac = param.lockMac ?: @"";
    
    // Determine status message
    NSString *statusMessage;
    switch (wifiStatus) {
        case 0x02:
            statusMessage = @"Network distribution binding in progress";
            break;
        case 0x04:
            statusMessage = @"WiFi module connected to router";
            break;
        case 0x05:
            statusMessage = @"WiFi module connected to cloud (success)";
            break;
        case 0x06:
            statusMessage = @"Incorrect password";
            break;
        case 0x07:
            statusMessage = @"WiFi configuration timeout";
            break;
        case 0x08:
            statusMessage = @"Device failed to connect to server";
            break;
        case 0x09:
            statusMessage = @"Device not authorized";
            break;
        default:
            statusMessage = [NSString stringWithFormat:@"Unknown status: 0x%02x", wifiStatus];
            break;
    }
    
    NSLog(@"[WiseApartmentPlugin] WiFi Status: 0x%02x - %@", wifiStatus, statusMessage);
    NSLog(@"[WiseApartmentPlugin] RF Module MAC: %@", rfModuleMac);
    NSLog(@"[WiseApartmentPlugin] Lock MAC: %@", lockMac);
    
    // Emit event to Flutter via EventChannel
    NSDictionary *event = @{
        @"type": @"wifiRegistration",
        @"status": @(wifiStatus),
        @"moduleMac": rfModuleMac,
        @"lockMac": lockMac,
        @"statusMessage": statusMessage
    };
    
    [self.eventEmitter emitEvent:event];
    NSLog(@"[WiseApartmentPlugin] WiFi registration event emitted to Flutter");
}

#pragma mark - FlutterStreamHandler (EventChannel)

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events {
    NSLog(@"[WiseApartmentPlugin] ========================================");
    NSLog(@"[WiseApartmentPlugin] ✓ onListen CALLED - Flutter started listening to EventChannel");
    NSLog(@"[WiseApartmentPlugin] ========================================");
    
    // Store event sink for streaming events to Flutter
    [self.eventEmitter setEventSink:events];
    
    // Verify it was set
    BOOL hasListener = [self.eventEmitter hasActiveListener];
    NSLog(@"[WiseApartmentPlugin] Event sink registered. hasActiveListener: %@", hasListener ? @"YES" : @"NO");
    
    return nil;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    NSLog(@"[WiseApartmentPlugin] ========================================");
    NSLog(@"[WiseApartmentPlugin] onCancel CALLED - Flutter stopped listening");
    NSLog(@"[WiseApartmentPlugin] ========================================");
    
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
    else if ([@"exitCmd" isEqualToString:method]) {
        [self.lockManager exitCmd:args result:result];
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
    else if ([@"addLockKeyStream" isEqualToString:method]) {
        NSLog(@"[WiseApartmentPlugin] handleAddLockKeyStream called with args: %@", args);
        NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : @{};

        // Use streaming version only when EventChannel listener is active
        if ([self.eventEmitter hasActiveListener]) {
            NSLog(@"[WiseApartmentPlugin] EventChannel listener active - starting addLockKeyStream");
            [self.lockManager addLockKeyStream:params eventEmitter:self.eventEmitter];
            result(@{ @"streaming": @YES, @"message": @"addLockKeyStream started - listen to EventChannel" });
        } else {
            NSLog(@"[WiseApartmentPlugin] No EventChannel listener - falling back to non-streaming addLockKey");
            // Fall back to the existing single-call behavior
            [self handleAddLockKey:args result:result];
        }
    }
    else if ([@"deleteLockKey" isEqualToString:method]) {
        [self handleDeleteLockKey:args result:result];
    }
    else if ([@"syncLockKey" isEqualToString:method]) {
        [self handleSyncLockKey:args result:result];
    }
    else if ([@"syncLockTime" isEqualToString:method]) {
        [self handleSyncLockTime:args result:result];
    }
    else if ([@"changeLockKeyPwd" isEqualToString:method]) {
        [self handleChangeLockKeyPwd:args result:result];
    }
    else if ([@"modifyLockKey" isEqualToString:method]) {
        [self handleModifyLockKey:args result:result];
    }
    else if ([@"enableLockKey" isEqualToString:method]) {
        [self handleEnableDisableKeyByType:args result:result];
    }
    else if ([@"getSysParam" isEqualToString:method]) {
        [self handleGetSysParam:args result:result];
    }
    else if ([@"getSysParamStream" isEqualToString:method]) {
        [self handleGetSysParamStream:args result:result];
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
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : @{};
    [self.lockManager deleteLock:params result:result];
}

- (void)handleGetDna:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleGetDna called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : @{};
    [self.lockManager getDna:params result:result];
}

// Lock Operations

- (void)handleOpenLock:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleOpenLock called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : @{};
    [self.lockManager openLock:params result:result];
}

- (void)handleCloseLock:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleCloseLock called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : @{};
    [self.lockManager closeLock:params result:result];
}

// WiFi Configuration

- (void)handleRegisterWifi:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleRegisterWifi called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!params) {
        NSLog(@"[WiseApartmentPlugin] Invalid parameters for regWifi");
        result(@{@"success": @NO, @"isSuccessful": @NO, @"isError": @YES, @"message": @"Invalid parameters - expected Map"});
        return;
    }

    // Per requirement: initialize addHelper before any steps.
    if (!self.addHelper) {
        self.addHelper = [[HXAddBluetoothLockHelper alloc] init];
    }

    // Extract data from Dart structure: {'wifi': wifiJson, 'dna': dna}
    NSString *wifiJson = params[@"wifi"];
    NSDictionary *dna = params[@"dna"];

    if (!wifiJson) {
        NSLog(@"[WiseApartmentPlugin] Missing wifi parameter");
        result(@{@"success": @NO, @"isSuccessful": @NO, @"isError": @YES, @"message": @"wifi parameter is required"});
        return;
    }

    if (![dna isKindOfClass:[NSDictionary class]]) {
        NSLog(@"[WiseApartmentPlugin] Missing or invalid dna parameter");
        result(@{@"success": @NO, @"isSuccessful": @NO, @"isError": @YES, @"message": @"dna parameter is required"});
        return;
    }

    // Extract mac from dna dictionary
    NSString *mac = dna[@"mac"];
    if (!mac || ![mac isKindOfClass:[NSString class]] || mac.length == 0) {
        // Attempt to infer mac from wifiJson as fallback
        if ([wifiJson isKindOfClass:[NSString class]]) {
            NSData *data = [(NSString *)wifiJson dataUsingEncoding:NSUTF8StringEncoding];
            if (data) {
                id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    id m = ((NSDictionary *)obj)[@"lockMac"] ?: ((NSDictionary *)obj)[@"mac"];
                    if ([m isKindOfClass:[NSString class]]) {
                        mac = (NSString *)m;
                    }
                }
            }
        }
    }

    if (!mac || ![mac isKindOfClass:[NSString class]] || mac.length == 0) {
        result(@{ @"success": @NO, @"isSuccessful": @NO, @"isError": @YES, @"code": @-1, @"message": @"mac is required" });
        return;
    }

    // Prepare: set device AES key before calling SDK methods (prevents 228 error)
    if (![self prepare:dna]) {
        result(@{ @"success": @NO, @"isSuccessful": @NO, @"isError": @YES, @"code": @228, @"message": @"Device not prepared: provide dnaKey/authCode or call addDevice first" });
        return;
    }

    // Build SHBLENetworkConfigParam.
    SHBLENetworkConfigParam *param = nil;
        if ([wifiJson isKindOfClass:[NSString class]]) {
            NSData *data = [((NSString *)wifiJson) dataUsingEncoding:NSUTF8StringEncoding];
            if (data) {
                NSError *jsonErr = nil;
                id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonErr];
                if (jsonErr == nil && [obj isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *m = (NSDictionary *)obj;
                    param = [[SHBLENetworkConfigParam alloc] init];
                    param.lockMac = [mac lowercaseString];
                    id ct = m[@"configType"];
                    if ([ct respondsToSelector:@selector(intValue)]) param.configType = [ct intValue];
                    id ut = m[@"updateTokenId"];
                    if ([ut respondsToSelector:@selector(boolValue)]) param.updateTokenId = [ut boolValue];
                    id token = m[@"tokenId"];
                    if ([token isKindOfClass:[NSString class]]) param.tokenId = (NSString *)token;
                    id ssid = m[@"ssid"];
                    if ([ssid isKindOfClass:[NSString class]]) param.ssid = (NSString *)ssid;
                    id pwd = m[@"password"];
                    if ([pwd isKindOfClass:[NSString class]]) param.password = (NSString *)pwd;
                    id host = m[@"host"];
                    if ([host isKindOfClass:[NSString class]]) param.host = (NSString *)host;
                    id port = m[@"port"];
                    if ([port respondsToSelector:@selector(intValue)]) param.port = [port intValue];
                    id ag = m[@"autoGetIP"];
                    if ([ag respondsToSelector:@selector(boolValue)]) param.autoGetIP = [ag boolValue];
                    id ip = m[@"ip"];
                    if ([ip isKindOfClass:[NSString class]]) param.ip = (NSString *)ip;
                    id sub = m[@"subnetwork"];
                    if ([sub isKindOfClass:[NSString class]]) param.subnetwork = (NSString *)sub;
                    id router = m[@"routerIP"];
                    if ([router isKindOfClass:[NSString class]]) param.routerIP = (NSString *)router;
                } else {
                    // JSON parsing failed or not a dict — try legacy pipe-delimited quoted format
                    // If the incoming string contains '|' it's likely the legacy pipe format — parse directly.
                    NSString *rawWifi = (NSString *)wifiJson;
                    NSString *unescaped = [rawWifi stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
                    unescaped = [unescaped stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];

                    if ([unescaped containsString:@"|"]) {
                        // First, try the RF code parser
                        SHBLENetworkConfigParam *parsed = [self wa_parseRfCode:unescaped lockMac:mac];
                        if (parsed != nil) {
                            param = parsed;
                        } else {
                            // Robust fallback: strip braces, split on '|' and trim surrounding quotes
                            NSString *trimmed = [unescaped stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            if ([trimmed hasPrefix:@"{"] && [trimmed hasSuffix:@"}"]) {
                                trimmed = [trimmed substringWithRange:NSMakeRange(1, trimmed.length - 2)];
                            }

                            NSArray<NSString *> *partsRaw = [trimmed componentsSeparatedByString:@"|"];
                            NSMutableArray<NSString *> *parts = [NSMutableArray arrayWithCapacity:partsRaw.count];
                            for (NSString *p in partsRaw) {
                                NSString *t = [p stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                if (t.length == 0) {
                                    [parts addObject:@""]; continue;
                                }
                                // Remove surrounding double quotes or other quote-like characters
                                NSCharacterSet *quotes = [NSCharacterSet characterSetWithCharactersInString:@"\"'“”`‘’"];
                                while (t.length > 0 && [quotes characterIsMember:[t characterAtIndex:0]]) {
                                    t = [t substringFromIndex:1];
                                }
                                while (t.length > 0 && [quotes characterIsMember:[t characterAtIndex:t.length - 1]]) {
                                    t = [t substringToIndex:t.length - 1];
                                }
                                t = [t stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                [parts addObject:t ?: @""];
                            }

                            if (parts.count >= 6) {
                                param = [[SHBLENetworkConfigParam alloc] init];
                                param.lockMac = [mac lowercaseString];
                                // parts indices based on observed vendor format
                                // 0: prefix, 1: updateToken (01/02), 2: ssid, 3: password, 4: tokenId, 5: configType, 6: host, 7: port, 8: ipMode, 9: ip, 10: subnet, 11: router
                                if (parts.count > 1) param.updateTokenId = ([parts[1] isEqualToString:@"01"] || [[parts[1] lowercaseString] isEqualToString:@"true"]);
                                if (parts.count > 5) param.configType = [parts[5] intValue];
                                if (parts.count > 2) param.ssid = parts[2];
                                if (parts.count > 3) param.password = parts[3];
                                if (parts.count > 4) param.tokenId = parts[4];
                                if (parts.count > 6) param.host = parts[6];
                                if (parts.count > 7) param.port = [parts[7] intValue];
                                if (parts.count > 8) param.autoGetIP = [parts[8] isEqualToString:@"0"]; // 0 => auto (DHCP)
                                if (parts.count > 9) param.ip = parts[9];
                                if (parts.count > 10) param.subnetwork = parts[10];
                                if (parts.count > 11) param.routerIP = parts[11];

                                NSLog(@"[WiseApartmentPlugin] Parsed legacy wifi: ssid=%@ host=%@ port=%@ token=%@", param.ssid ?: @"", param.host ?: @"", @(param.port), param.tokenId ?: @"");
                            } else {
                                NSLog(@"[WiseApartmentPlugin] handleRegisterWifi: wifi string not JSON and not recognized pipe format: %@", wifiJson);
                            }
                        }
                    } else {
                        // Not pipe-delimited — try RF parser as last resort
                        SHBLENetworkConfigParam *parsed = [self wa_parseRfCode:(NSString *)wifiJson lockMac:mac];
                        if (parsed != nil) param = parsed;
                        else NSLog(@"[WiseApartmentPlugin] handleRegisterWifi: wifi string not JSON and not recognized: %@", wifiJson);
                    }
                }
                }
            }
        

    if (!param) {
        NSLog(@"[WiseApartmentPlugin] Failed to parse WiFi configuration parameters");
        result(@{@"success": @NO, @"isSuccessful": @NO, @"isError": @YES, @"message": @"Failed to parse WiFi configuration"});
        return;
    }
    

    // No notification observer registered; only SDK completion result will be returned.

    // Call the new SDK API (completion block only returns statusCode + reason)
    [HXBluetoothLockHelper configWiFiLockNetworkWithParam:param completionBlock:^(KSHStatusCode statusCode, NSString *reason, NSString *macOut, int wifiStatus, NSString *rfModuleMac, NSString *originalRfModuleMac) {
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL ok = (statusCode == KSHStatusCode_Success);
            NSString *lockMacOut = macOut ?: [mac lowercaseString];
            result(@{
                @"success": @(ok),
                @"isSuccessful": @(ok),
                @"isError": @(!ok),
                @"code": @((NSInteger)statusCode),
                @"message": reason ?: @"",
                @"lockMac": lockMacOut,
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
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!params || !params[@"mac"]) {
        NSLog(@"[WiseApartmentPlugin] Invalid parameters for connectBle: missing mac");
        result(@NO);
        return;
    }
    
    // Per requirement: initialize addHelper before any steps.
    if (!self.addHelper) {
        self.addHelper = [[HXAddBluetoothLockHelper alloc] init];
    }
    
    NSString *mac = [params[@"mac"] lowercaseString];
    // Prepare: configure device auth before connecting
    [self prepare:params];
    
    [HXBluetoothLockHelper connectPeripheralWithMac:mac completionBlock:^(KSHStatusCode statusCode, NSString *reason) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"[WiseApartmentPlugin] connectPeripheralWithMac callback - mac: %@, status: %d, reason: %@", mac, (int)statusCode, reason ?: @"");
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
    
    // Per requirement: initialize addHelper before any steps.
    if (!self.addHelper) {
        self.addHelper = [[HXAddBluetoothLockHelper alloc] init];
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

    // Resolve auth material: prefer provided `auth` values, fallback to cached values when missing.
    NSDictionary *cached = [self.bleClient authForMac:mac];

    NSString *authCode = nil;
    if ([auth isKindOfClass:[NSDictionary class]] && [auth[@"authorizedRoot"] isKindOfClass:[NSString class]] && ((NSString *)auth[@"authorizedRoot"]).length > 0) {
        authCode = auth[@"authorizedRoot"];
        NSLog(@"[WiseApartmentPlugin] Using provided authorizedRoot for mac %@", mac);
    } else if ([cached isKindOfClass:[NSDictionary class]] && [cached[@"authorizedRoot"] isKindOfClass:[NSString class]]) {
        authCode = cached[@"authorizedRoot"];
        NSLog(@"[WiseApartmentPlugin] Using cached authorizedRoot for mac %@", mac);
    }

    NSString *dnaKey = nil;
    if ([auth isKindOfClass:[NSDictionary class]] && [auth[@"dnaAes128Key"] isKindOfClass:[NSString class]] && ((NSString *)auth[@"dnaAes128Key"]).length > 0) {
        dnaKey = auth[@"dnaAes128Key"];
        NSLog(@"[WiseApartmentPlugin] Using provided dnaAes128Key for mac %@", mac);
    } else if ([auth isKindOfClass:[NSDictionary class]] && [auth[@"aesKey"] isKindOfClass:[NSString class]] && ((NSString *)auth[@"aesKey"]).length > 0) {
        dnaKey = auth[@"aesKey"];
        NSLog(@"[WiseApartmentPlugin] Using provided aesKey for mac %@", mac);
    } else if ([cached isKindOfClass:[NSDictionary class]] && [cached[@"dnaAes128Key"] isKindOfClass:[NSString class]]) {
        dnaKey = cached[@"dnaAes128Key"];
        NSLog(@"[WiseApartmentPlugin] Using cached dnaAes128Key for mac %@", mac);
    } else if ([cached isKindOfClass:[NSDictionary class]] && [cached[@"aesKey"] isKindOfClass:[NSString class]]) {
        dnaKey = cached[@"aesKey"];
        NSLog(@"[WiseApartmentPlugin] Using cached aesKey for mac %@", mac);
    }

    // keyGroupId: prefer provided, else cached, else default 900
    NSNumber *keyGroupId = nil;
    if ([auth isKindOfClass:[NSDictionary class]] && auth[@"keyGroupId"] != nil) {
        keyGroupId = auth[@"keyGroupId"];
    } else if ([cached isKindOfClass:[NSDictionary class]] && cached[@"keyGroupId"] != nil) {
        keyGroupId = cached[@"keyGroupId"];
    }
    if ([keyGroupId isKindOfClass:[NSString class]]) keyGroupId = @([(NSString *)keyGroupId intValue]);
    if (![keyGroupId isKindOfClass:[NSNumber class]]) keyGroupId = @(900);

    // ble/protocol version: prefer provided, else cached, else 0
    NSNumber *bleProtocolVer = nil;
    if ([auth isKindOfClass:[NSDictionary class]] && auth[@"bleProtocolVer"] != nil) {
        bleProtocolVer = auth[@"bleProtocolVer"];
    } else if ([auth isKindOfClass:[NSDictionary class]] && auth[@"protocolVer"] != nil) {
        bleProtocolVer = auth[@"protocolVer"];
    } else if ([cached isKindOfClass:[NSDictionary class]] && cached[@"bleProtocolVer"] != nil) {
        bleProtocolVer = cached[@"bleProtocolVer"];
    } else if ([cached isKindOfClass:[NSDictionary class]] && cached[@"protocolVer"] != nil) {
        bleProtocolVer = cached[@"protocolVer"];
    }
    if ([bleProtocolVer isKindOfClass:[NSString class]]) bleProtocolVer = @([(NSString *)bleProtocolVer intValue]);
    if (![bleProtocolVer isKindOfClass:[NSNumber class]]) bleProtocolVer = @(0);

    if (![authCode isKindOfClass:[NSString class]] || authCode.length == 0) {
        NSLog(@"[WiseApartmentPlugin] prepare failed: missing authorizedRoot for mac %@ (provided or cached)", mac);
        return NO;
    }
    if (![dnaKey isKindOfClass:[NSString class]] || dnaKey.length == 0) {
        NSLog(@"[WiseApartmentPlugin] prepare failed: missing dna/aes key for mac %@ (provided or cached)", mac);
        return NO;
    }

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
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : @{};
    [self.deviceInfoManager getNBIoTInfo:params result:result];
}

- (void)handleGetCat1Info:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleGetCat1Info called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : @{};
    [self.deviceInfoManager getCat1Info:params result:result];
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

    // Streaming mode: results are emitted via EventChannel; return immediately.
    if ([self.eventEmitter hasActiveListener]) {
        NSLog(@"[WiseApartmentPlugin] Using streaming syncLockRecords");
        [self.recordManager syncLockRecordsStream:params];
        result(nil);
        return;
    }

    // Non-streaming fallback.
    NSLog(@"[WiseApartmentPlugin] Using non-streaming syncLockRecords (no active listener)");
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
        result(@{@"success": @NO, @"message": @"Invalid parameters"});
        return;
    }
    
    // Per requirement: initialize addHelper before any steps.
    if (!self.addHelper) {
        self.addHelper = [[HXAddBluetoothLockHelper alloc] init];
    }
    
    // Prepare: set device AES key before calling SDK methods
    if (![self prepare:params]) {
        result(@{@"success": @NO, @"code": @228, @"message": @"Device not prepared: provide dnaKey/authCode or call addDevice first"});
        return;
    }
    
    NSString *mac = [params[@"mac"] lowercaseString];
    if (!mac || mac.length == 0) {
        result(@{@"success": @NO, @"message": @"mac is required"});
        return;
    }
    
    // Extract action map (containing key-specific parameters)
    NSDictionary *actionMap = [params[@"action"] isKindOfClass:[NSDictionary class]] ? params[@"action"] : @{};
    
    // Determine key type: password (if password field exists) or other (fingerprint/card/remote)
    NSString *password = actionMap[@"password"];
    int addedKeyType = [actionMap[@"addedKeyType"] intValue]; // 1=password, 2=fingerprint, 3=card, 4=remote
    
    HXBLEAddKeyBaseParams *addKeyParams = nil;
    
    if (password && password.length > 0) {
        // Add password key
        HXBLEAddPasswordKeyParams *passwordParams = [[HXBLEAddPasswordKeyParams alloc] init];
        passwordParams.key = password;
        addKeyParams = passwordParams;
    } else if (addedKeyType >= 2 && addedKeyType <= 4) {
        // Add fingerprint/card/remote key
        HXBLEAddOtherKeyParams *otherParams = [[HXBLEAddOtherKeyParams alloc] init];
        
        // Map addedKeyType to KSHKeyType
        if (addedKeyType == 2) {
            otherParams.keyType = KSHKeyType_Fingerprint;
        } else if (addedKeyType == 3) {
            otherParams.keyType = KSHKeyType_Card;
            // If cardId provided, add by card number; otherwise swipe to add
            NSString *cardId = actionMap[@"cardId"];
            if (cardId && cardId.length > 0) {
                otherParams.cardId = cardId;
            }
        } else if (addedKeyType == 4) {
            otherParams.keyType = KSHKeyType_RemoteControl;
        }
        
        addKeyParams = otherParams;
    } else {
        result(@{@"success": @NO, @"message": @"Invalid key type or missing password"});
        return;
    }
    
    // Set common base parameters
    addKeyParams.lockMac = mac;
    addKeyParams.keyGroupId = [actionMap[@"addedKeyGroupId"] intValue] ?: 900;
    addKeyParams.vaildNumber = [actionMap[@"vaildNumber"] intValue] ?: 255; // 255 = unlimited
    addKeyParams.validStartTime = [actionMap[@"validStartTime"] longValue] ?: 0; // 0 = permanent
    addKeyParams.validEndTime = [actionMap[@"validEndTime"] longValue] ?: 0xFFFFFFFF; // 0xFFFFFFFF = permanent
    addKeyParams.authMode = [actionMap[@"vaildMode"] intValue] ?: 1; // 1 = validity period, 2 = periodic
    
    // Optional: periodic authorization parameters (authMode == 2)
    if (addKeyParams.authMode == 2) {
        addKeyParams.week = [actionMap[@"week"] intValue] ?: 0;
        addKeyParams.dayStartTimes = [actionMap[@"dayStartTimes"] intValue] ?: 0;
        addKeyParams.dayEndTimes = [actionMap[@"dayEndTimes"] intValue] ?: 0;
    }
    
    NSLog(@"[WiseApartmentPlugin] Adding lock key - type: %d, mac: %@", addedKeyType, mac);
    
    @try {
        [HXBluetoothLockHelper addKey:addKeyParams completionBlock:^(KSHStatusCode statusCode, NSString *reason, HXKeyModel *keyObj, int authTotal, int authCount) {
            @try {
                NSLog(@"[WiseApartmentPlugin] addKey callback - status: %d, authTotal: %d, authCount: %d", (int)statusCode, authTotal, authCount);
                
                // Build response body
                NSMutableDictionary *body = [NSMutableDictionary dictionary];
                if (keyObj != nil) {
                    NSDictionary *keyMap = [keyObj dicFromObject];
                    if ([keyMap isKindOfClass:[NSDictionary class]]) {
                        body[@"keyObj"] = keyMap;
                    }
                }
                body[@"authTotal"] = @(authTotal);
                body[@"authCount"] = @(authCount);
                body[@"statusCode"] = @((int)statusCode);
                
                BOOL ok = (statusCode == KSHStatusCode_Success);
                body[@"success"] = @(ok);
                body[@"code"] = @((int)statusCode);
                body[@"message"] = reason ?: @"";
                body[@"lockMac"] = mac;
                
                // For fingerprint/card adding, multiple callbacks may be triggered
                // Only send final result when key is successfully added or error occurs
                if (ok && keyObj != nil) {
                    // Key successfully added - send success
                    NSLog(@"[WiseApartmentPlugin] Lock key added successfully");
                    result(body);
                } else if (!ok) {
                    // Error occurred - send error
                    NSLog(@"[WiseApartmentPlugin] Lock key add failed: %@", reason);
                    result(body);
                } else if (authTotal != 255 && authCount >= authTotal) {
                    // Fingerprint verification complete but no key returned yet
                    NSLog(@"[WiseApartmentPlugin] Verification complete (%d/%d)", authCount, authTotal);
                    result(body);
                }
                // Otherwise, this is an intermediate callback (fingerprint verification in progress)
                // Don't send result yet - wait for final callback
            } @catch (NSException *exception) {
                NSLog(@"[WiseApartmentPlugin] Exception in addKey callback: %@", exception);
                result(@{@"success": @NO, @"message": exception.reason ?: @"Exception in addKey callback"});
            }
        }];
    } @catch (NSException *exception) {
        NSLog(@"[WiseApartmentPlugin] Exception calling addKey: %@", exception);
        result(@{@"success": @NO, @"message": exception.reason ?: @"Exception calling addKey"});
    }
}

- (void)handleDeleteLockKey:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleDeleteLockKey called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!params) {
        NSLog(@"[WiseApartmentPlugin] Invalid parameters for deleteLockKey");
        result(@{@"success": @NO, @"message": @"Invalid parameters"});
        return;
    }
    
    // Prepare: set device AES key before calling SDK methods
    if (![self prepare:params]) {
        result(@{@"success": @NO, @"code": @228, @"message": @"Device not prepared: provide dnaKey/authCode or call addDevice first"});
        return;
    }
    
    NSString *mac = [params[@"mac"] lowercaseString];
    if (!mac || mac.length == 0) {
        result(@{@"success": @NO, @"message": @"mac is required"});
        return;
    }
    
    // Extract action map
    NSDictionary *actionMap = [params[@"action"] isKindOfClass:[NSDictionary class]] ? params[@"action"] : @{};
    if (actionMap.count == 0) {
        result(@{@"success": @NO, @"message": @"action map is required"});
        return;
    }
    
    int deleteMode = [actionMap[@"deleteMode"] intValue];
    
    // Validate deleteMode
    if (deleteMode < 0 || deleteMode > 3) {
        result(@{@"success": @NO, @"message": @"deleteMode must be 0, 1, 2, or 3"});
        return;
    }
    
    // Create delete key params
    HXDeleteKeyParams *deleteParams = [[HXDeleteKeyParams alloc] init];
    deleteParams.lockMac = mac;
    deleteParams.deleteMode = deleteMode;
    
    // Validate and set fields based on deleteMode
    switch (deleteMode) {
        case 0: // Delete by key number
            if (!actionMap[@"deleteKeyType"]) {
                result(@{@"success": @NO, @"message": @"deleteKeyType is required for deleteMode 0"});
                return;
            }
            if (!actionMap[@"deleteKeyId"]) {
                result(@{@"success": @NO, @"message": @"deleteKeyId is required for deleteMode 0"});
                return;
            }
            deleteParams.keyType = [actionMap[@"deleteKeyType"] intValue];
            deleteParams.lockKeyId = [actionMap[@"deleteKeyId"] intValue];
            break;
            
        case 1: // Delete by key type
            if (!actionMap[@"deleteKeyType"]) {
                result(@{@"success": @NO, @"message": @"deleteKeyType is required for deleteMode 1"});
                return;
            }
            deleteParams.keyType = [actionMap[@"deleteKeyType"] intValue];
            break;
            
        case 2: // Delete by content
            if (!actionMap[@"deleteKeyType"]) {
                result(@{@"success": @NO, @"message": @"deleteKeyType is required for deleteMode 2"});
                return;
            }
            if (!actionMap[@"cardNumOrPassword"]) {
                result(@{@"success": @NO, @"message": @"cardNumOrPassword is required for deleteMode 2"});
                return;
            }
            deleteParams.keyType = [actionMap[@"deleteKeyType"] intValue];
            deleteParams.passwordOrCar = actionMap[@"cardNumOrPassword"];
            break;
            
        case 3: // Delete by user ID
            if (!actionMap[@"deleteKeyGroupId"]) {
                result(@{@"success": @NO, @"message": @"deleteKeyGroupId is required for deleteMode 3"});
                return;
            }
            deleteParams.keyGroupId = [actionMap[@"deleteKeyGroupId"] intValue];
            break;
            
        default:
            result(@{@"success": @NO, @"message": @"Invalid deleteMode"});
            return;
    }
    
    NSLog(@"[WiseApartmentPlugin] Deleting lock key - mode: %d, mac: %@", deleteMode, mac);
    
    @try {
        [HXBluetoothLockHelper deleteKey:deleteParams completionBlock:^(KSHStatusCode statusCode, NSString *reason) {
            @try {
                NSLog(@"[WiseApartmentPlugin] deleteKey callback - status: %d, reason: %@", (int)statusCode, reason);
                
                BOOL ok = (statusCode == KSHStatusCode_Success);
                NSMutableDictionary *body = [NSMutableDictionary dictionary];
                body[@"success"] = @(ok);
                body[@"code"] = @((int)statusCode);
                body[@"statusCode"] = @((int)statusCode);
                body[@"message"] = reason ?: @"";
                body[@"lockMac"] = mac;
                
                if (ok) {
                    NSLog(@"[WiseApartmentPlugin] Lock key deleted successfully");
                } else {
                    NSLog(@"[WiseApartmentPlugin] Lock key delete failed: %@", reason);
                }
                
                result(body);
            } @catch (NSException *exception) {
                NSLog(@"[WiseApartmentPlugin] Exception in deleteKey callback: %@", exception);
                result(@{@"success": @NO, @"message": [exception reason] ?: @"Unknown exception"});
            }
        }];
    } @catch (NSException *exception) {
        NSLog(@"[WiseApartmentPlugin] Exception in handleDeleteLockKey: %@", exception);
        result(@{@"success": @NO, @"message": [exception reason] ?: @"Unknown exception"});
    }
}

- (void)handleSyncLockKey:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] ========================================");
    NSLog(@"[WiseApartmentPlugin] handleSyncLockKey CALLED");
    NSLog(@"[WiseApartmentPlugin] ========================================");
    NSLog(@"[WiseApartmentPlugin] Args: %@", args);
    
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!params) {
        NSLog(@"[WiseApartmentPlugin] ✗ ERROR: Invalid parameters for syncLockKey");
        result(@{@"success": @NO});
        return;
    }

    // Check if EventEmitter has active listener
    BOOL hasListener = [self.eventEmitter hasActiveListener];
    NSLog(@"[WiseApartmentPlugin] Checking hasActiveListener: %@", hasListener ? @"YES" : @"NO");
    
    if (hasListener) {
        NSLog(@"[WiseApartmentPlugin] ✓ Using STREAMING mode (EventChannel active)");
        NSLog(@"[WiseApartmentPlugin]   ↳ Calling syncLockKeyStream...");
        
        // Call streaming version with eventEmitter directly (matches syncLockRecords pattern)
        [self.lockManager syncLockKeyStream:params eventEmitter:self.eventEmitter];
        // IMPORTANT: Return a valid acknowledgment (not nil) - Flutter requires non-null

        NSLog(@"[WiseApartmentPlugin]   ↳ Returning acknowledgment (results via EventChannel)");
        result(@{@"streaming": @YES, @"message": @"Sync started - listen to syncLockKeyStream"});
    } else {
        NSLog(@"[WiseApartmentPlugin] ⚠️ Using NON-STREAMING mode (no active listener)");
        NSLog(@"[WiseApartmentPlugin]   ↳ This means Flutter is NOT listening to EventChannel!");
        NSLog(@"[WiseApartmentPlugin]   ↳ Calling synclockkeys (returns via MethodChannel)...");
        [self.lockManager synclockkeys:params result:result];
    }
}

- (void)handleChangeLockKeyPwd:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleChangeLockKeyPwd called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!params) {
        NSLog(@"[WiseApartmentPlugin] Invalid parameters");
        result(@{@"success": @NO, @"message": @"Invalid parameters"});
        return;
    }
    [self.lockManager changeLockKeyPwd:params result:result];
}

- (void)handleModifyLockKey:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleModifyLockKey called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!params) {
        NSLog(@"[WiseApartmentPlugin] Invalid parameters");
        result(@{@"success": @NO, @"message": @"Invalid parameters"});
        return;
    }
    [self.lockManager modifyLockKey:params result:result];
}

- (void)handleEnableDisableKeyByType:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleEnableDisableKeyByType called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!params) {
        NSLog(@"[WiseApartmentPlugin] Invalid parameters");
        result(@{@"success": @NO, @"message": @"Invalid parameters"});
        return;
    }
    [self.lockManager enableLockKey:params result:result];
}

- (void)handleSyncLockTime:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleSyncLockTime called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : nil;
    if (!params) {
        NSLog(@"[WiseApartmentPlugin] Invalid parameters for syncLockTime");
        result(@NO);
        return;
    }
    
    NSLog(@"[WiseApartmentPlugin] Syncing lock time via BleLockManager");
    [self.lockManager syncLockTime:params result:result];
}

- (void)handleGetSysParam:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleGetSysParam called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : @{};
    NSLog(@"[WiseApartmentPlugin] Getting system parameters via BleLockManager");
    [self.lockManager getSysParam:params result:result];
}

- (void)handleGetSysParamStream:(id)args result:(FlutterResult)result {
    NSLog(@"[WiseApartmentPlugin] handleGetSysParamStream called with args: %@", args);
    NSDictionary *params = [args isKindOfClass:[NSDictionary class]] ? args : @{};

    if (![self.eventEmitter hasActiveListener]) {
        NSLog(@"[WiseApartmentPlugin] No active EventChannel listener for getSysParamStream");
        result(@NO);
        return;
    }

    [self.lockManager getSysParamStream:params eventEmitter:self.eventEmitter];
    // Acknowledge immediately; actual data will be sent via EventChannel
    result(nil);
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

#pragma mark - Prepare Helper

/**
 * Prepare method: ensures device auth is configured before calling SDK methods.
 * Extracts aesKey, authCode, keyGroupId, bleProtocolVersion from args and calls
 * HXBluetoothLockHelper setDeviceAESKey. Returns YES if successful.
 */
- (BOOL)prepare:(NSDictionary *)args {
    return [self wa_configureDeviceForAuth:args];
}

@end
