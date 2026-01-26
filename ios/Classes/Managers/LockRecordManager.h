#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@class HxjBleClient;

NS_ASSUME_NONNULL_BEGIN

@interface LockRecordManager : NSObject

- (instancetype)initWithBleClient:(HxjBleClient *)bleClient;

- (void)syncLockRecords:(NSDictionary *)args result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
