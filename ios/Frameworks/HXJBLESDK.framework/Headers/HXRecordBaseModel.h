//
//  HXRecordBaseModel.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/23.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JQBLEDefines.h"

/**
en:
 Note: keyGroupId corresponds to a user,
         lockKeyId corresponds to a key,
         One user can add multiple keys
 */
/**
cn:
 特别说明：keyGroupId对应一个用户，
         lockKeyId对应一个钥匙，
         一个用户可以添加多把钥匙
 */


/** Bluetooth lock operation record base class */
/** 第一代蓝牙锁操作记录基类 */
@interface HXRecordBaseModel : NSObject

/**
en:
 Record time,
 Unit: second
 */
/**
cn:
 记录时间，
 单位：秒
 */
@property (nonatomic, assign) long recordTime;

/**
en:
 Record type
 */
/**
cn:
 记录类型
 */
@property (nonatomic, assign) kSHBLEReadRecordType recordType;

- (NSDictionary *)dicFromObject;

@end
