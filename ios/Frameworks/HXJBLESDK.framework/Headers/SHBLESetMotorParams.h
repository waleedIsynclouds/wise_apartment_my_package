//
//  SHBLESetMotorParams.h
//  SmartHomeSDK
//
//  Created by JQ on 2019/6/28.
//  Copyright © 2019 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SHBLESetMotorParams : NSObject

/**
en:
 Door lock Mac, required
 */
/**
cn:
 门锁Mac，必填
 */
@property (nonatomic, strong) NSString *lockMac;

/**
en:
 Door opening direction, optional
 0: Open the door to the left
 1: Open the door on the right
 */
/**
cn:
 开门方向，可选
 0：左开门
 1：右开门
 */
@property (nonatomic, strong) NSNumber *unLockDirection;

/**
en:
 Slant tongue extension time, optional
 The value range is: 1-9 (means 0.1 second to 0.9 second)
 */
/**
cn:
 斜舌伸出时间，可选
 取值范围为：1～9（表示0.1秒 ~ 0.9秒）
 */
@property (nonatomic, strong) NSNumber *tongueLockTime;

/**
en:
 Locking current level of square tongue, optional
 The range of values ​​is as follows:
 24: Low current
 29: Current mid-range
 34: High current
 49: current adaptive
 */
/**
cn:
 方舌堵转电流等级，可选
 取值范围如下：
 24：电流低档
 29：电流中档
 34：电流高档
 49：电流自适应
 */
@property (nonatomic, strong) NSNumber *squareTongueBlockingCurrentLevel;

/**
en:
 Pause time after the oblique tongue is fully retracted, optional
 The value range is 10 to 90, and must be a multiple of 10, which means 1 second to 9 seconds
 */
/**
cn:
 斜舌完全回缩后停顿时间，可选
 取值范围为10~90，必须为10的倍数，表示1秒~9秒
 */
@property (nonatomic, strong) NSNumber *tongueUlockTime;

/**
en:
 Automatic lock time level, optional
 The range of values ​​is as follows:
 0: means no lock;
 10: indicates that it will be automatically locked after 10 seconds;
 15: Means that it will be automatically locked after 15 seconds;
 20: means that the lock will be automatically locked after 20 seconds;
 */
/**
cn:
 自动上锁时间等级，可选
 取值范围如下：
 0：表示不上锁；
 10：表示10秒后自动上锁；
 15：表示15秒后自动上锁；
 20：表示20秒后自动上锁；
 */
@property (nonatomic, strong) NSNumber *lockWaitTime;

@end

NS_ASSUME_NONNULL_END
