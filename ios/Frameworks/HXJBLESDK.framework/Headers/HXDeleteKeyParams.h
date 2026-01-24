//
//  HXDeleteKeyParams.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/22.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JQBLEDefines.h"

/** Delete key request parameter */
/** 删除钥匙请求参数 */
@interface HXDeleteKeyParams : NSObject

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
 Delete method:
 0: Delete by key number: key type + number;
 1: Delete by key type: delete all non-administrator keys of the specified key type;
 2: Delete according to the content: card number or password + key type;
 3: Delete according to keyGroupId (user Id), all keys related to this Id will be deleted at one time.
 */
/**
cn:
 必填
 删除方式:
 0：按钥匙编号删除：钥匙类型+编号；
 1：按钥匙类型删除：删除指定钥匙类型的所有非管理员钥匙；
 2：按照内容删除：卡号或密码 + 钥匙类型；
 3：按keyGroupId(用户Id)删除，所有与该Id相关的钥匙一次性删除。
 */
@property (nonatomic, assign) int deleteMode;

/**
en:
 Optional
 This parameter is valid when deleteMode == 0, which means the key Id to be deleted
 */
/**
cn:
 可选
 deleteMode == 0时该参数有效，表示被删除的钥匙Id
 */
@property (nonatomic, assign) int lockKeyId;

/**
en:
 Optional
 This parameter is valid when deleteMode==0 or deleteMode==1 or deleteMode==2, indicating the key type
 For example, if you delete fingerprints, passwords, cards, and App keys, then:
 keyType = KSHKeyType_Fingerprint|KSHKeyType_Password|KSHKeyType_Card|KSHKeyType_App;
 */
/**
cn:
 可选
 deleteMode==0或deleteMode==1或deleteMode==2时该参数有效，表示钥匙类型
 例如删除指纹、密码、卡片和App类型的钥匙，则：
 keyType = KSHKeyType_Fingerprint|KSHKeyType_Password|KSHKeyType_Card|KSHKeyType_App;
 */
@property (nonatomic, assign) KSHKeyType keyType;

/**
en:
 Optional
 This parameter is valid when deleteMode == 2, which means the password/card to be deleted
 Card number: up to 8 bytes
 Password: 6~12 digits, only numbers
 */
/**
cn:
 可选
 deleteMode == 2时该参数有效，表示删除的密码/卡片
 卡号: 最长8字节
 密码：6~12位，只能为数字
 */
@property (nonatomic, copy) NSString *passwordOrCar;

/**
en:
 Optional,
 This parameter is valid when deleteMode == 3, which means to delete by user Id
 */
/**
cn:
 可选，
 deleteMode == 3时该参数有效，表示按用户Id删除
 */
@property (nonatomic, assign) int keyGroupId;

@end
