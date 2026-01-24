//
//  HXRecordVerifyPwModel.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/23.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import "HXRecordBaseModel.h"

/**
en:
 Verify password record
 For example, it can be parsed as: "User xxx performs verification password on xxx key: pass"
 */
/**
cn:
 验证密码记录
 例如可解析为：“用户xxx对xxx钥匙执行验证密码：通过“
 */
@interface HXRecordVerifyPwModel : HXRecordBaseModel

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
 Key Id used for verification
 */
/**
cn:
 用于验证的钥匙Id
 */
@property (nonatomic, assign) int lockKeyId;

/**
en:
 Whether the verification is passed, 1: the verification is passed, 0: the verification is not passed
 */
/**
cn:
 验证是否通过，1：验证通过，0：验证不通过
 */
@property (nonatomic, assign) int isPass;

- (NSDictionary *)dicFromObject;

@end

