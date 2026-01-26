#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@class BleScanManager;
@class HxjBleClient;

NS_ASSUME_NONNULL_BEGIN

@interface BleLockManager : NSObject

- (instancetype)initWithBleClient:(HxjBleClient *)bleClient scanManager:(BleScanManager *)scanManager;

- (void)openLock:(NSDictionary *)args result:(FlutterResult)result;
- (void)closeLock:(NSDictionary *)args result:(FlutterResult)result;
- (void)setKeyExpirationAlarmTime:(NSDictionary *)args result:(FlutterResult)result;
- (void)deleteLock:(NSDictionary *)args result:(FlutterResult)result;
- (void)getDna:(NSDictionary *)args result:(FlutterResult)result;
- (void)addDevice:(NSDictionary *)args result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
