//
//  HXBLESecureAuthProtocol.h
//  HXJBLESDK
//
//  Created by JQ on 2021/7/23.
//  Copyright © 2021 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///en:
/// Security authentication protocol:
/// When the App cannot obtain the Bluetooth lock authentication code and DNA key, the method defined below needs to be implemented to realize the secure communication between the App and the Bluetooth lock

///cn:
/// 安全认证协议：
/// 当App无法获取到蓝牙锁鉴权码和DNA密钥时，需实现以下定义的方法，以实现App与蓝牙锁的安全通信
@protocol HXBLESecureAuthProtocol <NSObject>

@required

///en:
/// SessionId command encoding (App implements this method to obtain sessionIdCmd from the server and returns the result to SDK)
/// @param keyGroupId User Id, as a parameter to request sessionIdCmd from the server
/// @param snr packet sequence number, as a parameter to request sessionIdCmd from the server
/// @param lockMac door lock Mac
/// @param block returns the requested command to the SDK, if it fails, it returns nil

///cn:
/// SessionId命令编码（App实现该方法向服务器获取sessionIdCmd，将结果返回给SDK）
/// @param keyGroupId 用户Id，作为向服务器请求sessionIdCmd的参数
/// @param snr 包序号，作为向服务器请求sessionIdCmd的参数
/// @param lockMac 门锁Mac
/// @param block 返回请求到的命令给SDK，如果失败返回nil
- (void)getSessionIdCmdWithKeyGroupId:(int)keyGroupId
                                  snr:(int)snr
                              lockMac:(NSString *)lockMac
                     complectionBlock:(void(^)(NSString * _Nullable sessionIdCmd))block;

///en:
/// SessionId command decoding (App implements this method to request the server to parse the sessionIdPlayload, and return the parsed sessionId to the SDK)
/// @param lockMac door lock Mac
/// @param sessionIdPlayload the data to be decoded
/// @param block returns the requested sessionId to the SDK, if it fails, it returns nil

///cn:
/// SessionId命令解码（App实现该方法向服务器请求解析sessionIdPlayload，将解析到的sessionId返回给SDK）
/// @param lockMac 门锁Mac
/// @param sessionIdPlayload 待解码的数据
/// @param block 返回请求到的sessionId给SDK，如果失败返回nil
- (void)parseSessionIdWithLockMac:(NSString *)lockMac
                sessionIdPlayload:(NSString *)sessionIdPlayload
                 complectionBlock:(void(^)(NSString * _Nullable sessionId))block;

///en:
/// AES128 key command encoding (App implements this method to obtain aesKeyCmd from the server and return the result to SDK)
/// @param keyGroupId User Id, as a parameter to request aesKeyCmd from the server
/// @param snr packet sequence number, as a parameter to request aesKeyCmd from the server
/// @param sessionId Session ID, as a parameter to request aesKeyCmd from the server
/// @param lockMac door lock Mac
/// @param block returns the requested command to the SDK, if it fails, it returns nil

///cn:
/// AES128密钥命令编码（App实现该方法向服务器获取aesKeyCmd，将结果返回给SDK）
/// @param keyGroupId 用户Id，作为向服务器请求aesKeyCmd的参数
/// @param snr 包序号，作为向服务器请求aesKeyCmd的参数
/// @param sessionId 会话ID，作为向服务器请求aesKeyCmd的参数
/// @param lockMac 门锁Mac
/// @param block 返回请求到的命令给SDK，如果失败返回nil
- (void)getAESKeyCmdWithKeyGroupId:(int)keyGroupId
                               snr:(int)snr
                         sessionId:(NSString *)sessionId
                           lockMac:(NSString *)lockMac
                  complectionBlock:(void(^)(NSString * _Nullable aesKeyCmd))block;

///en:
/// AES128 key command decoding (App implements this method to request the server to parse the aesKeyPlayload, and return the parsed aesKey to the SDK)
/// @param lockMac door lock Mac
/// @param aesKeyPlayload The data to be decoded
/// @param block returns the requested sessionId to the SDK, if it fails, it returns nil

///cn:
/// AES128密钥命令解码（App实现该方法向服务器请求解析aesKeyPlayload，将解析到的aesKey返回给SDK）
/// @param lockMac 门锁Mac
/// @param aesKeyPlayload 待解码的数据
/// @param block 返回请求到的sessionId给SDK，如果失败返回nil
- (void)parseAESKeyWithLockMac:(NSString *)lockMac
                aesKeyPlayload:(NSString *)aesKeyPlayload
              complectionBlock:(void(^)(NSString * _Nullable aesKey))block;

///en:
/// Authentication command code (App implements this method to obtain authCmd from the server and returns the result to SDK)
/// @param keyGroupId User Id, as a parameter to request authCmd from the server
/// @param snr packet sequence number, as a parameter for requesting authCmd from the server
/// @param sessionId Session ID, as a parameter for requesting authCmd from the server
/// @param aesKey aes key, as a parameter to request authCmd from the server
/// @param lockMac door lock Mac
/// @param block returns the requested command to the SDK, if it fails, it returns nil

///cn:
/// 鉴权命令编码（App实现该方法向服务器获取authCmd，将结果返回给SDK）
/// @param keyGroupId 用户Id，作为向服务器请求authCmd的参数
/// @param snr 包序号，作为向服务器请求authCmd的参数
/// @param sessionId 会话ID，作为向服务器请求authCmd的参数
/// @param aesKey aes密钥，作为向服务器请求authCmd的参数
/// @param lockMac 门锁Mac
/// @param block 返回请求到的命令给SDK，如果失败返回nil
- (void)getAuthCmdWithKeyGroupId:(int)keyGroupId
                             snr:(int)snr
                       sessionId:(NSString *)sessionId
                          aesKey:(NSString *)aesKey
                         lockMac:(NSString *)lockMac
                complectionBlock:(void(^)(NSString * _Nullable authCmd))block;

@end

NS_ASSUME_NONNULL_END
