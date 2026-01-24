//
//  HXBLEDeviceStatus.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/17.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
en:
 Bluetooth lock status information
 */
/**
cn:
 蓝牙锁状态信息
 */
@interface HXBLEDeviceStatus : NSObject

/**
 系统参数和状态字符串，供服务器端使用
 */
@property (nonatomic, copy) NSString *deviceStatusStr;

/**
en:
 Bluetooth lock MAC
 */
/**
cn:
 蓝牙锁MAC
 */
@property (nonatomic, copy) NSString *lockMac;

/**
en:
 Unlock mode
 0-No unlock mode setting function
 1- Single unlock;
 2- Combination unlock;
 */
/**
cn:
 开锁模式
 0-无开锁模式设置功能
 1-单一开锁;
 2-组合开锁;
 */
@property (nonatomic, assign) int openMode;

/**
en:
 Normally open mode
 0-No normally open mode setting function
 1- Normally open mode is enabled;
 2- Normally open mode is closed.
 */
/**
cn:
 常开模式
 0-无常开模式设置功能
 1-常开模式启用;
 2-常开模式关闭。
 */
@property (nonatomic, assign) int normallyOpenMode;

/**
en:
 Normally open state flag
 0-Bluetooth lock is not in the normally open state;
 1- The Bluetooth lock is in the normally open state.
 */
/**
cn:
 常开状态标志
 0-蓝牙锁未处于常开状态;
 1-蓝牙锁处于常开状态。
 */
@property (nonatomic, assign) int normallyopenFlag;

/**
en:
 Voice opening and closing
 0- irrelevant door opening and closing function setting;
 1- Open and close the door voice;
 2- The door opening and closing voice is turned off.
 */
/**
cn:
 开门语音启闭
 0-无关门启闭功能设置；
 1-开关门语音打开;
 2-开关门语音关闭。
 */
@property (nonatomic, assign) int volumeEnable;

/**
en:
 Anti-pry alarm opening and closing
 0-No anti-pry alarm function;
 1- The anti-pry alarm function is enabled;
 2- The anti-pry alarm function is off
 */
/**
cn:
 防撬报警启闭
 0-无防撬报警功能;
 1-防撬报警功能启用;
 2-防撬报警功能关闭
 */
@property (nonatomic, assign) int shackleAlarmEnable;

/**
en:
 Tamper switch status
 0-No tamper-proof switch detection;
 1- The tamper switch is not operating;
 2- The tamper switch has been activated (may trigger a forced demolition event)
 */
/**
cn:
 防撬开关状态
 0-无防撬开关检测;
 1-防撬开关未动作;
 2-防撬开关已动作(可能触发强拆事件)
 */
@property (nonatomic, assign) int tamperSwitchStatus;

/**
en:
 Lock cylinder alarm opening and closing
 0-No lock core alarm function;
 1- The lock core alarm function is enabled;
 2- The lock core alarm function is disable
*/
/**
cn:
 锁芯报警启闭
 0-无锁芯报警功能;
 1-锁芯报警功能启用;
 2-锁芯报警功能关闭。
*/
@property (nonatomic, assign) int lockCylinderAlarmEnable;

/**
en:
 Lock core switch state
 0-No lock core detection;
 1- The key is not inserted into the lock cylinder;
 2- The lock core has been inserted with the key
 */
/**
cn:
 锁芯开关状态
 0-无锁芯检测;
 1-锁芯未插入钥匙;
 2-锁芯已插入钥匙
 */
@property (nonatomic, assign) int cylinderSwitchStatus;

/**
en:
 Anti-lock function open and close
 0-No anti-lock switch;
 1- Anti-lock function is enabled;
 2- The anti-lock function is disable
 */
/**
cn:
 反锁功能启闭
 0-无反锁开关;
 1-反锁功能启用;
 2-反锁功能关闭。
 */
@property (nonatomic, assign) int antiLockEnable;

/**
en:
 Anti-lock state
 0-No anti-lock switch;
 1- Unlocked;
 2- Has been locked.
 */
/**
cn:
 反锁状态
 0-无反锁开关;
 1-未打反锁;
 2-已打反锁。
 */
@property (nonatomic, assign) int antiLockStatues;

/**
en:
 Lock head cover alarm opening and closing
 0-No lock cover switch;
 1- The lock cover alarm is enabled;
 2- The lock cover alarm is closed
 */
/**
cn:
 锁头盖报警启闭
 0-无锁头盖开关;
 1-锁头盖报警启用;
 2-锁头盖报警关闭
 */
@property (nonatomic, assign) int lockCoverAlarmEnable;

/**
en:
 Lock cover switch status
 0-No lock cover switch;
 1- The lock cover alarm is enabled;
 2- The lock cover alarm is turned off.
 */
/**
cn:
 锁头盖开关状态
 0-无锁头盖开关;
 1-锁头盖报警启用;
 2-锁头盖报警关闭。
 */
@property (nonatomic, assign) int lockCoverSwitchStatus;

/**
en:
 system time
 Unit: second
 */
/**
cn:
 系统时间
 单位：秒
 */
@property (nonatomic, assign) long systemTimeTimestamp;

/**
en:
 Time zone offset
 Unit: second
 */
/**
cn:
 时区偏移量
 单位：秒
 */
@property (nonatomic, assign) int timezoneOffset;

/**
en:
 System volume
 0- means the volume cannot be adjusted.
 Other values-indicate normal system volume
 */
/**
cn:
 系统音量
 0-表示音量不可调节.
 其他值-表示正常系统音量
 */
@property (nonatomic, assign) int systemVolume;

/**
en:
 battery power
 Interval range: 0~100
 */
/**
cn:
 电池电量
 区间范围：0~100
 */
@property (nonatomic, assign) int power;

/**
en:
 Remaining unlock times after low battery
 When this number of times becomes 0, unlocking will be prohibited.
 */
/**
cn:
 低电量后剩余开锁次数
 当此次数变为0时,将会禁止开锁.
 */
@property (nonatomic, assign) int lowPowerUnlockTimes;

/**
en:
 Key type currently enabled
 The type whose bit field is 1 indicates that it is currently enabled.
 The type with a bit field of 0 means that it is prohibited or the door lock does not have this key type.
 */
/**
cn:
 当前使能的钥匙类型
 位域为1的类型表示当前使能。
 位域为0的类型表示禁止或者门锁没有此钥匙类型。
 */
@property (nonatomic, assign) int enableKeyType;

/**
en:
 Generous tongue
 0-No generous tongue switch;
 1- Retracted state of generous tongue;
 2- The generous tongue extended state (door locked state)
 */
/**
cn:
 大方舌状态
 0-无大方舌开关;
 1-大方舌缩进状态;
 2-大方舌伸出状态(锁门状态)
 */
@property (nonatomic, assign) int squareTongueStatues;

/**
en:
 Slant tongue state
 0-No oblique tongue switch;
 1- The oblique tongue retracted state;
 2- The oblique tongue is extended;
 */
/**
cn:
 斜舌状态
 0-无斜舌开关;
 1-斜舌缩进状态;
 2-斜舌伸出状态;
 */
@property (nonatomic, assign) int obliqueTongueStatues;

/**
en:
 System language
 1- Simplified Chinese
 2- Traditional Chinese
 3- English
 4-Vietnamese
 5-Thai
 */
/**
cn:
 系统语言
 1-简体中文
 2-繁体中文
 3-英文
 4-越南语
 5-泰语
 */
@property (nonatomic, assign) int systemLanguage;

- (NSDictionary *)dicFromObject;

@end
