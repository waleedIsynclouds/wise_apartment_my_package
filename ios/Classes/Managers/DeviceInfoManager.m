#import "DeviceInfoManager.h"

#import <UIKit/UIKit.h>

#import <HXJBLESDK/HXBluetoothNBInfoHelper.h>
#import <HXJBLESDK/HXBluetoothCat1InfoHelper.h>
#import <HXJBLESDK/HXBluetoothLockHelper.h>

#import "OneShotResult.h"
#import "PluginUtils.h"

@implementation DeviceInfoManager

- (void)getDeviceInfo:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];

    UIDevice *device = [UIDevice currentDevice];
    NSString *systemVersion = device.systemVersion ?: @"";
    int sdkInt = 0;
    NSArray<NSString *> *parts = [systemVersion componentsSeparatedByString:@"."];
    if (parts.count > 0) {
        sdkInt = (int)[parts[0] integerValue];
    }

    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier] ?: @"";

    NSDictionary *info = @{
        @"manufacturer": @"Apple",
        @"model": device.model ?: @"",
        @"brand": @"Apple",
        @"sdkInt": @(sdkInt),
        @"release": systemVersion,
        @"packageName": bundleId,
    };

    [one success:info];
}

- (void)getAndroidBuildConfig:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];

    NSBundle *bundle = [NSBundle mainBundle];
    NSString *bundleId = [bundle bundleIdentifier] ?: @"";
    NSString *versionName = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"";
    NSString *build = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"] ?: @"";

    NSInteger versionCodeInt = -1;
    if (build.length > 0) {
        versionCodeInt = [build integerValue];
    }

    NSString *systemVersion = [UIDevice currentDevice].systemVersion ?: @"";
    int targetSdk = 0;
    NSArray<NSString *> *parts = [systemVersion componentsSeparatedByString:@"."];
    if (parts.count > 0) targetSdk = (int)[parts[0] integerValue];

    NSDictionary *config = @{
        @"applicationId": bundleId,
        @"namespace": bundleId,
        @"versionName": versionName,
        @"versionCode": @(versionCodeInt),
        @"targetSdk": @(targetSdk),
        @"minSdk": @(-1),
        @"compileSdk": @(-1),
    };

    [one success:config];
}

- (void)getNBIoTInfo:(NSDictionary *)args result:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];

    NSString *mac = [PluginUtils lockMacFromArgs:args];
    if (mac.length == 0) {
        [one error:@"ERROR" message:@"mac is required" details:nil];
        return;
    }

    HXBluetoothNBInfoHelper *helper = [[HXBluetoothNBInfoHelper alloc] init];
    [helper getNBRegistInfoWithLockMac:mac completionBlock:^(KSHStatusCode statusCode, NSString *reason, NSString *cardID, NSString *IMEI, NSString *csq) {
        if (statusCode == KSHStatusCode_Success) {
            NSInteger rssi = 0;
            if (csq.length > 0) {
                rssi = [csq integerValue];
            }
            NSDictionary *res = @{
                @"rssi": @(rssi),
                @"imsi": cardID ?: @"",
                @"imei": IMEI ?: @"",
            };
            [one success:res];
        } else {
            [one error:@"ERROR" message:(reason ?: @"ERROR") details:nil];
        }
    }];
}

- (void)getCat1Info:(NSDictionary *)args result:(FlutterResult)result {
    OneShotResult *one = [[OneShotResult alloc] initWithResult:result];

    NSString *mac = [PluginUtils lockMacFromArgs:args];
    if (mac.length == 0) {
        [one error:@"ERROR" message:@"mac is required" details:nil];
        return;
    }

    HXBluetoothCat1InfoHelper *helper = [[HXBluetoothCat1InfoHelper alloc] init];
    [helper getCat1RegistInfoWithLockMac:mac completionBlock:^(KSHStatusCode statusCode, NSString *reason, NSString *ICCID, NSString *IMEI, NSString *IMSI, NSString *RSSI, NSString *RSRP, NSString *SINR) {
        if (statusCode == KSHStatusCode_Success) {
            NSDictionary *res = @{
                @"iccid": ICCID ?: @"",
                @"imei": IMEI ?: @"",
                @"imsi": IMSI ?: @"",
                @"rssi": RSSI ?: @"",
                @"rsrp": RSRP ?: @"",
                @"sinr": SINR ?: @"",
            };
            [one success:res];
        } else {
            [one error:@"ERROR" message:(reason ?: @"ERROR") details:nil];
        }
    }];
}

@end
