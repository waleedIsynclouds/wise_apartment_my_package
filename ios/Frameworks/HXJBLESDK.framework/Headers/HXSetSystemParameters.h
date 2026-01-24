//
//  HXSetSystemParameters.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/22.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Set system parameter request parameter */
/** 设置系统参数请求参数 */
@interface HXSetSystemParameters : NSObject

/**
en:
 Required,
 The mac of the Bluetooth lock is used to judge when sending a command to the specified device
 */
/**
cn:
 必填，
 蓝牙锁的mac，用于发送命令时判断发送给指定的设备
 */
@property (nonatomic, copy) NSString *lockMac;

/**
en:
 Optional
 Unlock mode,
 1: Single unlock;
 2: Combination unlock;
 */
/**
cn:
 可选
 开锁模式,
 1：单一开锁;
 2：组合开锁;
 */
@property (nonatomic, assign) int openMode;

/**
en:
 Optional
 Normally open mode
 1: Enable normally open mode;
 2: Disable normally open mode;
 */
/**
cn:
 可选
 常开模式
 1：启用常开模式;
 2：关闭常开模式；
 */
@property (nonatomic, assign) int normallyOpenMode;

/**
en:
 Optional
 Voice enable or disable
 1: enable the door opening voice;
 2: disable the door opening voice;
 */
/**
cn:
 可选
 开门语音启闭
 1：打开开门语音;
 2：关闭开门语音；
 */
@property (nonatomic, assign) int volumeEnable;

/**
en:
 Optional
 Volume (most door lock does not support volume settings)
 0: Do not change the volume setting;
 Other values: Change to the corresponding volume;
 */
/**
cn:
 可选
 音量（大部分门锁不支持音量设置）
 0：不更改音量设置;
 其它值：更改为相应的音量；
 */
@property (nonatomic, assign) int systemVolume;

/**
en:
 Optional
 Anti-smash alarm is closed,
 1: Start the anti-smashing alarm;
 2: Turn off the anti-smash alarm function;
 */
/**
cn:
 可选
 防撬报警启闭，
 1：启动防撬报警；
 2：关闭防撬报警功能；
 */
@property (nonatomic, assign) int shackleAlarmEnable;

/**
en:
 Optional
 Lock core alarm is closed
 0: Do not change the lock-locking core alarm function;
 1: Enble the lock core alarm;
 2: Disable the lock core alarm;
 */
/**
cn:
 可选
 锁芯报警启闭
 0：不更改无锁芯报警功能;
 1：启动锁芯报警;
 2：关闭锁芯报警功能
 */
@property (nonatomic, assign) int lockCylinderAlarmEnable;

/**
en:
 Optional
 The anti-lock function is open,
 1: Open the switch lock switch,
 2: Close the anti-lock switch
 */
/**
cn:
 可选
 反锁功能启闭,
 1：打开反锁开关，
 2：关闭反锁开关
 */
@property (nonatomic, assign) int antiLockEnable;

/**
en:
 Optional
 Alarm opening and closing of the lock cover,
 1: Enable the lock cover alarm;
 2: Disable the lock cover alarm;
 */
/**
cn:
 可选
 锁头盖报警启闭，
 1：启用锁头盖报警;
 2：禁止锁头盖报警
 */
@property (nonatomic, assign) int lockCoverAlarmEnable;

/**
en:
 Optional
 System language
 1 Simplified Chinese
 2 Traditional Chinese
 3 English
 4 Vietnamese
 5 Thai
 */
/**
cn:
 可选
 系统语言
 1     简体中文
 2     繁体中文
 3     英文
 4     越南语
 5     泰语
 */
@property (nonatomic, assign) int systemLanguage;

/**
 顶替功能
 0x00：不更改
 0x01：开启顶替功能
 0x02：关闭顶替功能呢
 */
@property (nonatomic, assign) int replaceSet;

/**
 防复制使能
 0x00：不更改设置
 0x01：开启防复制
 0x02：关闭防复制
 */
@property (nonatomic, assign) int antiCopyFunction;

/**
 试错告警使能
 0x00：不更改设置
 0x01：开启试错告警(默认状态）
 0x02：关闭试错告警
 */
@property (nonatomic, assign) int keyTrialErrorAlarmEn;

/**
 未关门告警语音使能
 0x00：不更改设置
 0x01：开启未关门声光告警(默认状态）
 0x02：关闭未关门声光告警
 注意，未关门告警只是关闭了声光提醒，但事件依然会上报
 */
@property (nonatomic, assign) int noneCloseVoiceAlarmEn;

@end
