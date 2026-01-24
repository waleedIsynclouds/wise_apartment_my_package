//
//  HXBluetoothNBHelper.h
//  SmartHomeSDK
//
//  Created by JQ on 2019/8/26.
//  Copyright © 2019 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JQBLEDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXBluetoothNBHelper : NSObject

#pragma mark -设置NBIoT模组进入AT指令模式 Set NBIoT module to enter AT command mode
#pragma mark ********************************
///en:
/// Set NBIoT module to enter AT command mode
/// @param timeout Indicates the timeout period, in seconds. 1~254: The Bluetooth lock will automatically exit the AT mode if it does not receive an AT command for more than this time; 255: It means there is no timeout period, and you need to call exitATCmdModeWithLockMac to exit the AT command mode;
/// @param lockMac Bluetooth lock Mac address
/// @param block Result callback

///cn:
/// 让NBIoT模组进入AT指令模式
/// @param timeout 表示超时时间，单位秒。1~254：蓝牙锁超过这个时间没有收到AT指令将自动退出AT模式；255：表示没有超时时间，需要调用exitATCmdModeWithLockMac才会退出AT指令模式；
/// @param lockMac 蓝牙锁Mac
/// @param block 结果回调
+ (void)startATCmdModeWithTimeout:(int)timeout
                          lockMac:(NSString *)lockMac
                  completionBlock:(nullable void(^)(KSHStatusCode statusCode, NSString *reason))block;


#pragma mark -设置NBIoT模组退出AT指令模式 Set NBIoT module to exit AT command mode
#pragma mark ********************************
///en:
/// Set NBIoT module to exit AT command mode
/// (Note: If the timeout in startATCmdModeWithTimeout is set to 255, this interface must be called later to allow NB to exit the AP command mode.)
/// @param lockMac Bluetooth lock Mac address
/// @param block Result callback

///cn:
/// 退出AT指令模式
/// （注意：如果startATCmdModeWithTimeout中的timeout设置为255，则后续必须调用该接口才能让NB退出AP指令模式。）
/// @param lockMac 蓝牙锁Mac
/// @param block 结果回调
+ (void)exitATCmdModeWithLockMac:(NSString *)lockMac
                 completionBlock:(nullable void(^)(KSHStatusCode statusCode, NSString *reason))block;

#pragma mark -发送自定义AT指令 Send custom AT commands
#pragma mark ******************************************
///en:
/// Send custom AT commands
/// (Note: Before calling this interface, if the NBIoT module does not enter the AT command mode, you need to call the startATCmdModeWithTimeout interface successfully before calling this interface)
/// @param ATCmd AT command, please refer to the AT command document provided by the module solution provider for details
/// @param lockMac Bluetooth lock Mac address
/// @param block Result callback. One request may have multiple callbacks. (CurIndex == totoal-1) indicates that there is no more callback when the request is completed, otherwise it indicates that there will be callbacks in the future.

///cn:
/// 发送自定义AT指令
/// （注意：调用该接口前，如果NBIoT模组未进入AT指令模式，需要先调用startATCmdModeWithTimeout接口成功后，再调用该接口）
/// @param ATCmd AT指令，具体请参考模块方案商提供的AT指令文档
/// @param lockMac 蓝牙锁Mac
/// @param block 结果回调，一次请求可能有多次回调。（curIndex == totoal-1）表示请求完成没有更多回调，否则表示后续还有回调。
+ (void)sendCustomATCmd:(NSString *)ATCmd
                lockMac:(NSString *)lockMac
        completionBlock:(nullable void(^)(KSHStatusCode statusCode, NSString *reason, NSString *response, int curIndex, int totoal))block;

#pragma mark -设置NB-IoT模组飞行模式 Set NBIoT Airplane Mode
#pragma mark ******************************************
///en
/// Set NBIoT Airplane Mode
/// @param state Turn on/off airplane mode
/// @param lockMac Bluetooth lock Mac address
/// @param block Result callback

///cn:
/// 设置NB-IoT模组飞行模式
/// @param state 开启/关闭飞行模式
/// @param lockMac 蓝牙锁Mac
/// @param block 结果回调
+ (void)setNBIoTAirplaneMode:(kSHOnOffState)state lockMac:(NSString *)lockMac completionBlock:(nullable void(^)(KSHStatusCode statusCode, NSString *reason))block;

@end

NS_ASSUME_NONNULL_END
