//
//  HXRecordUnlockModel.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/23.
//  Copyright © 2019年 JQ. All rights reserved.

#import "HXRecordBaseModel.h"

/**
en:
 Unlock record
 For example, it can be parsed as: "User xxx opened the door lock"
 */
/**
cn:
 开锁记录
 例如可解析为：“xxx用户打开了门锁”
 */
@interface HXRecordUnlockModel : HXRecordBaseModel

/**
en:
 Unlock user's Id 1
 */
/**
cn:
 开锁用户的Id 1
 */
@property (nonatomic, assign) int operKeyGroupId1;

/**
en:
 Unlock user's Id 2
 Generally the default value is 0, if it is not 0, it means the combination unlock (that is, the openMode value in HXBLEDeviceStatus is the combination unlock)
 */
/**
cn:
 开锁用户的Id 2
 一般为默认值0，如果不为0表示组合开锁（即HXBLEDeviceStatus中的openMode值为组合开锁）
 */
@property (nonatomic, assign) int operKeyGroupId2;

- (NSDictionary *)dicFromObject;

@end

