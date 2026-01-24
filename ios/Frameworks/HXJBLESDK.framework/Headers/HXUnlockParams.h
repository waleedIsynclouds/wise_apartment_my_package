//
//  HXUnlockParams.h
//  HXJBLESDK
//
//  Created by JQ on 2020/7/27.
//  Copyright © 2020 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXUnlockParams : NSObject

/**
en:
 Required
 Bluetooth lock mac address, used to judge when sending a command to the specified device
 */
/**
cn:
 必填
 蓝牙锁的mac，用于发送命令时判断发送给指定的设备
 */
@property (nonatomic, copy) NSString *lockMac;

/**
en:
 Optional
 Whether to calibrate the Bluetooth lock time, the default is NO
 YES: According to the systemTime and timezoneOffset to calibrate the Bluetooth lock time;
 NO: Bluetooth unlocking does not calibrate the time, systemTime and timezoneOffset are invalid;
 */
/**
cn:
 可选
 是否校准蓝牙锁时间，默认为NO
 YES：根据systemTime和timezoneOffset给蓝牙锁校准时间；
 NO：蓝牙开锁不校准时间，systemTime和timezoneOffset无效；
 */
@property (nonatomic, assign) BOOL synchronizeTime;

/**
en:
 Optional
 Timestamp (unit: second), synchronizeTime is valid for YES
 For example: systemTime = (long)[[NSDate date] timeIntervalSince1970]
 */
/**
cn:
 可选
 时间戳（单位：秒），synchronizeTime为YES有效
 例如：systemTime = (long)[[NSDate date] timeIntervalSince1970]
 */
@property (nonatomic, assign) long systemTime;

/**
en:
 Optional
 Time zone offset (signed integer, unit: second), synchronizeTime is valid for YES
 Time zone offset = time zone * 3600 + daylight saving time offset
 
 For example: timezoneOffset = (int)[NSTimeZone systemTimeZone].secondsFromGMT;
 */
/**
cn:
 可选
 时区偏移量（有符号整数，单位：秒），synchronizeTime为YES有效
 时区偏移量 = 时区 * 3600 + 夏令时偏移量
 
 例如：timezoneOffset = (int)[NSTimeZone systemTimeZone].secondsFromGMT;
 */
@property (nonatomic, assign) int timezoneOffset;

/**
en:
 Optional,
 Indicates the effective start timestamp of the authorization (unit: second), which can realize the replacement function
 After the value is assigned, all keys whose validity period start timestamp is less than authStartTimestamp in the door lock are invalidated.
 */
/**
cn:
 可选，
 表示授权有效起始时间戳（单位：秒），可实现顶替功能
 赋值后，门锁中有效期起始时间戳小于authStartTimestamp的钥匙全部失效。
 */
@property (nonatomic, strong) NSNumber *authStartTimestamp;

@end

NS_ASSUME_NONNULL_END
