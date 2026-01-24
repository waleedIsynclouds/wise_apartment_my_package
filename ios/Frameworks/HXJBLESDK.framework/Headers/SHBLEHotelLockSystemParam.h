//
//  SHSetHotelLockSystemParam.h
//  SmartHomeSDK
//
//  Created by JQ on 2022/9/13.
//  Copyright © 2022 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SHBLEHotelLockSystemParam : NSObject<NSCopying>

/// 门锁Mac，必填
@property (nonatomic, copy) NSString *lockMac;

/// 常开模式
/// 0x00: 不修改/不支持；
/// 0x01: 常开模式；
/// 0x02: 正常模式；
@property (nonatomic, assign) int normallyOpenMode;

/// 开锁语音
/// 0x00：不修改/不支持
/// 0x01：开门语音开启
/// 0x02：开门语音关闭
@property (nonatomic, assign) int volumeEnable;

/// 斜舌线选择
/// 0x00：不修改/不支持
/// 0x01：BACKLOCK
/// 0x02：TONGUE
@property (nonatomic, assign) int tongueChoose;

/// 反锁线选择
/// 0x00：不修改/不支持
/// 0x01：BACKLOCK
/// 0x02：TONGUE
@property (nonatomic, assign) int backLockChoose;

/// 电机转动方向
/// 0x00：不修改/不支持
/// 0x01：正转
/// 0x02：反转
@property (nonatomic, assign) int motorDirection;

/// 密码使能
/// 0x00：不修改/不支持
/// 0x01：使能
/// 0x02：禁用
@property (nonatomic, assign) int passwordEnable;

/// 下压把手关锁(斜舌检测)
/// 0x00：不修改/不支持
/// 0x01：使能
/// 0x02：禁用
@property (nonatomic, assign) int tongueDetection;

/// 顶替设置
/// 0x00：不修改/不支持
/// 0x01：使能
/// 0x02：禁用
@property (nonatomic, assign) int replaceSet;

/// 电机驱动时间
/// 0x00：不修改/不支持
/// 0x01~0xff：10ms~2.55S
@property (nonatomic, assign) int motorDriveTime;

/// 开锁时间
/// 0x00: 不修改/不支持
/// 0x01~0x10:1~16S
/// 表示开锁后等待16S的时间
@property (nonatomic, assign) int lockOpenTime;

/// 检卡灵敏度
/// 0x00：不修改/不支持
/// 0x01~0x05：越高越灵敏
@property (nonatomic, assign) int cardDetectiongSensitivity;

/// 密码灵敏度
/// 0x00：不修改/不支持
/// 0x01~0x05：越高越灵敏
@property (nonatomic, assign) int passwordSensitivity;

/// 蓝牙连接间隔
/// 0x00：不修改/不支持
/// 0x01：关闭蓝牙（需点亮屏幕开蓝牙广播）
/// 0x02：1S四次 n 0x03：1S三次
/// 0x04：1S两次 n 0x05：1S一次
/// 0x06：2S一次
@property (nonatomic, assign) int bleConnectInterval;

/// 设置按键功能
/// 0x00：不修改/不支持
/// 0x01：不生效任何功能
/// 0x02：只生效初始化检测功能
/// 0x03：只生效机械钥匙开锁检测功能；
/// 注意：初始化和机械钥匙开锁检测功能二选一
@property (nonatomic, assign) int setKeyFunction;

/// 低压情况下增强驱动时间
/// 0x00: 不修改/不支持
/// 0x01~0xFF：单位为10ms
@property (nonatomic, assign) int lowpowerMotorDriverTimeAdd;

/// 到期语音提醒
/// 注意：只有在lockNetSystemFunction 第24个比特位值为1才支持设置
/// 0: 不修改到期提醒功能 / 不支持该功能
/// 255：关闭到期提醒功能
/// 1~30：提前1天 ~ 30天内报到期提醒
/// 其他值：无效，设置后会返回参数无效
///
/// 语音说明：
/// ① 未到期的时候播报：
/// 开锁钥匙剩余x天到期，请续租
/// ②到期后播放：
/// 开锁钥匙已经到期，请续租
@property (nonatomic, assign) int expirationAlarmTime;

@end

NS_ASSUME_NONNULL_END
