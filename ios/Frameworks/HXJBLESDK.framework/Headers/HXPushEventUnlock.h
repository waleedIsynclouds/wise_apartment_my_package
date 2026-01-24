//
//  HXPushEventUnlock.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/24.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import "HXPushEventBase.h"

/**
en:
 Unlock event report (KSHEventType_Unlock)
 */
/**
cn:
 开锁事件上报（KSHEventType_Unlock）
 */
@interface HXPushEventUnlock : HXPushEventBase


/**
en:
 eventFlag description:
 The 7th bit of eventFlag is 1, which means the combination is unlocked;
 The 6th bit of eventFlag is 1, which means the door lock is normally open;
 The fifth bit of eventFlag is 1, which means the door is unlocked;
 */
/**
cn:
 eventFlag 说明：
 eventFlag第7个bit位为1表示组合开锁；
 eventFlag第6个bit位为1表示门锁常开；
 eventFlag第5个bit位为1表示门内开锁；
 */


/**
en:
 Id of unlock user 1
 */
/**
cn:
 开锁用户1的Id
 */
@property (nonatomic, assign) int operKeyGroupId1;

/**
en:
 Key Id used by user 1 to unlock
 */
/**
cn:
 用户1开锁使用的钥匙Id
 */
@property (nonatomic, assign) int lockKeyId1;

/**
en:
 The type corresponding to the key used by user 1 to unlock
 */
/**
cn:
 用户1开锁使用的钥匙对应的类型
 */
@property (nonatomic, assign) KSHKeyType keyType1;



/**
en:
 Generally the default value is 0, if it is not 0, it means the ID of user 2 when the combination is unlocked
 */
/**
cn:
 一般为默认值0，如果不为0表示组合开锁时用户2的Id
 */
@property (nonatomic, assign) int operKeyGroupId2;

/**
en:
 Key Id used by user 2 to unlock
 */
/**
cn:
 用户2开锁使用的钥匙Id
 */
@property (nonatomic, assign) int lockKeyId2;

/**
en:
 The type corresponding to the key used by user 2 to unlock
 */
/**
cn:
 用户2开锁使用的钥匙对应的类型
 */
@property (nonatomic, assign) KSHKeyType keyType2;

- (NSDictionary *)dicFromObject;

@end

