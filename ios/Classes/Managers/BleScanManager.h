#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@class SHAdvertisementModel;

NS_ASSUME_NONNULL_BEGIN

@interface BleScanManager : NSObject

- (void)startScan:(NSNumber * _Nullable)timeoutMs result:(FlutterResult)result;
- (void)stopScan:(FlutterResult)result;

- (void)stopScan;

- (nullable SHAdvertisementModel *)advertisementForMac:(NSString *)mac;

@end

NS_ASSUME_NONNULL_END
