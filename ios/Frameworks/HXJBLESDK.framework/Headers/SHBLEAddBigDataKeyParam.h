//
//  SHBLEAddBigDataKeyParam.h
//  HXJBLESDK
//
//  Created by JQ on 2023/4/13.
//  Copyright © 2023 JQ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SHBLEAddBigDataKeyParam : NSObject

/// 钥匙总字节长度
@property (nonatomic, assign) int totalBytesLength;

/// 当前发送的数据处于第几包，下标从0开始（实际门锁是从1开始，内部会自动处理）
@property (nonatomic, assign) int currentIndex;

/// 总包数
@property (nonatomic, assign) int totalNum;

/// 钥匙所属用户ID
@property (nonatomic, assign) int keyGroupId;

/// currentIndex对应的钥匙数据（门锁端对于每一条命令的字节数有做限制，这里分包大小定义为最大200个字节）
@property (nonatomic, strong) NSData *data;

@end

NS_ASSUME_NONNULL_END
