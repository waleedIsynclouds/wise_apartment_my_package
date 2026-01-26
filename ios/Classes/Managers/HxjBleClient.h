#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HxjBleClient : NSObject

@property (nonatomic, copy, nullable) NSString *lastConnectedMac;

- (void)disConnectBle:(nullable void (^)(void))callback;

@end

NS_ASSUME_NONNULL_END
