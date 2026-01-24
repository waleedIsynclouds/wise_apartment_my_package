//
//  HXRecordArmDisarmModel.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/23.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import "HXRecordBaseModel.h"

/**
en:
 Arm/disarm record
 For example, it can be parsed as: "Door lock is armed/disarmed"
 */
/**
cn:
 布防/撤防记录
 例如可解析为：”门锁已布防/撤防“
 */
@interface HXRecordArmDisarmModel : HXRecordBaseModel

/**
en:
 Operator's user ID
 If the door lock is triggered locally, the operatUserID is 0
 */
/**
cn:
 操作人的用户Id
 若是门锁本地触发，则operatUserID为0
 */
@property (nonatomic, assign) int operKeyGroupId;

/**
en:
 1: Armed, 0: Disarmed
 */
/**
cn:
 1:布防、0：撤防
 */
@property (nonatomic, assign) int arm;

- (NSDictionary *)dicFromObject;

@end

