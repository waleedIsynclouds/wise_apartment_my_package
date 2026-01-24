//
//  SHBluetoothCat1InfoHelper.h
//  SmartHomeSDK
//
//  Created by JQ on 2023/9/22.
//  Copyright © 2023 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JQBLEDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXBluetoothCat1InfoHelper : NSObject

/// 获取Cat.1模组注册相关信息（该接口获取的参数将用于向服务器注册Cat.1模组）
/// @param lockMac 门锁Mac
/// @param block 结果回调，
/// ICCID: 集成电路卡识别码即SIM卡卡号
/// IMEI：IMEI号；
/// IMSI: 表示物联网卡号；
/// RSSI：表示当前信号质量；
/// RSRP: 信号接收功率;
/// SINR: 信号与干扰+噪声比
- (void)getCat1RegistInfoWithLockMac:(NSString *)lockMac
                     completionBlock:(nullable void(^)(KSHStatusCode statusCode, NSString *reason, NSString *ICCID, NSString *IMEI, NSString *IMSI, NSString *RSSI, NSString *RSRP, NSString *SINR))block;

@end

NS_ASSUME_NONNULL_END
