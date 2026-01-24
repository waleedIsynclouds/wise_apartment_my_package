//
//  HXBLEAddKeyBaseParams.h
//  SmartHomeSDK
//
//  Created by JQ on 2019/4/4.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JQBLEDefines.h"

@interface HXBLEAddKeyBaseParams : NSObject

/** Required, the mac of the Bluetooth lock, used to judge when sending a command to the specified device */
/** 必填，蓝牙锁的mac，用于发送命令时判断发送给指定的设备 */
@property (nonatomic, copy) NSString *lockMac;

/**
en:
 Required
 User Id (ie key group Id)
 (Note: The key is added to the key group, and a user can add multiple keys, which corresponds to multiple lockKeyIds)
 The keyGroupId is allocated by its own server to ensure that the keyGroupId of the user in a lock does not conflict
 Value range: 900~4095
 */
/**
cn:
 必填
 用户Id（即钥匙组Id）
 （说明：钥匙新增到该钥匙组中，一个用户可以添加多把钥匙，即对应多个lockKeyId）
 由自己的服务器分配keyGroupId，确保一把锁中用户的keyGroupId不冲突
 取值范围：900~4095
 */
@property (nonatomic, assign) int keyGroupId;

/**
en:
 Required
 Enable times
 0: disable
 1~254: effective times
 255: Unlimited number of times
 */
/**
cn:
 必填
 使能次数
 0:禁用
 1~254：有效次数
 255：无限次数
 */
@property (nonatomic, assign) int vaildNumber;

/**
en:
 Required
 Effective start timestamp (seconds)
 Permanent authorization: validStartTime = 0x00000000
 */
/**
cn:
 必填
 有效起始时间戳（秒）
 永久授权：validStartTime = 0x00000000
 */
@property (nonatomic, assign) long validStartTime;

/**
en:
 Required
 Effective end timestamp (seconds)
 Permanent authorization: validEndTime = 0xFFFFFFFF
 */
/**
cn:
 必填
 有效结束时间戳（秒）
 永久授权：validEndTime = 0xFFFFFFFF
 */
@property (nonatomic, assign) long validEndTime;

/**
en:
 Required
 Validity period authorization method
 1: Validity period authorization
 2: Periodic repetition time period authorization
 */
/**
cn:
 必填
 有效期授权方式
 1：有效期授权
 2：周期重复时间段授权
 */
@property (nonatomic, assign) int authMode;

/**
en:
 Optional,
 This value is valid when authMode == 2
 Week, for example: Monday and Tuesday are expressed as kSHWeek_monday|kSHWeek_tuesday
 */
/**
cn:
 可选，
 authMode == 2时该值有效
 星期，例如：周一和周二表示为 kSHWeek_monday|kSHWeek_tuesday
 */
@property (nonatomic, assign) kSHWeek week;

/**
en:
 Optional,
 This value is valid when authMode == 2
 Daily start time
 Value range: 00:00~23:59
 Unit: minutes
 */
/**
cn:
 可选，
 authMode == 2时该值有效
 每日起始时间
 取值范围：00:00~23:59
 单位：分钟
 */
@property (nonatomic, assign) int dayStartTimes;

/**
en:
 Optional,
 This value is valid when authMode == 2
 Daily end time
 Value range: 00:00~23:59
 Unit: minutes
 */
/**
cn:
 可选，
 authMode == 2时该值有效
 每日结束时间
 取值范围：00:00~23:59
 单位：分钟
 */
@property (nonatomic, assign) int dayEndTimes;

@end
