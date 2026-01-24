//
//  HXBluetoothNBInfoHelper.h
//  HXJBLESDK
//
//  Created by JQ on 2020/8/5.
//  Copyright © 2020 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JQBLEDefines.h"

NS_ASSUME_NONNULL_BEGIN

/// 该类获取NBIoT模组信息 This class obtains NBIoT module information
@interface HXBluetoothNBInfoHelper : NSObject

/**
 注：调用HXBluetoothNBInfoHelper的接口前确保已经调用过如下接口
 Note: Before calling HXBluetoothNBInfoHelper class interface, make sure that the following interface has been called

 + (void)setDeviceAESKey:(NSString *)aesKey
           authCode:(NSString *)authCode
         keyGroupId:(int)keyGroupId
 bleProtocolVersion:(int)bleProtocolVersion
            lockMac:(NSString *)lockMac
 */

#pragma mark -获取NBIoT模组注册相关信息 Obtain NBIoT module registration related information
///en:
/// Obtain NBIoT module registration related information (the parameters obtained by this interface will be used to register the NB module with the server)
/// @param lockMac Bluetooth lock Mac address
/// @param block Result callback, cardID: indicates the card number of the Internet of Things; IMEI: indicates the IMEI number; csq: indicates the current signal quality;

///cn:
/// 获取NBIoT模组注册相关信息（该接口获取的参数将用于向服务器注册NB模组）
/// @param lockMac 门锁Mac
/// @param block 结果回调，cardID：表示物联网卡号；IMEI：表示IMEI号；csq：表示当前信号质量；
- (void)getNBRegistInfoWithLockMac:(NSString *)lockMac
                   completionBlock:(nullable void(^)(KSHStatusCode statusCode, NSString *reason, NSString *cardID, NSString *IMEI, NSString *csq))block;

@end

NS_ASSUME_NONNULL_END
