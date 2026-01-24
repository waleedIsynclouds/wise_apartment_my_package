//
//  HXRecord2ModifyKeyModel.h
//  HXJBLESDK
//
//  Created by JQ on 2022/3/28.
//  Copyright © 2022 JQ. All rights reserved.
//

#import "HXRecord2BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 修改密码
 */
@interface HXRecord2ModifyKeyModel : HXRecord2BaseModel

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


/// 钥匙内容
@property (nonatomic, assign) NSString *key;


@end

NS_ASSUME_NONNULL_END
