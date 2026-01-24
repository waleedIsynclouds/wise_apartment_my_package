//
//  HXLockNetSystemFunctionModel.h
//  HXJBLESDK
//
//  Created by JQ on 2020/7/27.
//  Copyright © 2020 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Functional definition of engineering lock networking
/// 工程锁联网方面功能定义
@interface HXLockNetSystemFunctionModel : NSObject

- (instancetype)initWithLockNetSystemFunction:(long)lockNetSystemFunction;

///en:
/// Whether to support local menu
/// 0x00: not supported
/// 0x01: Support

///cn:
/// 是否支持本地菜单
/// 0x00：不支持
/// 0x01：支持
@property (nonatomic, assign) int supportLocalMenu;

///en:
/// Whether to support setting the door lock heartbeat interval time
/// 0x00: not supported
/// 0x01: Support

///cn:
/// 是否支持设置门锁心跳间隔时间
/// 0x00：不支持
/// 0x01：支持
@property (nonatomic, assign) int supportSetHeartBeat;

///en:
/// Whether to support remote query of local key details
/// 0x00: not supported
/// 0x01: Support

///cn:
/// 是否支持远程查询本地钥匙明细
/// 0x00：不支持
/// 0x01：支持
@property (nonatomic, assign) int supportRemoteQueryKeyList;

/// 是否支持所有者、管理员、普通用户三种类型
/// 如果支持，则按照钥匙类型删除钥匙不会删除掉管理员和所有者的钥匙
/// 0x00：不支持
/// 0x01：支持
@property (nonatomic, assign) int supportLockUserType;

/// 是否支持周期性开锁开启设置
/// 0x00：不支持
/// 0x01：支持
@property (nonatomic, assign) int supportCycleNormallyOpen;

/// 是否支持身份证云解析
/// 0：不支持
/// 1：支持
@property (nonatomic, assign) int supportIDCard;

/// 是否支持设置人体感应（红外/雷达）灵敏度
@property (nonatomic, assign) int supportSetFaceLockBodyDetectionSensitivity;

/// 是否支持的人脸模组类型
/// 0：不支持
/// 1：支持
@property (nonatomic, assign) int supportFaceModuleType;

/// 是否支持设置钥匙到期语音提醒
/// 0：不支持
/// 1：支持
@property (nonatomic, assign) int supportExpirationAlarmTime;

@end

NS_ASSUME_NONNULL_END
