#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@class BleScanManager;
@class HxjBleClient;

NS_ASSUME_NONNULL_BEGIN

/**
 * Callback protocol for streaming syncLockKey events.
 * Allows incremental updates to be sent to Flutter via EventChannel.
 */
@protocol SyncLockKeyStreamDelegate <NSObject>
- (void)onChunk:(NSDictionary *)chunkEvent;
- (void)onDone:(NSDictionary *)doneEvent;
- (void)onError:(NSDictionary *)errorEvent;
@end

@interface BleLockManager : NSObject

- (instancetype)initWithBleClient:(HxjBleClient *)bleClient scanManager:(BleScanManager *)scanManager;

- (void)openLock:(NSDictionary *)args result:(FlutterResult)result;
- (void)closeLock:(NSDictionary *)args result:(FlutterResult)result;
- (void)setKeyExpirationAlarmTime:(NSDictionary *)args result:(FlutterResult)result;
- (void)deleteLock:(NSDictionary *)args result:(FlutterResult)result;
- (void)getDna:(NSDictionary *)args result:(FlutterResult)result;
- (void)addDevice:(NSDictionary *)args result:(FlutterResult)result;
- (void)getSysParam:(NSDictionary *)args result:(FlutterResult)result;
- (void)synclockkeys:(NSDictionary *)args result:(FlutterResult)result;
- (void)syncLockKeyStream:(NSDictionary *)args delegate:(id<SyncLockKeyStreamDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
