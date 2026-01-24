//
//  HXRecordCloseLockModel.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/23.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import "HXRecordBaseModel.h"

/**
en:
 Lock record
 For example, it can be parsed as: "door lock is closed" or "xxx user closed the door lock"
 */
/**
cn:
 关锁记录
 例如可解析为：“门锁已关闭”或“xxx用户关闭了门锁”
 */
@interface HXRecordCloseLockModel : HXRecordBaseModel

/**
en:
 Operator's key Id
 1) Most door locks do not need to be verified for identity verification, generally 0;
 2) If you want to verify your identity, it corresponds to the key Id
 */
/**
cn:
 操作人的钥匙Id
 1）大部分门锁关锁不需要验证身份，一般为0；
 2）如果要验证身份，则对应为钥匙Id
 */
@property (nonatomic, assign) int operLockKeyId;

- (NSDictionary *)dicFromObject;

@end
