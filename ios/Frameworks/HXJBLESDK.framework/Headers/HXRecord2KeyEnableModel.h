//
//  HXRecord2KeyEnableModel.h
//  HXJBLESDK
//
//  Created by JQ on 2022/3/28.
//  Copyright © 2022 JQ. All rights reserved.
//

#import "HXRecord2BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 钥匙的使能与禁止记录
 */
@interface HXRecord2KeyEnableModel : HXRecord2BaseModel


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
 Operation type
 1: Disable or enable according to lockKeyId
 2: Disable or enable according to keyType
 3: Disable or enable according to keyGroupId (user Id)
 */
/**
cn:
 操作类型
 1：按照lockKeyId进行禁用或激活
 2：按照keyType进行禁用或激活
 3：按照keyGroupId（用户Id）禁用或激活
 */
@property (nonatomic, assign) int operMode;

/**
en:
 operMode == 1 This parameter is valid,
 Key Id, disable or enable the key Id
 */
/**
cn:
 operMode == 1该参数有效，
 钥匙Id，禁用或激活该钥匙Id
 */
@property (nonatomic, assign) int modifyLockKeyId;

/**
en:
 operMode == 2 This parameter is valid
 Type of key to enable or disable
 For example, the following conditions can be used to determine whether the set key type includes fingerprints, passwords, cards, or apps, etc.
 (modifyKeyTypes & KSHKeyType_Fingerprint == KSHKeyType_Fingerprint), the condition is satisfied, it means that the set key type includes fingerprint
 (modifyKeyTypes & KSHKeyType_Password == KSHKeyType_Password)
 (modifyKeyTypes & KSHKeyType_Card == KSHKeyType_Card)
 (modifyKeyTypes & KSHKeyType_App == KSHKeyType_App)
 */
/**
cn:
 operMode == 2 该参数有效
 要激活或禁用的钥匙类型
 例如可通过以下条件判断设置的钥匙类型是否包括指纹、密码、卡片或App等类型钥匙
 (modifyKeyTypes & KSHKeyType_Fingerprint == KSHKeyType_Fingerprint),条件成立表示设置的钥匙类型包括指纹
 (modifyKeyTypes & KSHKeyType_Password == KSHKeyType_Password)
 (modifyKeyTypes & KSHKeyType_Card == KSHKeyType_Card)
 (modifyKeyTypes & KSHKeyType_App == KSHKeyType_App)
 */
@property (nonatomic, assign) KSHKeyType modifyKeyTypes;

/**
en:
 operMode == 3 This parameter is valid
 Modified user Id, disable or enable all keys under this user
 */
/**
cn:
 operMode == 3该参数有效
 被修改的用户Id，禁用或激活该用户下所有的钥匙
 */
@property (nonatomic, assign) int modifyKeyGroupId;

/**
en:
 enable or disable
 1) When operModel == 1 or operMode == 3, 1: enable, 2: disabled;
 2) When operModel == 2, the bit field of enable corresponding to keyType is 1 to indicate enable, and 0 to disable
 E.g,
 (modifyKeyTypes & KSHKeyType_Fingerprint == KSHKeyType_Fingerprint) &&
 (enable & KSHKeyType_Fingerprint == KSHKeyType_Fingerprint) If the condition is satisfied, it means that the fingerprint key is enable
 
 (modifyKeyTypes & KSHKeyType_Password == KSHKeyType_Password) &&
 (enable & KSHKeyType_Password == 0) If the condition is satisfied, the password key is disabled
 */
/**
cn:
 激活或禁用
 1）当operModel == 1 或 operMode == 3时，1:表示激活，2:禁用；
 2）当operModel == 2 时，enable对应keyType的位域为1表示激活，为0表示禁用
 例如，
 (modifyKeyTypes & KSHKeyType_Fingerprint == KSHKeyType_Fingerprint) &&
 (enable & KSHKeyType_Fingerprint == KSHKeyType_Fingerprint)条件成立表示激活指纹钥匙
 
 (modifyKeyTypes & KSHKeyType_Password == KSHKeyType_Password) &&
 (enable & KSHKeyType_Password == 0)条件成立表示禁用密码钥匙
 */
@property (nonatomic, assign) int enable;

@end

NS_ASSUME_NONNULL_END
