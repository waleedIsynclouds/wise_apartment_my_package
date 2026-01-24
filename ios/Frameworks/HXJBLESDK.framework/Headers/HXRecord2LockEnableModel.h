//
//  HXRecord2LockEnableModel.h
//  HXJBLESDK
//
//  Created by JQ on 2022/5/18.
//  Copyright © 2022 JQ. All rights reserved.
//

#import "HXRecord2BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 激活事件记录
 
 示例文案：门锁已激活
 */
@interface HXRecord2LockEnableModel : HXRecord2BaseModel

/**
en:
 Option，Operator's user ID
 */
/**
cn:
 可选，操作人的用户Id
 */
@property (nonatomic, assign) int operKeyGroupId;


@end

NS_ASSUME_NONNULL_END
