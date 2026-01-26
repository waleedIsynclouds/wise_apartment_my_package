#import "BleScanManager.h"

#import <HXJBLESDK/HXScanAllDevicesHelper.h>
#import <HXJBLESDK/SHAdvertisementModel.h>

#import "OneShotResult.h"

@interface BleScanManager () <HXScanAllDevicesHelperDelegate>

@property (nonatomic, strong) HXScanAllDevicesHelper *scanHelper;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDictionary *> *uniqueDevices;
@property (nonatomic, strong) NSMutableDictionary<NSString *, SHAdvertisementModel *> *advertisementsByMac;
@property (nonatomic, assign) BOOL scanning;

@end

@implementation BleScanManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _uniqueDevices = [NSMutableDictionary dictionary];
        _advertisementsByMac = [NSMutableDictionary dictionary];
        _scanHelper = [[HXScanAllDevicesHelper alloc] initWithDelegate:self];
        _scanHelper.startClearOldData = YES;
        _scanHelper.bleStatePoweredOnAutoScan = YES;
        _scanning = NO;
    }
    return self;
}

- (void)startScan:(NSNumber *)timeoutMs result:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];

    NSInteger timeout = timeoutMs != nil ? [timeoutMs integerValue] : 10000;
    if (timeout <= 0) timeout = 10000;

    [self.uniqueDevices removeAllObjects];
    [self.advertisementsByMac removeAllObjects];

    self.scanning = YES;
    [self.scanHelper startScanForDevices];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self.scanHelper stopScan];
        self.scanning = NO;

        NSArray *finalResults = [self.uniqueDevices allValues];
        [one success:finalResults];
    });
}

- (void)stopScan:(FlutterResult)result {
    [self stopScan];
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];
    [one success:@YES];
}

- (void)stopScan {
    if (!self.scanning) {
        [self.scanHelper stopScan];
        return;
    }
    [self.scanHelper stopScan];
    self.scanning = NO;
}

- (SHAdvertisementModel *)advertisementForMac:(NSString *)mac {
    if (mac.length == 0) return nil;
    NSString *key = [[mac lowercaseString] copy];
    return self.advertisementsByMac[key];
}

#pragma mark - HXScanAllDevicesHelperDelegate

- (void)didDiscoverDeviceAdvertisement:(NSArray<SHAdvertisementModel *> *)advertisements {
    for (SHAdvertisementModel *ad in advertisements) {
        NSString *mac = ad.mac ?: @"";
        if (mac.length == 0) continue;
        NSString *key = [mac lowercaseString];
        self.advertisementsByMac[key] = ad;

        NSMutableDictionary *d = [NSMutableDictionary dictionary];
        d[@"mac"] = key;
        d[@"address"] = key;
        d[@"name"] = ad.name ?: @"";
        if (ad.RSSI != nil) d[@"rssi"] = ad.RSSI;
        d[@"chipType"] = @(ad.chipType);
        d[@"lockType"] = @(ad.lockType);
        d[@"isPaired"] = @(ad.isPairedFlag);
        d[@"isDiscoverable"] = @(ad.discoverableFlag);
        d[@"isNewProtocol"] = @(ad.modernProtocol);

        self.uniqueDevices[key] = d;
    }
}

- (void)didFailToScanDevices:(KSHStatusCode)statusCode reason:(NSString *)reason {
    // Android side only logs scan failures; it still returns whatever it found at timeout.
    (void)statusCode;
    (void)reason;
}

@end
