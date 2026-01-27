//
//  WAScanManager.m
//  wise_apartment
//
//  BLE scanning implementation
// Change log statements to use your preferred logging framework
//

#import "WAScanManager.h"
#import "WAEventEmitter.h"
#import "WAErrorHandler.h"

#import <HXJBLESDK/HXScanAllDevicesHelper.h>
#import <HXJBLESDK/SHAdvertisementModel.h>

static NSString *const kWAUnknownDeviceName = @"Unknown Device";

@interface WAScanManager () <HXScanAllDevicesHelperDelegate>

@property (nonatomic, weak) WAEventEmitter *eventEmitter;
@property (nonatomic, strong) NSTimer *scanTimeoutTimer;
@property (nonatomic, assign) BOOL isCurrentlyScanning;
@property (nonatomic, assign) BOOL allowDuplicates;
@property (nonatomic, strong) NSMutableDictionary<NSString *, SHAdvertisementModel *> *discoveredAdvertisements;

@property (nonatomic, strong) HXScanAllDevicesHelper *scanHelper;

@end

@implementation WAScanManager

- (instancetype)initWithEventEmitter:(WAEventEmitter *)eventEmitter {
    NSLog(@"[WAScanManager] Initializing scan manager");
    self = [super init];
    if (self) {
        _eventEmitter = eventEmitter;
        _discoveredAdvertisements = [NSMutableDictionary dictionary];
        _scanHelper = [[HXScanAllDevicesHelper alloc] initWithDelegate:self];
        _scanHelper.bleStatePoweredOnAutoScan = YES;
        _scanHelper.startClearOldData = YES;
        NSLog(@"[WAScanManager] Scan manager initialized successfully");
    }
    return self;
}

- (void)dealloc {
    [self stopScan];
}

#pragma mark - Public Methods

- (BOOL)startScanWithTimeout:(NSTimeInterval)timeout
             allowDuplicates:(BOOL)allowDuplicates
                       error:(NSError **)error {
    NSLog(@"[WAScanManager] startScan called - timeout: %.1fs, allowDuplicates: %d", timeout, allowDuplicates);
    
    if (self.isCurrentlyScanning) {
        NSLog(@"[WAScanManager] Scan already in progress");
        if (error) {
            *error = [WAErrorHandler errorWithCode:WAErrorCodeScanAlreadyRunning
                                           message:nil];
        }
        return NO;
    }
    
    self.allowDuplicates = allowDuplicates;
    [self.discoveredAdvertisements removeAllObjects];

    self.scanHelper.startClearOldData = YES;
    [self.scanHelper startScanForDevices];
    NSLog(@"[WAScanManager] HXJBLESDK scan started");
    
    self.isCurrentlyScanning = YES;
    
    // Emit scan started event
    [self.eventEmitter emitEvent:@{
        @"type": @"scanState",
        @"state": @"started"
    }];
    NSLog(@"[WAScanManager] Scan state event emitted: started");
    
    // Setup timeout if specified
    if (timeout > 0) {
        NSLog(@"[WAScanManager] Setting scan timeout timer for %.1fs", timeout);
        __weak typeof(self) weakSelf = self;
        self.scanTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeout
                                                                repeats:NO
                                                                  block:^(NSTimer *timer) {
            NSLog(@"[WAScanManager] Scan timeout reached");
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf stopScan];
        }];
    }
    
    NSLog(@"[WAScanManager] Scan started successfully");
    return YES;
}

- (void)stopScan {
    NSLog(@"[WAScanManager] stopScan called");
    if (!self.isCurrentlyScanning) {
        NSLog(@"[WAScanManager] No scan in progress, nothing to stop");
        return;
    }

    [self.scanHelper stopScan];
    NSLog(@"[WAScanManager] HXJBLESDK scan stopped");
    
    [self.scanTimeoutTimer invalidate];
    self.scanTimeoutTimer = nil;
    self.isCurrentlyScanning = NO;
    
    [self.eventEmitter emitEvent:@{
        @"type": @"scanState",
        @"state": @"stopped"
    }];
    NSLog(@"[WAScanManager] Scan stopped, event emitted");
}

- (BOOL)isScanning {
    return self.isCurrentlyScanning;
}

- (NSArray<NSDictionary *> *)snapshotDiscoveredDevices {
    NSMutableArray<NSDictionary *> *out = [NSMutableArray arrayWithCapacity:self.discoveredAdvertisements.count];
    for (NSString *mac in self.discoveredAdvertisements) {
        SHAdvertisementModel *ad = self.discoveredAdvertisements[mac];
        if (!ad) continue;
        NSString *name = (ad.name.length > 0) ? ad.name : kWAUnknownDeviceName;
        NSNumber *rssi = ad.RSSI ?: @0;
        [out addObject:@{
            @"deviceId": mac,
            @"mac": mac,
            @"name": name,
            @"rssi": rssi,
            @"chipType": @(ad.chipType),
            @"lockType": @(ad.lockType),
            @"advertisementData": @{},
        }];
    }
    return out;
}

- (nullable SHAdvertisementModel *)advertisementForMac:(NSString *)mac {
    if (mac.length == 0) return nil;
    NSString *key = [mac lowercaseString];
    return self.discoveredAdvertisements[key];
}


#pragma mark - HXScanAllDevicesHelperDelegate

- (void)didDiscoverDeviceAdvertisement:(NSArray<SHAdvertisementModel *> *)advertisements {
    for (SHAdvertisementModel *ad in advertisements) {
        NSString *mac = (ad.mac.length > 0) ? [ad.mac lowercaseString] : nil;
        if (mac.length == 0) continue;

        if (!self.allowDuplicates && self.discoveredAdvertisements[mac] != nil) {
            continue;
        }

        self.discoveredAdvertisements[mac] = ad;
        NSString *name = (ad.name.length > 0) ? ad.name : kWAUnknownDeviceName;
        NSNumber *rssi = ad.RSSI ?: @0;

        NSDictionary *devicePayload = @{
            @"deviceId": mac,
            @"mac": mac,
            @"name": name,
            @"rssi": rssi,
            @"chipType": @(ad.chipType),
            @"lockType": @(ad.lockType),
            @"advertisementData": @{},
        };

        [self.eventEmitter emitEvent:@{
            @"type": @"scanResult",
            @"device": devicePayload
        }];
    }
}

- (void)didFailToScanDevices:(KSHStatusCode)statusCode reason:(NSString *)reason {
    NSLog(@"[WAScanManager] HXJBLESDK scan failed: %ld %@", (long)statusCode, reason);

    if (statusCode == KSHStatusCode_BluetoothStateUnavailable || statusCode == KSHStatusCode_BluetoothStateDenied) {
        [self.eventEmitter emitEvent:@{
            @"type": @"scanState",
            @"state": @"stopped",
            @"reason": @"bluetooth_unavailable",
        }];
    }

    [self.eventEmitter emitEvent:@{
        @"type": @"scanError",
        @"code": @((NSInteger)statusCode),
        @"message": reason ?: @"Scan failed"
    }];
}

@end
