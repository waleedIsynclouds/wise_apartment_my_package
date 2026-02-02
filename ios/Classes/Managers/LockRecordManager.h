#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@class HxjBleClient;
@class WAEventEmitter;

NS_ASSUME_NONNULL_BEGIN

@interface LockRecordManager : NSObject

- (instancetype)initWithBleClient:(HxjBleClient *)bleClient eventEmitter:(WAEventEmitter *)eventEmitter;

- (void)syncLockRecords:(NSDictionary *)args result:(FlutterResult)result;

/// Streaming variant: emits events via EventChannel.
///
/// Events emitted:
/// - syncLockRecordsChunk: { type, items (record batch), totalSoFar, isMore }
/// - syncLockRecordsDone: { type, items (all records), total }
/// - syncLockRecordsError: { type, message, code }
- (void)syncLockRecordsStream:(NSDictionary *)args;

@end

NS_ASSUME_NONNULL_END
