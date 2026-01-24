//
//  HXLockSystemFunctionModel.h
//  HXJBLESDK
//
//  Created by JQ on 2020/7/27.
//  Copyright © 2020 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Engineering lock system function definition
/// 工程锁系统功能定义
@interface HXLockSystemFunctionModel : NSObject

- (instancetype)initWithLockSystemFunction:(long)lockSystemFunction;

///en:
/// Allow the master card to unlock
/// 0x00: not supported
/// 0x01: Allow
/// 0x02: prohibited

///cn:
/// 允许总卡开锁
/// 0x00：不支持
/// 0x01：允许
/// 0x02：禁止
@property (nonatomic, assign) int cardFunctionEnable;

///en:
/// Electronic lock
/// 0x00: not supported
/// 0x01: open
/// 0x02: Close

///cn:
/// 电子反锁
/// 0x00：不支持
/// 0x01：开启
/// 0x02：关闭
@property (nonatomic, assign) int antiLock;

///en:
/// Replacement function
/// 0x00: not supported
/// 0x01: enable
/// 0x02: disable

///cn:
/// 顶替功能
/// 0x00：不支持
/// 0x01：使能
/// 0x02：禁用
@property (nonatomic, assign) int replaceFunction;

///en:
/// Push down the door handle to close the lock
/// 0x00: not supported
/// 0x01: enable
/// 0x02: disable

///cn:
/// 下压门把手关锁
/// 0x00：不支持
/// 0x01：使能
/// 0x02：禁用
@property (nonatomic, assign) int pressDoorknobUnlock;

///en:
/// Password enable
/// 0x00: not supported
/// 0x01: enable
/// 0x02: disable

///cn:
/// 密码使能
/// 0x00：不支持
/// 0x01：使能
/// 0x02：禁用
@property (nonatomic, assign) int passwordEnable;

///en:
/// Motor rotation direction
/// 0x00: not supported
/// 0x01: forward rotation
/// 0x02: Reverse

///cn:
/// 电机转动方向
/// 0x00：不支持
/// 0x01：正转
/// 0x02：反转
@property (nonatomic, assign) int motorDirection;

///en:
/// Anti-lock line selection
/// 0x00: not supported
/// 0x01: backlock
/// 0x02: tongue

///cn:
/// 反锁线选择
/// 0x00：不支持
/// 0x01：backlock
/// 0x02：tongue
@property (nonatomic, assign) int antiLockLine;

///en:
/// Diagonal line selection
/// 0x00: not supported
/// 0x01: backlock
/// 0x02: tongue

///cn:
/// 斜舌线选择
/// 0x00：不支持
/// 0x01：backlock
/// 0x02：tongue
@property (nonatomic, assign) int tongueLine;

///en:
/// Unlock voice
/// 0x00: not supported
/// 0x01: The unlocking voice is on
/// 0x02: Turn off the unlocking voice

///cn:
/// 开锁语音
/// 0x00：不支持
/// 0x01：开锁语音开启
/// 0x02：开锁语音关闭
@property (nonatomic, assign) int unlockVoice;

///en:
/// Normally open mode
/// 0x00: not supported
/// 0x01: enable
/// 0x02: disable

///cn:
/// 常开模式
/// 0x00：不支持
/// 0x01：启用
/// 0x02：禁用
@property (nonatomic, assign) int normalOpenMode;

///en:
/// Card sensitivity
/// 0x00: does not support modification
/// 0x01 ~ 0x05: the higher the more sensitive

///cn:
/// 卡片灵敏度
/// 0x00：不支持修改
/// 0x01 ~ 0x05：越高越灵敏
@property (nonatomic, assign) int cardSensitivity;

///en:
/// Set key function
/// 0x00: does not support modification
/// 0x01: No function takes effect
/// 0x02: Only the initialization detection function is effective
/// 0x03: Only the mechanical key unlocking detection function is valid;
/// Choose one of 0x02 initialization and 0x03 mechanical key unlock detection function.

///cn:
/// 设置按键功能
/// 0x00：不支持修改
/// 0x01：不生效任何功能
/// 0x02：只生效初始化检测功能
/// 0x03：只生效机械钥匙开锁检测功能；
/// 0x02初始化和0x03机械钥匙开锁检测功能二选一。
@property (nonatomic, assign) int setKeyFunction;

/// 本地修改离线密码，输入：14#原密码#新密码
/// 0x00：不支持
/// 0x01：支持
@property (nonatomic, assign) int localModifyOfflinePassword;

/// 是否支持离线周期密码
/// 0x00：支持
/// 0x01：不支持
@property (nonatomic, assign) int supportOfflineCyclePassword;

/// 是否支持自动删除过期自定义钥匙和离线密码
/// 0x00：过期的自定义钥匙门锁不会自动删除，只有过期的离线密码会被门锁自动删除
/// 0x01：过期的自定义密码和离线密码都会被门锁自动删除
/// 注意：当钥匙被顶替时，或者钥匙有效次数变为0时，这些钥匙都会被自动删除
@property (nonatomic, assign) int autoDeleteKey;

/// 防复制卡功能
/// 0x00：不支持设置 M1 防复制功能
/// 0x01：开启防复制
/// 0x02：关闭防复制
@property (nonatomic, assign) int m1CopyProtectionFlag;

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

NS_ASSUME_NONNULL_END
