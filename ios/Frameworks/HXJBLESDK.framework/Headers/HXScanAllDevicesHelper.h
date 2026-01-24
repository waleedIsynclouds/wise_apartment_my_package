//
//  HXScanAllDevicesHelper.h
//  JQBluetooth
//
//  Created by JQ on 2017/12/13.
//  Copyright © 2017年 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHAdvertisementModel.h"
#import "JQBLEDefines.h"

@protocol HXScanAllDevicesHelperDelegate;

@interface HXScanAllDevicesHelper : NSObject


/// After calling the startScanForDevices method, before manually calling stopScan, monitor whether to turn on the Bluetooth of the mobile phone, whether to automatically scan, the default is YES
/// 调用startScanForDevices方法后，在未手动调用stopScan前，监听到开启手机蓝牙，是否自动扫描，默认为YES
@property (nonatomic, assign) BOOL bleStatePoweredOnAutoScan;

/// Call startScanForDevices method to clear the previously searched peripherals, the default is YES
/// 调用startScanForDevices方法是否清空之前搜索到的外设，默认为YES
@property (nonatomic, assign) BOOL startClearOldData;

///Initialization method
///初始化方法
- (instancetype)initWithDelegate:(id<HXScanAllDevicesHelperDelegate>)delegate;

/// Start scanning the Bluetooth lock
/// 开始扫描蓝牙锁
- (void)startScanForDevices;

/// Stop scanning Bluetooth lock
/// 停止扫描蓝牙锁
- (void)stopScan;


#pragma mark -扫描获取外设信号 Scan for peripheral signals
///en:
/// Scan for peripheral signals
/// @param lockMac Bluetooth lock Mac address
/// @param block Result callback
///        rssi: signal value (unit: dBm)

///cn:
/// 扫描获取外设信号
/// @param lockMac 蓝牙锁Mac
/// @param block 结果回调
///        rssi：信号值（单位：dBm）
+ (void)getBLERSSIWithLockMac:(NSString *)lockMac
              completionBlock:(void(^)(KSHStatusCode statusCode, NSString *reason, NSNumber *rssi))block;

@end



@protocol HXScanAllDevicesHelperDelegate <NSObject>

#pragma mark - 扫描到蓝牙锁时回调 Call back when the Bluetooth lock is scanned
///en:
/// Call back when the Bluetooth lock is scanned (Will call back multiple times)
/// @param advertisements Broadcast data object of discovered devices

///cn:
/// 发现蓝牙锁回调（会回调多次）
/// @param advertisements 已发现设备的广播数据
- (void)didDiscoverDeviceAdvertisement:(NSArray<SHAdvertisementModel *> *)advertisements;


#pragma mark - 失败回调 Failure callback
///en:
/// Failure callback
/// (Note: This callback will also be triggered when the mobile phone has not turned on Bluetooth. Before stopScan is called, the user will automatically continue to discover the device after turning on the mobile phone's Bluetooth)

///cn:
/// 失败回调
/// （注意：手机未打开蓝牙的情况下也会触发该回调，在未调用stopScan前，用户打开手机蓝牙后会自动继续发现设备）
- (void)didFailToScanDevices:(KSHStatusCode)statusCode reason:(NSString *)reason;

@end
