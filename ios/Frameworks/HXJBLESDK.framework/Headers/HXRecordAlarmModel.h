//
//  HXRecordAlarmModel.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/23.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import "HXRecordBaseModel.h"

/**
en:
 Alarm record
 For example, it can be parsed as:
 "General alarm: XXX alarm"
 "Duress warning: Please note that XXX was hijacked and unlocked;"
 "Fault alarm: XXX failure"
 */
/**
cn:
 告警记录
 例如可解析为：
 “普通告警：XXX告警”
 “胁迫告警：请注意，XXX被劫持开锁；”
 “故障告警：XXX故障”
 */
@interface HXRecordAlarmModel : HXRecordBaseModel

/**
cn:
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
@property (nonatomic, assign) int alarmType;

/**
en:
alarmType == 4: duress alarm, if this parameter is not equal to 0, it means that the user is holding the key Id to unlock the lock */
/**
cn:
 alarmType == 4：胁迫报警，如果该参数不等于0，表示挟持用户开锁的钥匙Id
 */
@property (nonatomic, assign) int alarmLockKeyId;

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


- (NSDictionary *)dicFromObject;

@end

