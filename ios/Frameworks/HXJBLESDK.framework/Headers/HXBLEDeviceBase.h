//
//  HXBLEDeviceBase.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/23.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHGlobalHeader.h"
#import "HXLockSystemFunctionModel.h"
#import "HXLockNetSystemFunctionModel.h"

/**
en:
 Bluetooth lock information base class
 */
/**
cn:
 蓝牙锁信息基类
 */
@interface HXBLEDeviceBase : NSObject

/**
 DNA信息字符串，供服务器端使用
 */
@property (nonatomic, copy) NSString *deviceDnaInfoStr;

/**
en:
 Hardware version number
 */
/**
cn:
 硬件版本号
 */
@property (nonatomic, copy) NSString *hardwareVersion;

/**
en:
 Firmware version (software version)
 */
/**
cn:
 固件版本（软件版本）
 */
@property (nonatomic, copy) NSString *firmwareVersion;

/**
en:
 Bluetooth lock protocol version
 */
/**
cn:
 蓝牙锁协议版本
 */
@property (nonatomic, assign) int bleProtocolVersion;

/**
en:
 The type of wireless module connected to the Bluetooth lock
 */
/**
cn:
 蓝牙锁外接的无线模组类型
 */
@property (nonatomic, assign) kHXRFModuleType rfModuleType;

/**
en:
 For door lock characteristics, please refer to kHXLockFunctionType for the meaning of corresponding bits
 */
/**
cn:
 门锁特性，对应bit位的含义请见kHXLockFunctionType
 */
@property (nonatomic, assign) kHXLockFunctionType lockFunctionType;

/**
en:
 The maximum volume of the Bluetooth lock, generally 5
 */
/**
cn:
 蓝牙锁最大音量，一般为5
 */
@property (nonatomic, assign) int maxVolume;

/**
en:
 Maximum number of users that can be created
 */
/**
cn:
 最大可创建的用户数
 */
@property (nonatomic, assign) int maxUser;

/**
en:
 RF module MAC address
 */
/**
cn:
 RF模块MAC地址
 */
@property (nonatomic, copy) NSString *rfModuleMac;

/**
en:
 Wireless module function
 */
/**
cn:
 无线模组功能
 */
@property (nonatomic, assign) kHXRFModuleFunction rfModuleFunction;

/**
en:
 Bluetooth wake frequency
 0x00: Do not modify
 0x01: Turn off Bluetooth (need to light up the screen to turn on Bluetooth broadcast)
 0x02: 1S four times
 0x03: 1S three times
 0x04: 1S twice (default value, this is when the field is missing)
 0x05: 1S once
 0x06: 2S once
 */
/**
cn:
 蓝牙唤醒频率
 0x00：不修改
 0x01：关闭蓝牙（需点亮屏幕开蓝牙广播）
 0x02：1S四次
 0x03：1S三次
 0x04：1S两次（默认值，字段缺醒的时候是这个）
 0x05：1S一次
 0x06：2S一次
 */
@property (nonatomic, assign) int bleActiveTimes;

/**
en:
 Wireless module software version number
 */
/**
cn:
 无线模组软件版本号
 */
@property (nonatomic, strong) NSString *rfMoudleSoftwareVer;

/**
en:
 Wireless module hardware version number
 */
/**
cn:
 无线模组硬件版本号
 */
@property (nonatomic, strong) NSString *rfMoudleHarewareVer;

/**
en:
 When the password is valid, the largest numeric key word
 0x00: valid password range 0~9 (default)
 0x08: valid password range 0~8
 0x07: valid password range 0~7
 …
 0x04: valid password range 0~4
 */
/**
cn:
 密码有效的情况下，最大的数字按键字
 0x00：有效密码范围0~9（默认）
 0x08：有效密码范围0~8
 0x07：有效密码范围0~7
 …
 0x04：有效密码范围0~4
 */
@property (nonatomic, assign) int passwordNumRange;

/**
en:
 Offline password version
 Default or 0x00: indicates the current online password
 0x02: Only one-time passwords are supported, and other types of offline passwords are not supported
 0xff: indicates that offline algorithm passwords are not supported
 */
/**
cn:
 离线密码版本
 缺省或0x00：表示为当前已经上线的密码
 0x02：只支持一次性密码，不支持其它类型的离线密码
 为0xff：表示不支持离线算法密码
 */
@property (nonatomic, assign) int offlinePasswordVer;

/**
en:
 This field is meaningful only when the door lock supports the system language setting.
 1.
 Value is 0: Indicates that the languages ​​supported by the door lock are simplified Chinese and English
 2.
 Non-zero: the corresponding bit is 1, indicating that the door lock supports the corresponding language:
 bit0: Simplified Chinese
 bit1: Traditional Chinese
 bit2: English
 bit3: Vietnamese

 For example: a value of 5: indicates that the Bluetooth lock supports simplified Chinese and English
 */
/**
cn:
 只有当门锁支持系统语言设置时, 此字段才有意义。
 一、
 值为0: 表示门锁支持的语言为简体中文和英文
 二、
 非0：对应bit为1表示门锁支持相应语言:
 bit0：简体中文
 bit1：繁体中文
 bit2：英文
 bit3：越南语

 例如：值为5：表示蓝牙锁支持简体中文和英文
 */
@property (nonatomic, assign) long supportedSystemLanguage;

/// Bluetooth lock menu properties
/// 蓝牙锁菜单属性
@property (nonatomic, assign) kHXMenuFeature menuFeature;

/// Engineering lock system function definition, the specific meaning of the data can be parsed through the'resolveLockSystemFunction:' method
/// 工程锁系统功能定义，可通过 'resolveLockSystemFunction:' 方法解析得到数据的具体含义
@property (nonatomic, assign) long lockSystemFunction;

/// The function definition of engineering lock networking can be parsed through the'resolveLockNetSystemFunction:' method to get the specific meaning of the data
/// 工程锁联网方面功能定义，可通过 'resolveLockNetSystemFunction:' 方法解析得到数据的具体含义
@property (nonatomic, assign) long lockNetSystemFunction;


///en:
/// Analyze lockSystemFunction to get the specific meaning of the data
/// @param lockSystemFunction 0 indicates that the data is invalid
/// @return return value, if it is nil, the data is invalid

///cn:
/// 解析lockSystemFunction，得到数据的具体含义
/// @param lockSystemFunction 0表示数据无效
/// @return 返回值，如果为nil表示数据无效
- (HXLockSystemFunctionModel *)resolveLockSystemFunction:(long)lockSystemFunction;


///en:
/// Analyze lockNetSystemFunction to get the specific meaning of the data
/// @param lockNetSystemFunction 0 indicates that the data is invalid
/// @return return value, if it is nil, the data is invalid

///cn:
/// 解析lockNetSystemFunction，得到数据的具体含义
/// @param lockNetSystemFunction 0表示数据无效
/// @return 返回值，如果为nil表示数据无效
- (HXLockNetSystemFunctionModel *)resolveLockNetSystemFunction:(long)lockNetSystemFunction;

- (NSDictionary *)dicFromObject;

@end

