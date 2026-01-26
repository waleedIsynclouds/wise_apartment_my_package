#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceInfoManager : NSObject

- (void)getDeviceInfo:(FlutterResult)result;
- (void)getAndroidBuildConfig:(FlutterResult)result;
- (void)getNBIoTInfo:(NSDictionary *)args result:(FlutterResult)result;
- (void)getCat1Info:(NSDictionary *)args result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
