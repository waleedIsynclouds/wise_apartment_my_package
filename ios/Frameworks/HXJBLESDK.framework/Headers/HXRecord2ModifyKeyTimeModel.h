//
//  HXRecord2ModifyKeyTimeModel.h
//  HXJBLESDK
//
//  Created by JQ on 2022/3/28.
//  Copyright © 2022 JQ. All rights reserved.
//

#import "HXRecord2BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 修改钥匙有效期记录
 */
@interface HXRecord2ModifyKeyTimeModel : HXRecord2BaseModel

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
 1: Modify according to lockKeyId
 2: Modify according to keyGroupId (one keyGroupId corresponds to one user)
 */
/**
cn:
 1：按照lockKeyId修改
 2：按照keyGroupId修改（一个keyGroupId对应一个用户）
 */
@property (nonatomic, assign) int changeMode;

/**
en:
 changeMode = 1
 it means lockKeyId here; the value range is: 11 to 899
 */
/**
cn:
 changeMode = 1有效
 待操作的钥匙Id，取值范围为：11 ～ 899
 */
@property (nonatomic, assign) int lockKeyId;

/**
en:
 changeMode = 2,
 it means keyGroupId here; the value range is: 900 to 4095
 */
/**
cn:
 changeMode = 2有效，
 待操作的用户Id，取值范围为：900 ～ 4095
 */
@property (nonatomic, assign) int keyGroupId;

/**
en:
 Required
 1: Valid time period authorization
 2: Cycle time period authorization
 */
/**
cn:
 必填
 1：有效时间段授权
 2：周期时间段授权
 */
@property (nonatomic, assign) int authMode;

/**
en:
 Required
 indicating the initial validity period of the key (time stamp)
 (If permanent authorization is set: validStartTime = 0x00000000;)
 Unit: second
 */
/**
cn:
 Required
 表示钥匙的起始有效期（时间戳）
 （如果设置永久授权：validStartTime = 0x00000000;）
 单位：秒
 */
@property (nonatomic, assign) long validStartTime;

/**
en:
 Required
 indicating the end of the key's validity period (time stamp)
 (If permanent authorization is set: validEndTime = 0xFFFFFFFF;)
 Unit: second
 */
/**
cn:
 必填
  表示钥匙的结束有效期（时间戳）
 （如果设置永久授权：validEndTime = 0xFFFFFFFF;）
 单位：秒
 */
@property (nonatomic, assign) long validEndTime;

/**
en:
 Optional
 authMode==2 This parameter is valid, indicating the period
 Valid from Monday to Sunday can be set as: weeks = kSHWeek_monday|kSHWeek_Tuesday|kSHWeek_wednesday|kSHWeek_thursday|kSHWeek_friday|kSHWeek_saturday|kSHWeek_sunday
 */
/**
cn:
 可选
 authMode==2该参数有效，表示周期
 周一~周日有效可设置为：weeks = kSHWeek_monday|kSHWeek_Tuesday|kSHWeek_wednesday|kSHWeek_thursday|kSHWeek_friday|kSHWeek_saturday|kSHWeek_sunday
 */
@property (nonatomic, assign) kSHWeek weeks;

/**
en:
 Optional
 authMode==2 This parameter is valid, indicating the starting time of the day,
 Range: 00:00~23:59.
 Unit: minutes
 */
/**
cn:
 可选
 authMode==2该参数有效，表示每日起始时间，
 范围：00:00~23:59。
 单位：分钟
 */
@property (nonatomic, assign) int dayStartTimes;

/**
en:
 Optional
 authMode==2 This parameter is valid, indicating the end time of the day, the end must be greater than the start time
 Range: 00:00~23:59.
 Unit: minutes
 */
/**
cn:
 可选
 authMode==2该参数有效，表示每日结束时间，结束一定要大于起始时间
 范围：00:00~23:59。
 单位：分钟
 */
@property (nonatomic, assign) int dayEndTimes;

/**
en:
 Required
 0: The effective use times of the key are not modified
 1 ~ 254: Customize the effective use times
 255: Unlimited times
 */
/**
cn:
 必填
 0：钥匙有效使用次数不修改
 1 ～ 254：自定义有效使用次数
 255：无限次
 */
@property (nonatomic, assign) int vaildNumber;

@end

NS_ASSUME_NONNULL_END
