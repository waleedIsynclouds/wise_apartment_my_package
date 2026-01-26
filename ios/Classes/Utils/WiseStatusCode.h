#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WiseStatusCode : NSObject

+ (NSString *)description:(int)code;
+ (NSDictionary *)toMap:(int)code;
+ (BOOL)isSuccess:(int)code;

@end

NS_ASSUME_NONNULL_END
