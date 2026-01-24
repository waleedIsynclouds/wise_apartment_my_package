//
//  HXRecord2WrongKeyUnlockModel.h
//  HXJBLESDK
//
//  Created by JQ on 2022/5/18.
//  Copyright © 2022 JQ. All rights reserved.
//

#import "HXRecord2BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 错误的开锁钥匙事件记录
 */
@interface HXRecord2WrongKeyUnlockModel : HXRecord2BaseModel

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
 Door lock key verification result:
 0x01: The key cannot pass the verification at the door lock end, and the unlocking fails
 0x02: The key can pass the verification at the door lock end, but the door lock is locked, the key cannot be unlocked, and the unlocking fails
 0x03: The key has been replaced
 */
/**
cn:
 门锁钥匙校验结果:
 0x01: 钥匙在门锁端无法通过校验, 开锁失败
 0x02: 钥匙在门锁端可以通过校验, 但门锁反锁, 钥匙无法开反锁, 开锁失败
 0x03：钥匙已被顶替
 */
@property (nonatomic, assign) int keyStatus;

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

@end

NS_ASSUME_NONNULL_END
