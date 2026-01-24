//
//  HXBLEAddPasswordKeyParams.h
//  SmartHomeSDK
//
//  Created by JQ on 2019/4/4.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import "HXBLEAddKeyBaseParams.h"

/** Bluetooth add password request parameter */
/** 蓝牙添加密码请求参数 */
@interface HXBLEAddPasswordKeyParams : HXBLEAddKeyBaseParams

/**
en:
 Required
 Added password
 Password: 6-12 digits, only 0-9 digits can be set
 */
/**
cn:
 必填
 添加的密码
 密码：6~12位，只能设置0~9的数字
 */
@property (nonatomic, strong) NSString *key;

@end

