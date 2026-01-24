//
//  HXAddBluetoothLockHelper.h
//  SmartHomeSDK
//
//  Created by JQ on 2017/12/29.
//  Copyright © 2017年 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JQBLEDefines.h"
#import "SHAdvertisementModel.h"
#import "HXBLEDevice.h"
#import "HXBLEDeviceStatus.h"

@interface HXAddBluetoothLockHelper : NSObject

#pragma mark -添加蓝牙锁 Add Bluetooth lock
///en:
/// Add Bluetooth lock
/// @param advertisementModel Bluetooth broadcast data object (can be obtained by scanning peripherals)
/// @param block Result callback
///        statusCode：status code
///        reason: Status code description
///        device: Device Information
///        deviceStatus: Device status information

///cn:
/// 添加蓝牙锁
/// @param advertisementModel 蓝牙广播数据对象(可通过扫描外设获取)
/// @param block 结果回调
///        statusCode：状态码
///        reason：状态码说明
///        device：设备信息
///        deviceStatus：设备状态信息
- (void)startAddDeviceWithAdvertisementModel:(SHAdvertisementModel *)advertisementModel
                             completionBlock:(void(^)(KSHStatusCode statusCode, NSString *reason, HXBLEDevice *device, HXBLEDeviceStatus *deviceStatus))block;


#pragma mark -取消添加蓝牙锁 Cancel adding Bluetooth lock
///en:
/// Cancel adding Bluetooth lock

///cn:
/// 取消添加蓝牙锁 Cancel adding Bluetooth lock
- (void)cancelAddDevice;

@end
