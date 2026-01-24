//
//  HXRecordDeleteGroupKeyModel.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/23.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import "HXRecordBaseModel.h"

/**
en:
 Delete keys in bulk
 For example, it can be parsed as: "All keys of user xxx are deleted" or "All keys of xxx type are deleted"
 */
/**
cn:
 批量删除钥匙
 例如可解析为：“xxx用户所有钥匙被删除”或“所有xxx类型钥匙被删除”
 */
@interface HXRecordDeleteGroupKeyModel : HXRecordBaseModel

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
 Delete mode
 1: Delete by key type
 3: Delete by user ID
 */
/**
cn:
 删除模式
 1: 按钥匙类型删除
 3: 按用户ID删除
 */
@property (nonatomic, assign) int deleteMode;

/**
en:
 deleteMode == 1 This parameter is valid
 Type of key deleted
 For example, the following conditions can be used to determine whether the deleted key type includes fingerprints, passwords, cards, or apps.
 (keyType & KSHKeyType_Fingerprint == KSHKeyType_Fingerprint), the condition is satisfied, the key type to be deleted includes fingerprint
 (keyType & KSHKeyType_Password == KSHKeyType_Password)
 (keyType & KSHKeyType_Card == KSHKeyType_Card)
 (keyType & KSHKeyType_App == KSHKeyType_App)
 
 Other instructions: if delKeyType == 255, it means delete all types of keys
 */
/**
cn:
 deleteMode == 1该参数有效
 被删除的钥匙类型
 例如可通过以下条件判断删除的钥匙类型是否包括指纹、密码、卡片或App等类型钥匙
 (keyType & KSHKeyType_Fingerprint == KSHKeyType_Fingerprint),条件成立表示删除的钥匙类型包括指纹
 (keyType & KSHKeyType_Password == KSHKeyType_Password)
 (keyType & KSHKeyType_Card == KSHKeyType_Card)
 (keyType & KSHKeyType_App == KSHKeyType_App)
 
 其它说明：如果delKeyType == 255，表示删除所有类型的钥匙
 */
@property (nonatomic, assign) KSHKeyType delKeyType;

/**
en:
 deleteMode == 3 This parameter is valid
 Id of the user whose key was deleted
 */
/**
cn:
 deleteMode == 3该参数有效
 被删除钥匙的用户Id
 */
@property (nonatomic, assign) int delKeyGroupId;

- (NSDictionary *)dicFromObject;

@end
