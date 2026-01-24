//
//  HXRecord2BaseModel.h
//  HXJBLESDK
//
//  Created by JQ on 2022/3/28.
//  Copyright © 2022 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JQBLEDefines.h"

NS_ASSUME_NONNULL_BEGIN

/** Bluetooth lock operation record base class */
/** 第二代蓝牙锁操作记录基类 */
@interface HXRecord2BaseModel : NSObject

/**
en:
 Record time,
 Unit: second
 */
/**
cn:
 记录时间，
 单位：秒
 */
@property (nonatomic, assign) long recordTime;

/**
en:
 Record type
 */
/**
cn:
 记录类型
 */
@property (nonatomic, assign) KSHEventType recordType;

/**
 事件相关标志
 */
@property (nonatomic, assign) int eventflag;

/**
en:
 battery power
 Interval range: 0~100
 */
/**
cn:
 电池电量
 区间范围：0~100
 */
@property (nonatomic, assign) int power;

- (NSDictionary *)dicFromObject;

@end

NS_ASSUME_NONNULL_END
