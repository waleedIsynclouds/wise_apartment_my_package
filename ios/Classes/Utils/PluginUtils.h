#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PluginUtils : NSObject

+ (NSString * _Nullable)stringArg:(NSDictionary *)args key:(NSString *)key;
+ (NSNumber * _Nullable)numberArg:(NSDictionary *)args key:(NSString *)key;

+ (NSString * _Nullable)lockMacFromArgs:(NSDictionary *)args;
+ (int)intFromArgs:(NSDictionary *)args key:(NSString *)key defaultValue:(int)defaultValue;

@end

NS_ASSUME_NONNULL_END
