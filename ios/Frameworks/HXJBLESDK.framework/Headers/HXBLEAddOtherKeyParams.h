//
//  HXBLEAddOtherKeyParams.h
//  SmartHomeSDK
//
//  Created by JQ on 2019/4/4.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import "HXBLEAddKeyBaseParams.h"

/** Bluetooth add fingerprint/card/remote key request parameter */
/** 蓝牙添加指纹/卡片/遥控钥匙请求参数 */
@interface HXBLEAddOtherKeyParams : HXBLEAddKeyBaseParams

/**
en:
 Required
 The type of key being added,
 The types that can be set include KSHKeyType_Fingerprint, KSHKeyType_Card, KSHKeyType_RemoteControl
 */
/**
cn:
 必填
 被添加的钥匙类型，
 可设置的类型包括KSHKeyType_Fingerprint、KSHKeyType_Card、KSHKeyType_RemoteControl
 */
@property (nonatomic, assign) KSHKeyType keyType;

/**
en:
 Optional
 When keyType == KSHKeyType_Card,
 If cardId is not empty, it means to add by card number. If cardId is nil, it means swipe card to add.
 Card Id added
 Length: 6~12 digits, only 0~9 digits can be set
 */
/**
cn:
 可选
 当keyType == KSHKeyType_Card时，
 如果cardId不为空，表示按卡号添加。如果cardId为nil表示刷卡添加。
 添加的10进制卡片Id
 keyDataType == 0 是，cardId字符串长度限制为6~12位
 keyDataType == 1 时，cardId字符串长度最长限制为12位，填写卡号16进制字符串，如 AABBCC11
 */
@property (nonatomic, strong) NSString *cardId;

/**
 当keyType == KSHKeyType_Card时有效
 1：表示卡片内容为16进制字符串
 0：表示卡片内容为10进制字符串
 */
@property (nonatomic, assign) int keyDataType;

@end

