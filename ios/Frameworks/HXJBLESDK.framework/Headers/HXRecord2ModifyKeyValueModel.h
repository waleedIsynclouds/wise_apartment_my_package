//
//  HXRecord2ModifyKeyValueModel.h
//  HXJBLESDK
//
//  Created by JQ on 2022/5/18.
//  Copyright © 2022 JQ. All rights reserved.
//

#import "HXRecord2BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 按照钥匙内容修改钥匙信息事件记录 （例如修改卡号或密码）
 */
@interface HXRecord2ModifyKeyValueModel : HXRecord2BaseModel

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
 Key type
 */
/**
cn:
 钥匙类型
 */
@property (nonatomic, assign) KSHKeyType keyType;

/**
 密码钥匙的长度为6～15, 若门锁输入的密码不足6位, 将不会上报此事件。
 卡片钥匙的长度为1～8。
 指纹钥匙不会上传钥匙内容, 钥匙长度为0
 */
@property (nonatomic, assign) int keyLen;

/**
en:
 For password keys, the key content is in ASCII format;
 For card keys, the key content is the card number in hexadecimal format
 */
/**
cn:
 对于密码钥匙, 钥匙内容为ASCII格式;
 对于卡片钥匙, 钥匙内容为十六进制格式的卡号
 */
@property (nonatomic, copy) NSString *key;

/**
 钥匙可用的次数
 */
@property (nonatomic, assign) int vaildNumber;

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
 The modified user
 */
/**
cn:
 被修改的用户
 */
@property (nonatomic, assign) int modifyKeyGroupId;

@end

NS_ASSUME_NONNULL_END
