//
//  HXPushEventBase.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/24.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JQBLEDefines.h"

/** Event reporting object base class */
/** 事件上报对象基类 */
@interface HXPushEventBase : NSObject

/**
en:
 Door lock Mac
 */
/**
cn:
 门锁Mac
 */
@property (nonatomic, copy) NSString *lockMac;

/**
en:
 battery power
 */
/**
cn:
 电池电量
 */
@property (nonatomic, assign) int power;

/**
en:
 Event related flags
 */
/**
cn:
 事件相关标志
 */
@property (nonatomic, assign) int eventFlag;

/**
en:
 Event type
 */
/**
cn:
 事件类型
 */
@property (nonatomic, assign) KSHEventType eventType;

/**
en:
 Timestamp: Indicates when the event was triggered
 */
/**
cn:
 时间戳：表示事件触发时间
 */
@property (nonatomic, assign) long timestamp;


- (NSDictionary *)dicFromObject;

@end
