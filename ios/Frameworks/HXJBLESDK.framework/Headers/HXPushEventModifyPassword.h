//
//  HXPushEventModifyPassword.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/24.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import "HXPushEventBase.h"

/**
en:
 Reporting of password modification events (namely modifying the key) (KSHEventType_ChangePassword)
 */
/**
cn:
 修改密码事件上报（即修改钥匙）(KSHEventType_ChangePassword)
 */
@interface HXPushEventModifyPassword : HXPushEventBase

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
 Modified key Id
 */
/**
cn:
 被修改的钥匙Id
 */
@property (nonatomic, assign) int modifyLockKeyId;

/**
en:
 The key type corresponding to the modifyLockKeyId key
 */
/**
cn:
 modifyLockKeyId钥匙对应的钥匙类型
 */
@property (nonatomic, assign) KSHKeyType modifyLockKeyType;

- (NSDictionary *)dicFromObject;

@end

