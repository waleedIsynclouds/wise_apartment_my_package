//
//  WAScanManager.h
//  wise_apartment
//
//  Manages BLE device scanning and discovery
//

#import <Foundation/Foundation.h>

@class SHAdvertisementModel;

@class WAEventEmitter;

NS_ASSUME_NONNULL_BEGIN

@interface WAScanManager : NSObject

- (instancetype)initWithEventEmitter:(WAEventEmitter *)eventEmitter;

/**
 * Start BLE scanning for smart lock devices
 * @param timeout Scan timeout in seconds (0 = no timeout)
 * @param allowDuplicates Whether to report duplicate discoveries
 * @param error Output error if scan fails to start
 * @return YES if scan started successfully
 */
- (BOOL)startScanWithTimeout:(NSTimeInterval)timeout
             allowDuplicates:(BOOL)allowDuplicates
                       error:(NSError **)error;

/**
 * Stop ongoing scan
 */
- (void)stopScan;

/**
 * Check if scan is currently running
 */
- (BOOL)isScanning;

/// Snapshot of discovered devices, formatted for Flutter.
- (NSArray<NSDictionary *> *)snapshotDiscoveredDevices;

/// Returns the last seen advertisement for a lock MAC (lower/upper tolerated).
- (nullable SHAdvertisementModel *)advertisementForMac:(NSString *)mac;

@end

NS_ASSUME_NONNULL_END
