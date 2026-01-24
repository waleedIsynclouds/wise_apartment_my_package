//
//  HXSetKeyEnableParams.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/22.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JQBLEDefines.h"

/** Disable or enable key request parameters */
/** 禁用或激活钥匙请求参数 */
@interface HXSetKeyEnableParams : NSObject

/**
en:
 Required, the mac of the Bluetooth lock, used to judge when sending a command to the specified device
 */
/**
cn:
 必填，蓝牙锁的mac，用于发送命令时判断发送给指定的设备
 */
@property (nonatomic, copy) NSString *lockMac;

/**
en:
 Required
 Operation type
 1: Disable or enable according to lockKeyId
 2: Disable or enable according to keyType
 3: Disable or enable according to keyGroupId (one keyGroupId corresponds to one user)
 */
/**
cn:
 必填
 操作类型
 1：按照lockKeyId进行禁用或激活
 2：按照keyType进行禁用或激活
 3：按照keyGroupId（一个keyGroupId对应一个用户）禁用或激活
 */
@property (nonatomic, assign) int operMode;

/**
en:
 Optional
 Key Id, operMode == 1 This parameter is valid, disable or enable the key Id
 */
/**
cn:
 可选
 钥匙Id，operMode == 1该参数有效，禁用或激活该钥匙Id
 */
@property (nonatomic, assign) int lockKeyId;

/**
en:
 Optional
 The key type to be enabled or disabled, operMode == 2 This parameter is valid
 For example, when only fingerprint, password, card, remote control are set:
 keyTypes == KSHKeyType_Fingerprint|KSHKeyType_Password|KSHKeyType_Card|KSHKeyType_RemoteControl;
 */
/**
cn:
 可选
 要激活或禁用的钥匙类型，operMode == 2 该参数有效
 例如，只设置指纹、密码、卡片、遥控时：
 keyTypes == KSHKeyType_Fingerprint|KSHKeyType_Password|KSHKeyType_Card|KSHKeyType_RemoteControl;
 */
@property (nonatomic, assign) KSHKeyType keyTypes;

/**
en:
 Optional
 Key group Id (one keyGroupId corresponds to one user), operMode == 3 This parameter is valid, disable or enable all keys under a certain user
 */
/**
cn:
 可选
 钥匙组Id（一个keyGroupId对应一个用户），operMode == 3该参数有效，禁用或激活某一个用户下所有的钥匙
 */
@property (nonatomic, assign) int keyGroupId;

/**
en:
 Required
 1) When operModel == 1 or operMode == 3, 1: means enable, 0: disabled;
 2) When operModel == 2, the bit field of enable corresponding to keyType is 1 to indicate enable, and 0 to disable
    For example, when fingerprints and cards are enabled, passwords and remote control are disabled:
    keyTypes = KSHKeyType_Fingerprint|KSHKeyType_Password|KSHKeyType_Card|KSHKeyType_RemoteControl;
    enable = KSHKeyType_Fingerprint|KSHKeyType_Card; (disabled key type does not participate in OR operation)
 */
/**
cn:
 必填
 1）当operModel == 1 或 operMode == 3时，1:表示激活，0:禁用；
 2）当operModel == 2 时，enable对应keyType的位域为1表示激活，为0表示禁用
    例如，激活指纹和卡片，禁用密码和遥控时：
    keyTypes = KSHKeyType_Fingerprint|KSHKeyType_Password|KSHKeyType_Card|KSHKeyType_RemoteControl;
    enable = KSHKeyType_Fingerprint|KSHKeyType_Card;（禁用的钥匙类型不参与或运算）
 */
@property (nonatomic, assign) int enable;

@end

