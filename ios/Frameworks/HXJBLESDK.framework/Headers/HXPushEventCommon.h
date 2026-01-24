//
//  HXPushEventCommon.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/24.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import "HXPushEventBase.h"

/**
en:
 General event reporting object
 */
/**
cn:
 通用事件上报对象
 */
@interface HXPushEventCommon : HXPushEventBase

@property (nonatomic, assign) KSHKeyType keyType;

@property (nonatomic, assign) int lockKeyId;

- (NSDictionary *)dicFromObject;

@end
