#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@class BleScanManager;
@class HxjBleClient;
@class WAEventEmitter;

NS_ASSUME_NONNULL_BEGIN

@interface BleLockManager : NSObject

- (instancetype)initWithBleClient:(HxjBleClient *)bleClient scanManager:(BleScanManager *)scanManager;

- (void)openLock:(NSDictionary *)args result:(FlutterResult)result;
- (void)closeLock:(NSDictionary *)args result:(FlutterResult)result;
- (void)setKeyExpirationAlarmTime:(NSDictionary *)args result:(FlutterResult)result;
- (void)deleteLock:(NSDictionary *)args result:(FlutterResult)result;
- (void)changeLockKeyPwd:(NSDictionary *)args result:(FlutterResult)result;
- (void)modifyLockKey:(NSDictionary *)args result:(FlutterResult)result;
- (void)enableLockKey:(NSDictionary *)args result:(FlutterResult)result;
- (void)getDna:(NSDictionary *)args result:(FlutterResult)result;
- (void)addDevice:(NSDictionary *)args result:(FlutterResult)result;
- (void)getSysParam:(NSDictionary *)args result:(FlutterResult)result;
- (void)getSysParamStream:(NSDictionary *)args eventEmitter:(WAEventEmitter *)eventEmitter;
- (void)synclockkeys:(NSDictionary *)args result:(FlutterResult)result;
- (void)syncLockKeyStream:(NSDictionary *)args eventEmitter:(WAEventEmitter *)eventEmitter;
- (void)addLockKeyStream:(NSDictionary *)args eventEmitter:(WAEventEmitter *)eventEmitter;
// Start a WiFi registration and stream incremental events via the provided eventEmitter.
- (void)registerWifiStream:(NSDictionary *)args eventEmitter:(WAEventEmitter *)eventEmitter;
- (void)syncLockTime:(NSDictionary *)args result:(FlutterResult)result;
- (void)exitCmd:(NSDictionary *)args result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
