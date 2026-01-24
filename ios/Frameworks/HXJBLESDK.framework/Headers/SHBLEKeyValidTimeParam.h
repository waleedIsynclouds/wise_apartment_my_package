//
//  SHBLEKeyValidTimeParam.h
//  HXJBLESDK
//
//  Created by JQ on 2023/8/11.
//  Copyright © 2023 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JQBLEDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface SHBLEKeyValidTimeParam : NSObject

/**
 修改的时间戳，默认为当前时间
 */
@property (nonatomic, assign) long modifyTimestamp;

/**
 1：有效时间段授权
 2：周期时间段授权
 */
@property (nonatomic, assign) int authMode;

/**
 authMode = 1有效，钥匙的起始有效期（时间戳）
 永久授权：ValidStartTime = 0x00000000
 */
@property (nonatomic, assign) long validStartTime;

/**
 authMode = 1有效，钥匙的结束有效期（时间戳）
 永久授权：ValidEndTime = 0xFFFFFFFF
 */
@property (nonatomic, assign) long validEndTime;

/**
 authMode=2该参数有效
 周一~周日有效可设置为：kSHWeek_monday|kSHWeek_Tuesday|kSHWeek_wednesday|kSHWeek_thursday|kSHWeek_friday|kSHWeek_saturday|kSHWeek_sunday
 */
@property (nonatomic, assign) kSHWeek weeks;

/** authMode=2有效，每日起始时间，
 范围：00:00~23:59。
 单位：分钟
 */
@property (nonatomic, assign) int dayStartTimes;

/** authMode=2有效，每日结束时间，结束一定要大于起始时间
 范围：00:00~23:59。
 单位：分钟
*/
@property (nonatomic, assign) int dayEndTimes;

/**
 0x00：门锁有效次数不变
 0x01 ～ 0xFE：有效次数
 0xFF：无限次
 */
@property (nonatomic, assign) int vaildNumber;


@end

NS_ASSUME_NONNULL_END
