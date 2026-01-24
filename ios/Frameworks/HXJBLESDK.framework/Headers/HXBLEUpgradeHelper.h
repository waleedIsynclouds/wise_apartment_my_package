//
//  HXBLEUpgradeHelper.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/23.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JQBLEDefines.h"

/**
 蓝牙锁固件升级 Bluetooth lock firmware upgrade
 */
@interface HXBLEUpgradeHelper : NSObject

#pragma mark - 开始蓝牙锁固件升级 Start the Bluetooth lock firmware upgrade
///en:
/// Start the Bluetooth lock firmware upgrade
/// @param lockMac Bluetooth lock Mac address
/// @param localFilePath The .bin/.zip format firmware is stored in the local path name of the App. During the firmware upgrade process, the SDK will obtain the firmware package according to this path
/// @param callback Result callback

///cn:
/// 开始蓝牙锁固件升级
/// @param lockMac 蓝牙锁Mac地址
/// @param localFilePath .bin/.zip 格式的固件存储在App本地的路径名，固件升级过程中SDK将根据该路径获取固件包
/// @param callback 结果回调
+ (void)startUpgradeWithMac:(NSString *)lockMac localFilePath:(NSString *)localFilePath callback:(BLEOTACallbackBlock)callback;


#pragma mark - 取消蓝牙锁固件升级 Cancel the Bluetooth lock firmware upgrade
///en:
/// Cancel the Bluetooth lock firmware upgrade
/// @param lockMac Bluetooth lock Mac address

///cn:
/// 取消蓝牙锁固件升级 Cancel the Bluetooth lock firmware upgrade
/// @param lockMac 蓝牙锁Mac地址 Bluetooth lock Mac address
+ (void)cancelUpgradeWithMac:(NSString *)lockMac;

@end
