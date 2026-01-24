//
//  HXPushEventDeleteKey.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/24.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import "HXPushEventBase.h"

/**
en:
 Delete key event report (KSHEventType_DeleteUser)
 */
/**
cn:
 删除钥匙事件上报(KSHEventType_DeleteUser)
 */
@interface HXPushEventDeleteKey : HXPushEventBase


/**
en:
 Event related flag eventFlag
 0: delete normally
 1: Delete by content
 */
/**
cn:
 事件相关标志eventFlag
 0：正常删除
 1：按内容删除
 */



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
 Delete method:
 0: Delete by key number: key type + number;
 1: Delete by key type: delete all non-administrator keys of the specified key type;
 2: Delete according to the content: the card/password key of the designated card number or password;
 3: Delete according to keyGroupId (user Id), all keys related to this Id will be deleted at one time.
 */
/**
cn:
 删除方式:
 0：按钥匙编号删除：钥匙类型+编号；
 1：按钥匙类型删除：删除指定钥匙类型的所有非管理员钥匙；
 2：按照内容删除：指定卡号或密码的卡片/密码钥匙；
 3：按keyGroupId(用户Id)删除，所有与该Id相关的钥匙一次性删除。
 */
@property (nonatomic, assign) int deleteMode;

/**
en:
 This parameter is valid when deleteMode == 0,
 Indicates the key Id that was deleted
 */
/**
cn:
 deleteMode == 0时该参数有效，
 表示被删除的钥匙Id
 */
@property (nonatomic, assign) int lockKeyId;

/**
en:
 This parameter is valid when deleteMode==0 or deleteMode==1,
 Indicates the key type
 Different key types are represented according to different bits, see KSHKeyType for details
 */
/**
cn:
 deleteMode==0或deleteMode==1时该参数有效，
 表示钥匙类型
 根据不同的bit位表示不同的钥匙类型，具体见KSHKeyType
 */
@property (nonatomic, assign) KSHKeyType keyType;

/**
en:
 This parameter is valid when deleteMode == 2 and eventFlag == 1,
 Indicates the password/card to be deleted
 Card number: up to 8 bytes
 Password: 6~12 digits, only numbers
 */
/**
cn:
 deleteMode == 2 并且eventFlag == 1时该参数有效，
 表示删除的密码/卡片
 卡号: 最长8字节
 密码：6~12位，只能为数字
 */
@property (nonatomic, copy) NSString *key;

/**
en:
 This parameter is valid when deleteMode == 3.
 Indicates the ID of the deleted user
 */
/**
cn:
 deleteMode == 3时该参数有效，
 表示被删除的用户Id
 */
@property (nonatomic, assign) int keyGroupId;

- (NSDictionary *)dicFromObject;

@end

