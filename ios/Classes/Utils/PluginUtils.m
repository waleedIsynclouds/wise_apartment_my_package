#import "PluginUtils.h"

@implementation PluginUtils

+ (NSString *)stringArg:(NSDictionary *)args key:(NSString *)key {
    id v = args[key];
    if ([v isKindOfClass:[NSString class]]) return (NSString *)v;
    if ([v isKindOfClass:[NSNumber class]]) return [(NSNumber *)v stringValue];
    return nil;
}

+ (NSNumber *)numberArg:(NSDictionary *)args key:(NSString *)key {
    id v = args[key];
    if ([v isKindOfClass:[NSNumber class]]) return (NSNumber *)v;
    if ([v isKindOfClass:[NSString class]]) {
        NSInteger n = [(NSString *)v integerValue];
        return @(n);
    }
    return nil;
}

+ (NSString *)lockMacFromArgs:(NSDictionary *)args {
    NSString *mac = [self stringArg:args key:@"mac"];
    if (mac.length == 0) return nil;
    return [mac lowercaseString];
}

+ (int)intFromArgs:(NSDictionary *)args key:(NSString *)key defaultValue:(int)defaultValue {
    NSNumber *n = [self numberArg:args key:key];
    if (!n) return defaultValue;
    return (int)[n integerValue];
}

@end
