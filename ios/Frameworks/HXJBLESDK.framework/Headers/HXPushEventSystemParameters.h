//
//  HXPushEventSystemParameters.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/24.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import "HXPushEventBase.h"

/**
en:
 System parameter setting event reporting (KSHEventType_SystemParameterSetting)
 */
/**
cn:
 系统参数设置事件上报(KSHEventType_SystemParameterSetting)
 */
@interface HXPushEventSystemParameters : HXPushEventBase

/**
en:
 The key Id of the operator, this parameter may always be 0 (that is, an invalid parameter)
 */
/**
cn:
 操作人的钥匙Id，该参数可能一直为0（即无效参数）
 */
@property (nonatomic, assign) int operLockKeyId;

/**
en:
 Unlock mode,
 0-No unlock mode setting function
 1- Single unlock;
 2- Combination unlock;
 */
/**
cn:
 开锁模式,
 0-无开锁模式设置功能
 1-单一开锁;
 2-组合开锁;
 */
@property (nonatomic, assign) int openMode;

/**
en:
 Normally open mode
 0-No normally open mode setting function
 1- Enable normally open mode;
 2- Close the normally open mode;
 */
/**
cn:
 常开模式
 0-无常开模式设置功能
 1-启用常开模式;
 2-关闭常开模式；
 */
@property (nonatomic, assign) int normallyOpenMode;

/**
en:
 Voice opening and closing
 0- irrelevant door opening and closing function setting;
 1- Open the door opening voice;
 2- Turn off the door opening voice;
 */
/**
cn:
 开门语音启闭
 0-无关门启闭功能设置；
 1-打开开门语音;
 2-关闭开门语音；
 */
@property (nonatomic, assign) int volumeEnable;

/**
en:
 System volume
 0- means the volume cannot be adjusted.
 */
/**
cn:
 系统音量
 0-表示音量不可调节.
 */
@property (nonatomic, assign) int systemVolume;

/**
en:
 Anti-pry alarm opening and closing,
 0-No anti-pry alarm function;
 1—The anti-pry alarm is activated;
 2- The tamper-proof alarm function is turned off;
 */
/**
cn:
 防撬报警启闭，
 0-无防撬报警功能;
 1—防撬报警启动;
 2-防撬报警功能关闭；
 */
@property (nonatomic, assign) int shackleAlarmEnable;

/**
en:
 Lock cylinder alarm opening and closing
 0-No lock core alarm function;
 1—The lock cylinder alarm starts;
 2- The lock cylinder alarm function is off
 */
/**
cn:
 锁芯报警启闭
 0-无锁芯报警功能;
 1—锁芯报警启动;
 2-锁芯报警功能关闭
 */
@property (nonatomic, assign) int lockCylinderAlarmEnable;

/**
en:
 Anti-lock function open and close,
 0-No anti-lock switch;
 1- The anti-lock switch is turned on,
 2- The anti-lock switch is off
 */
/**
cn:
 反锁功能启闭,
 0-无反锁开关;
 1-反锁开关打开，
 2-反锁开关关闭
 */
@property (nonatomic, assign) int antiLockEnable;

/**
en:
 Alarm opening and closing of the lock cover,
 0-No lock cover switch;
 1- Enable the lock cover alarm;
 2-Prohibit the lock cover alarm
 */
/**
cn:
 锁头盖报警启闭，
 0-无锁头盖开关;
 1-启用锁头盖报警;
 2-禁止锁头盖报警
 */
@property (nonatomic, assign) int lockCoverAlarmEnable;

/**
en:
 System language
 1 Simplified Chinese
 2 Traditional Chinese
 3 English
 4 Vietnamese
 5 Thai
 */
/**
cn:
 系统语言
 1     简体中文
 2     繁体中文
 3     英文
 4     越南语
 5     泰语
 */
@property (nonatomic, assign) int systemLanguage;

- (NSDictionary *)dicFromObject;

@end
