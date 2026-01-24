//
//  HXRecordAntiLockModel.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/23.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import "HXRecordBaseModel.h"

/**
en:
 Unlock/unlock release record
 For example, it can be parsed as: "door lock has been locked" or "antilock has been released"
 */
/**
cn:
 反锁/反锁解除记录
 例如可解析为：”门锁已反锁“或”反锁已解除“
 */
@interface HXRecordAntiLockModel : HXRecordBaseModel

/**
en:
 Operator's user ID
 If the door lock is triggered locally, the operatUserID is 0
 */
/**
cn:
 操作人的用户Id
 若是门锁本地触发，则operatUserID为0
 */
@property (nonatomic, assign) int operKeyGroupId;

/**
en:
 1: Anti-lock, 0: Anti-lock release
 */
/**
cn:
 1:反锁、0：反锁解除
 */
@property (nonatomic, assign) int antiLock;

- (NSDictionary *)dicFromObject;

@end


