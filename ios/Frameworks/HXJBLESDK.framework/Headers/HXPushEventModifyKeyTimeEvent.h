//
//  HXPushEventModifyKeyTimeEvent.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/24.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import "HXPushEventBase.h"

/**
en:
 Modify key validity period event report (KSHEventType_ModifyKeyTime)
 */
/**
cn:
 修改钥匙有效期事件上报(KSHEventType_ModifyKeyTime)
 */
@interface HXPushEventModifyKeyTimeEvent : HXPushEventBase

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
 If changeMode = 1, it means lockKeyId here; the value range is: 11 to 899
 If changeMode = 2, it means keyGroupId here; the value range is: 900 to 4095
 */
/**
cn:
 若changeMode = 1，则这里表示lockKeyId；取值范围为：11 ～ 899
 若changeMode = 2，则这里表示keyGroupId；取值范围为：900 ～ 4095
 */
@property (nonatomic, assign) int changeId;

- (NSDictionary *)dicFromObject;

@end

