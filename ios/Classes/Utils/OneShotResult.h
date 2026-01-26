#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface OneShotResult : NSObject

- (instancetype)initWithResult:(FlutterResult)result;

- (void)success:(id _Nullable)value;
- (void)error:(NSString *)code message:(NSString *)message details:(id _Nullable)details;

@end

NS_ASSUME_NONNULL_END
