//
//  SHBLENetworkConfigParam.h
//  SmartHomeSDK
//
//  Created by JQ on 2021/7/1.
//  Copyright © 2021 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHGlobalHeader.h"

NS_ASSUME_NONNULL_BEGIN

/// Wi-Fi module configuration to the network
/// Wi-Fi模组配置入网
@interface SHBLENetworkConfigParam : NSObject

/// 是否需要监听配网接口回调结果，默认为NO，表示通过通知方式获取配网接口；
@property (nonatomic, assign) BOOL needListenCallbackStatus;

/// Bluetooth lock mac
/// 蓝牙锁Mac
@property (nonatomic, copy) NSString *lockMac;

/// en:
///  Configuration type:
///  1 Configure the connection server,
///  2 Configure to connect to Wi-Fi,
///  3 Configure to connect to Wi-Fi and connect to the server;
///
/// cn:
///  配置类型：
///  1 配置连接服务器，
///  2 配置连接Wi-Fi，
///  3 配置连接Wi-Fi和连接服务器；
@property (nonatomic, assign) int configType;

/// en:
///  Whether to update tokenId, YES: update, NO: not update
///  Configure the connection server updateTokenId must be set to YES
///
/// cn:
///  是否更新tokenId，YES：更新，NO：不更新
///  配置连接服务器updateTokenId必须设置为YES
@property (nonatomic, assign) BOOL updateTokenId;

/// en:
///  The tokenId of the connection server, [updateTokenId is valid for YES]
///
/// cn:
/// 由服务器分配，连接服务器的tokenId，【updateTokenId为YES有效】
@property (nonatomic, copy) NSString *tokenId;

/// en:
///  Wi-Fi wireless network name, [valid when the configuration type is 2 or 3]
///  Up to 32 characters
///
/// cn:
///  Wi-Fi无线网络名称，【配置类型为2或3时有效】
///  最长32个字符
@property (nonatomic, copy) NSString *ssid;

/// en:
///  Wi-Fi wireless network password, [valid when the configuration type is 2 or 3]
///  Length 8~16 bits
///
/// cn:
///  Wi-Fi无线网络密码，【配置类型为2或3时有效】
///  长度8~16位
@property (nonatomic, copy) NSString *password;

/// en:
///  The address of the connecting server, [valid when the configuration type is 1 or 3]
///
/// cn:
/// 连接服务器的地址，【配置类型为1或3时有效】
@property (nonatomic, copy) NSString *host;

/// en:
/// Port to connect to the server, [valid when the configuration type is 1 or 3]
///
/// cn:
/// 连接服务器的端口，【配置类型为1或3时有效】
@property (nonatomic, assign) int port;

/// en:
/// Whether to obtain IP automatically, YES: Obtain automatically, NO: Obtain manually
///
/// cn:
/// 是否自动获取IP，YES：自动获取，NO：手动获取
@property (nonatomic, assign) BOOL autoGetIP;

/// en:
/// Manually configured IP
///
/// cn:
/// 手动配置的IP，
@property (nonatomic, copy) NSString *ip;

/// en:
/// Subnet mask
///
/// cn:
/// 子网掩码
@property (nonatomic, copy) NSString *subnetwork;

/// en:
/// Router address
///
/// cn:
/// 路由器地址
@property (nonatomic, copy) NSString *routerIP;

@end

NS_ASSUME_NONNULL_END
