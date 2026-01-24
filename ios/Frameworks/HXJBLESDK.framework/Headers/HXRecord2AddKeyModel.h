//
//  HXRecord2AddKeyModel.h
//  HXJBLESDK
//
//  Created by JQ on 2022/3/28.
//  Copyright © 2022 JQ. All rights reserved.
//

#import "HXRecord2BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 添加钥匙记录
 
 注意：事件相关标志eventFlag说明如下：
 0：表示普通钥匙添加事件
 1：表示算法密码钥匙添加事件
 */
@interface HXRecord2AddKeyModel : HXRecord2BaseModel


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
 User Id to which the key belongs
 (Note: The key is added to the key group, and a user can add multiple keys, which corresponds to multiple lockKeyIds)
 Value range: 900~4095
 */
/**
cn:
 钥匙所属用户Id
 （说明：钥匙新增到该钥匙组中，一个用户可以添加多把钥匙，即对应多个lockKeyId）
 取值范围：900~4095
 */
@property (nonatomic, assign) int addedKeyGroupId;

/**
en:
 Key Id, the unique Id of the key saved in the door lock
 */
/**
cn:
 钥匙Id，保存在门锁中的钥匙唯一Id
 */
@property (nonatomic, assign) int lockKeyId;

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
 钥匙长度
 密码钥匙的长度为6～12。
 卡片钥匙的长度为1～8。
 注意: 并不是所有锁都会在开始事件中上报钥匙内容, 若钥匙长度为0, 则表明门锁没有上报钥匙内容
 */
@property (nonatomic, assign) int keyLen;

/**
en:
 eventFlag == 1 This parameter is valid
 Added password
 Password: 6-12 digits, only 0-9 digits can be set
 */
/**
cn:
 eventFlag == 1该参数有效
 添加的密码
 密码：6~12位，只能设置0~9的数字
 */
@property (nonatomic, copy) NSString *key;


@end

NS_ASSUME_NONNULL_END
