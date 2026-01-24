//
//  HXKeyModel.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/24.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JQBLEDefines.h"

/** Key information */
/** 钥匙信息 */
@interface HXKeyModel : NSObject<NSCopying>

/**
en:
 Bluetooth lock MAC
 */
/**
cn:
 蓝牙锁MAC
 */
@property (nonatomic, copy) NSString *lockMac;

/**
en:
 User Id to which the key belongs
 */
/**
cn:
 钥匙所属用户Id
 */
@property (nonatomic, assign) int keyGroupId;

/**
en:
 Key Id
 */
/**
cn:
 钥匙Id
 */
@property (nonatomic, assign) int lockKeyId;

/**
en:
 Key type
 */
/**
cn:
 钥匙类型
 */
@property (nonatomic, assign) KSHKeyType keyType;

/**
en:
 Last update timestamp (seconds)
 */
/**
cn:
 最后更新时间戳（秒）
 */
@property (nonatomic, assign) long updateTime;

/**
en:
 Effective start timestamp (seconds)
 Permanent authorization: ValidStartTime = 0x00000000
 */
/**
cn:
 有效起始时间戳（秒）
 永久授权：ValidStartTime = 0x00000000
 */
@property (nonatomic, assign) long validStartTime;

/**
en:
 Effective end timestamp (seconds)
 Permanent authorization: ValidEndTime = 0xFFFFFFFF
 */
/**
cn:
 有效结束时间戳（秒）
 永久授权：ValidEndTime = 0xFFFFFFFF
 */
@property (nonatomic, assign) long validEndTime;

/**
en:
 Effective use times
 0: disable
 1~254: effective times
 255: Unlimited number of times
 */
/**
cn:
 有效使用次数
 0:禁用
 1~254：有效次数
 255：无限次数
 */
@property (nonatomic, assign) int validNumber;

/**
en:
 Validity period authorization method
 1: Validity period authorization (refer to ValidStartTime/ValidEndTime for timeliness)
 2: Periodic repetition time period authorization (refer to ValidStartTime/ ValidEndTime/ Weeks/ DayStartTimes/ DayEndTimes for timeliness)
 */
/**
cn:
 有效期授权方式
 1：有效期授权（时效性参考ValidStartTime/ ValidEndTime）
 2：周期重复时间段授权（时效性参考ValidStartTime/ ValidEndTime/ Weeks/ DayStartTimes/ DayEndTimes）
 */
@property (nonatomic, assign) int authMode;

/**
en:
 Week
 This value is valid when authMode == 2
 Week, for example: Monday and Tuesday are expressed as kSHWeek_monday|kSHWeek_tuesday
 */
/**
cn:
 星期
 authMode == 2时该值有效
 星期，例如：周一和周二表示为 kSHWeek_monday|kSHWeek_tuesday
 */
@property (nonatomic, assign) kSHWeek weeks;

/**
en:
 This value is valid when authMode == 2
 Daily start time
 Value range: 00:00~23:59
 Unit: minutes
 */
/**
cn:
 authMode == 2时该值有效
 每日起始时间
 取值范围：00:00~23:59
 单位：分钟
 */
@property (nonatomic, assign) int dayStartTimes;

/**
en:
 This value is valid when authMode == 2
 Daily end time
 Value range: 00:00~23:59
 Unit: minutes
 */
/**
cn:
 authMode == 2时该值有效
 每日结束时间
 取值范围：00:00~23:59
 单位：分钟
 */
@property (nonatomic, assign) int dayEndTimes;

/**
en:
 Delete mark
 0: delete
 1: Normal
 */
/**
cn:
 删除标记
 0：删除
 1：正常
 */
@property (nonatomic, assign) int deleteFalg;

/**
en:
 eventFlag == 1 This parameter is valid
 Added password
 Password: 6-12 digits, only 0-9 digits can be set
 */
/**
cn:
 注意：添加钥匙接口不会返回key（key在事件上报中获取），同步钥匙列表部分钥匙会返回该key
 当keyType == KSHKeyType_Password时，表示密码，6~12位的十进制密码值
 当keyType == KSHKeyType_Card 时，表示卡号，8 ~ 22位的16进制大写字符串
 */
@property (nonatomic, copy) NSString *key;


- (NSDictionary *)dicFromObject;

@end

