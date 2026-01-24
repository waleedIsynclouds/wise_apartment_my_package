//
//  HXRecordModifyKeyModel.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/23.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import "HXRecordBaseModel.h"

/**
en:
 Modify key record
 For example, it can be parsed as: "xxx key is modified"
 */
/**
cn:
 修改钥匙记录
 例如可解析为：“xxx钥匙被修改”
 */
@interface HXRecordModifyKeyModel : HXRecordBaseModel

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

