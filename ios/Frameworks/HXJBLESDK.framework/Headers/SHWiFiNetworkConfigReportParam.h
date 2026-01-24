//
//  SHWiFiNetworkConfigReportParam.h
//  SmartHomeSDK
//
//  Created by JQ on 2020/3/4.
//  Copyright © 2020 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SHWiFiNetworkConfigReportParam : NSObject

/**
 0x04：WiFi模组连接路由器成功
 0x05：WiFi模组连接云端成功
 0x06：密码错误
 0x07：WiFi配置超时
 0x08：设备连接服务器失败
 0x09：设备不合法
 */
@property (nonatomic, assign) int wifiStatus;


/// 设备登录服务器的唯一标识（该值可能会与设备实际登录服务器的Mac不一致，如果会出现该情况时，请使用originalRfModuleMac截取固定长度获取设备登录服务器的唯一标识）
@property (nonatomic, strong) NSString *rfModuleMac;
@property (nonatomic, strong) NSString *originalRfModuleMac;

@property (nonatomic, strong) NSString *lockMac;

@end

NS_ASSUME_NONNULL_END
