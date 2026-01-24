//
//  HXRecord2AlarmModel.h
//  HXJBLESDK
//
//  Created by JQ on 2022/3/28.
//  Copyright © 2022 JQ. All rights reserved.
//

#import "HXRecord2BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 报警事件记录
 
 对应recordType为以下类型的记录
 1：强拆报警
 2：非法操作报警，系统已锁定
 3：低电量报警
 7：胁迫开锁
 12：撬锁芯报警
 14：假锁报警
 15：未关门报警
 18：故障报警
 25：未拔钥匙事件
 */
@interface HXRecord2AlarmModel : HXRecord2BaseModel

/**
en:
 alarmType == 18: fault alarm, this parameter is valid
 0: Button short circuit
 1: The memory is abnormal
 2: The touch chip is abnormal
 3: Low-voltage detection circuit is abnormal
 4: The card reading circuit is abnormal
 5: Check card circuit is abnormal
 6: Fingerprint communication is abnormal
 7: RTC crystal oscillator circuit is abnormal
 */
/**
cn:
 alarmType == 18：故障报警，该参数有效
 0：按键短路
 1：存储器异常
 2：触摸芯片异常
 3：低压检测电路异常
 4：读卡电路异常
 5：检卡电路异常
 6：指纹通讯异常
 7：RTC晶振电路异常
 */
@property (nonatomic, assign) int faultType;

/**
en:
 alarmType == 7: duress alarm, if this parameter is not equal to 0, it means that the user is holding the key Id to unlock the lock */
/**
cn:
 alarmType == 7：胁迫报警，如果该参数不等于0，表示挟持用户开锁的钥匙Id
 */
@property (nonatomic, assign) int lockKeyId;

@end

NS_ASSUME_NONNULL_END
