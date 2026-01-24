//
//  HXRecordModifyKeyTimeModel.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/23.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import "HXRecordBaseModel.h"

/**
en:
 Modify the key validity period record
 For example, it can be parsed as: "The xxx user has modified the validity period of the xxx key" etc.
 */
/**
cn:
 修改钥匙有效期记录
 例如可解析为：”xxx用户修改了xxx钥匙的有效期“等
 */
@interface HXRecordModifyKeyTimeModel : HXRecordBaseModel

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
 1: Modify according to lockKeyId
 2: Modify according to keyGroupId (one keyGroupId corresponds to one user)
 */
/**
cn:
 1：按照lockKeyId修改
 2：按照keyGroupId修改（一个keyGroupId对应一个用户）
 */
@property (nonatomic, assign) int changeMode;

/**
en:
 If changeMode = 1, it means lockKeyId here; the value range is: 11 to 899
 If changeMode = 2, it means keyGroupId here; the value range is: 900 to 4095
 */
/**
cn:
 若changeMode = 1，则这里表示lockKeyId；取值范围为：11 ～ 899
 若changeMode = 2，则这里表示keyGroupId；取值范围为：900 ～ 4095
 */
@property (nonatomic, assign) int changeId;

- (NSDictionary *)dicFromObject;

@end

