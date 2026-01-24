//
//  SHAdvertisementModel.h
//  JQBluetooth
//
//  Created by JQ on 2017/11/15.
//  Copyright © 2017年 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
en:
 Bluetooth lock broadcast data
 */
/**
cn:
 蓝牙锁广播数据
 */
@interface SHAdvertisementModel : NSObject<NSCopying>

/**
en:
 Bluetooth lock  Mac
 */
/**
cn:
 蓝牙锁Mac
 */
@property (nonatomic, copy) NSString *mac;

/**
en:
 YES: has been added, NO: has not been added
 */
/**
cn:
 YES:已经被添加，NO:未被添加
 */
@property (nonatomic, assign) BOOL isPairedFlag;

/**
en:
 YES: discovery mode, NO: normal mode
 */
/**
cn:
 YES:发现模式，NO:普通模式
 */
@property (nonatomic, assign) BOOL discoverableFlag;

/**
en:
 Bluetooth lock broadcast name
 */
/**
cn:
 蓝牙锁广播名称
 */
@property (nonatomic, copy) NSString *name;

/**
en:
 Broadcast service UUIDs
 */
/**
cn:
 广播服务UUIDs
 */
@property (nonatomic, copy) NSArray *serviceUUIDs;

/**
en:
 Signal
 */
/**
cn:
 信号
 */
@property (nonatomic, copy) NSNumber *RSSI;

/**
en:
BLE Chip type
 */
/**
cn:
 芯片类型
 */
@property (nonatomic, assign) int chipType;

/**
en:
 YES: indicates that the door lock uses the new version of the protocol, NO: indicates that the old protocol is used
 */
/**
cn:
 YES：表示门锁使用新版本协议，NO：表示使用旧协议
 */
@property (nonatomic, assign) BOOL modernProtocol;

/**
 表示设备类型
 */
@property (nonatomic, assign) int lockType;

- (NSDictionary *)dicFromObject;

@end
