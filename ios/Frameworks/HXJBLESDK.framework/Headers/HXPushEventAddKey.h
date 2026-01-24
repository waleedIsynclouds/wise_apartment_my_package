//
//  HXPushEventAddKey.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/24.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import "HXPushEventBase.h"

/**
en:
 Add key event report (KSHEventType_AddUser)
 */
/**
cn:
 添加钥匙事件上报(KSHEventType_AddUser)
 */
@interface HXPushEventAddKey : HXPushEventBase


/**
en:
 Event related flag eventFlag
 0: Indicates common key addition event
 1: Represents the algorithm password key addition event
 */
/**
cn:
 事件相关标志eventFlag
 0：表示普通钥匙添加事件
 1：表示算法密码钥匙添加事件
 */


/**
en:
 Operator's user ID
 */
/**
cn:
 操作人的用户Id
 */
@property (nonatomic, assign) int operKeyGroupId;

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
 Effective start timestamp
 Permanent authorization: validStartTime = 0x00000000
 */
/**
cn:
 有效起始时间戳
 永久授权：validStartTime = 0x00000000
 */
@property (nonatomic, assign) long validStartTime;

/**
en:
 Effective end timestamp
 Permanent authorization: validEndTime = 0xFFFFFFFF
 */
/**
cn:
 有效结束时间戳
 永久授权：validEndTime = 0xFFFFFFFF
 */
@property (nonatomic, assign) long validEndTime;

/**
en:
 authMode == 2 This parameter is valid,
 Week
 According to the bit field bit0~bit6 respectively, the corresponding bit number is set to 1, which means the key is valid on the day.
 */
/**
cn:
 authMode == 2该参数有效，
 星期
 按位域bit0~bit6分别表示，对应bit位数置1，则表示当天钥匙有效。
 */
@property (nonatomic, assign) kSHWeek weeks;

/**
en:
 authMode = 2 This parameter is valid
 Daily start time
 Value range: 00:00~23:59
 Unit: minutes
 */
/**
cn:
 authMode = 2该参数有效
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
 User Id to which the key belongs
 (Note: The key is added to the key group, and a user can add multiple keys, which corresponds to multiple lockKeyIds)
 Value range: 900~4095
 */
/**
cn:
 钥匙所属用户Id
 （说明：钥匙新增到该钥匙组中，一个用户可以添加多把钥匙，即对应多个lockKeyId）
 取值范围：900~4095
 */
@property (nonatomic, assign) int addedKeyGroupId;

/**
en:
 Key Id, the unique Id of the key saved in the door lock
 */
/**
cn:
 钥匙Id，保存在门锁中的钥匙唯一Id
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
 eventFlag == 1 This parameter is valid
 Added password
 Password: 6-12 digits, only 0-9 digits can be set
 */
/**
cn:
 当keyType == KSHKeyType_Password时，表示密码，6~12位的十进制密码值
 当keyType == KSHKeyType_Card 时，表示卡号，8 ~ 22位的16进制大写字符串
 */
@property (nonatomic, copy) NSString *key;

- (NSDictionary *)dicFromObject;

@end

