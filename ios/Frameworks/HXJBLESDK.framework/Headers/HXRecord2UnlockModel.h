//
//  HXRecord2UnlockModel.h
//  HXJBLESDK
//
//  Created by JQ on 2022/3/28.
//  Copyright © 2022 JQ. All rights reserved.
//

#import "HXRecord2BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 开锁记录
 
 注意：开锁记录中eflag相关标志说明如下：
 Eflag.7 == 1：双重认证开锁（表示2个人以上操作才能打开门锁）（即eflag第7个bit位值为1）
 Eflag.6 == 1：门锁常开（即eflag第6个bit位值为1）
 Eflag.5 == 1：门内开锁（即eflag第5个bit位值为1）
 */
@interface HXRecord2UnlockModel : HXRecord2BaseModel


/**
en:
 Id of unlock user 1
 */
/**
cn:
 开锁用户1的Id
 */
@property (nonatomic, assign) int operKeyGroupId1;

/**
en:
 The type corresponding to the key used by user 1 to unlock
 */
/**
cn:
 用户1开锁使用的钥匙对应的类型
 */
@property (nonatomic, assign) KSHKeyType keyType1;

/**
en:
 Key Id used by user 1 to unlock
 */
/**
cn:
 用户1开锁使用的钥匙Id
 */
@property (nonatomic, assign) int lockKeyId1;


/**
en:
 Id of unlock user 2
 */
/**
cn:
 开锁用户2的Id
 */
@property (nonatomic, assign) int operKeyGroupId2;

/**
en:
 The type corresponding to the key used by user 2 to unlock
 */
/**
cn:
 用户2开锁使用的钥匙对应的类型
 */
@property (nonatomic, assign) KSHKeyType keyType2;

/**
en:
 Key Id used by user 2 to unlock
 */
/**
cn:
 用户2开锁使用的钥匙Id
 */
@property (nonatomic, assign) int lockKeyId2;

/**
 钥匙1长度
 密码钥匙的长度为6～12
 卡片钥匙的长度为1～8
 注意: 并不是所有锁都会在开始事件中上报钥匙内容, 若钥匙长度为0, 则表明门锁没有上报钥匙内容
 */
@property (nonatomic, assign) int keyLen1;

/**
 钥匙1内容
 对于密码钥匙, 钥匙内容为ASCII格式;
 对于卡片钥匙, 钥匙内容为十六进制格式的卡号，超过12字节去掉末尾部分
 */
@property (nonatomic, copy) NSString *key1;

/**
 钥匙1剩余使用次数
 */
@property (nonatomic, assign) int Key1RemainingTimes;

/**
 钥匙2剩余使用次数
 */
@property (nonatomic, assign) int key2RemainingTimes;


@end

NS_ASSUME_NONNULL_END
