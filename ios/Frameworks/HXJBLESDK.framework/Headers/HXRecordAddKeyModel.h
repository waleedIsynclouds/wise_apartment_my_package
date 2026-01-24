//
//  HXRecordAddKeyModel.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/23.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import "HXRecordBaseModel.h"

/**
en:
 Add key record
 For example, it can be parsed as: "The xxx user added a xxx key"
 */
/**
cn:
 添加钥匙记录
 例如可解析为：“xxx用户添加了一枚xxx钥匙”
 */
@interface HXRecordAddKeyModel : HXRecordBaseModel

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
 Successfully added key Id
 */
/**
cn:
 添加成功的钥匙Id
 */
@property (nonatomic, assign) int addLockKeyId;

/**
en:
 The key type corresponding to addLockKeyId
 */
/**
cn:
 addLockKeyId对应的钥匙类型
 */
@property (nonatomic, assign) KSHKeyType keyType;

- (NSDictionary *)dicFromObject;

@end
