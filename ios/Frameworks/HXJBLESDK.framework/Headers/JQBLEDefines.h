//
//  JQBLEDefines.h
//  JQBluetooth
//
//  Created by JQ on 2017/8/9.
//  Copyright © 2017年 JQ. All rights reserved.
//


#ifndef JQBLEDefines_h
#define JQBLEDefines_h

#pragma mark -通知

/** Bluetooth lock event report notification.object Refer to PushEvent */
/** 蓝牙锁事件上报 notification.object 参考PushEvent */
#define HXPushEventNotification @"HXPUSHEVENTNOTIFICATION"

/** The phone is disconnected from the Bluetooth lock notification.object = Bluetooth lock mac address*/
/** 手机与蓝牙锁断开连接 notification.object = 蓝牙锁mac地址*/
#define KSHNotification_BLEDisconnect @"KSHNotification_BLEDisconnect"

/** The phone is successfully connected to the Bluetooth lock, notification.object = Bluetooth lock mac address*/
/** 手机与蓝牙锁连接成功 ，notification.object = 蓝牙锁mac地址*/
#define KSHNotification_BLEConnect @"KSHNotification_BLEConnect"

/**Invoked when the central manager’s state is updated. notification.object = @(KJQBluetoothState)*/
#define kJQNotification_CBManagerDidUpdateState @"kJQNotification_CBManagerDidUpdateState"

/**
 WiFi lock config network event report notification, object is "SHWiFiNetworkConfigReportParam object"
 WiFi锁配网事件上报通知，object为“SHWiFiNetworkConfigReportParam对象”
 */
#define KSHNotificationWiFiNetworkConfig @"KSHNotificationWiFiNetworkConfig"

/**
Bluetooth lock firmware upgrade stage
 蓝牙锁固件升级的阶段
 */
typedef NS_ENUM(NSInteger, KSHBLEUpgradePhase) {
    /**
     Ready to upgrade (realize Bluetooth search, connect devices, etc. at this stage)
     准备升级（此阶段实现蓝牙搜索、连接设备等）
     */
    KSHBLEUpgradePhase_Prepare,
    /**
     Upgrading (at this stage, the upgrade progress can be judged according to the percentage)
     正在升级（此阶段可根据根据百分比判断升级进度）
     */
    KSHBLEUpgradePhase_Updating,
    /**
     The upgrade is over (you need to wait for the device to automatically restart successfully and then run the new firmware,
     The BLUEX chip generally takes 3 seconds to wait for the device to restart
     Other Bluetooth chips generally take 15 seconds to wait for the device to restart.

     升级结束（需等待设备自动重启成功后运行新固件，
     BLUEX芯片一般要3秒等待设备重启
     其它蓝牙芯片一般要15秒等待设备重启，
     ）
     */
    KSHBLEUpgradePhase_End,
};

/**
 结果状态码
 */
typedef NS_ENUM(NSInteger, KSHStatusCode) {
    /** Return success */
    /** 返回成功 */
    KSHStatusCode_Success = 0,
    /** operation failed */
    /** 操作失败 */
    KSHStatusCode_Failed = -100003,
    /** Invalid parameter */
    /** 无效参数 */
    KSHStatusCode_invalidParam = -100004,
    /** Request timed out */
    /** 请求超时 */
    KSHStatusCode_Timeout = -100005,
    /** The service does not exist in the Bluetooth peripheral */
    /** 蓝牙外设中不存在该服务 */
    KSHStatusCode_ServiceNotExist = -800001,
    /** The service has not been found in the Bluetooth peripherals, it may be because the services of the peripherals have not been read */
    /** 蓝牙外设中还没有发现该服务，可能是因为还未读取外设的服务 */
    KSHStatusCode_ServiceNotFound = -800002,
    /** There are no features in the current service */
    /** 当前服务中不存在任何特征 */
    KSHStatusCode_CharacteristicNotExist = -800003,
    /** Bluetooth is not available */
    /** 蓝牙不可用 */
    KSHStatusCode_BluetoothStateUnavailable = -800004,
    /** Disconnect from peripheral */
    /** 与外设断开连接 */
    KSHStatusCode_DidDisconnectPeripheral = -800005,
    /** Failed to connect to peripheral */
    /** 连接外设失败 */
    KSHStatusCode_BluetoothConnectionFailed = -800006,
    /** DNA key error, the device may have been reset, please add the device again */
    /** DNA密钥错误，设备可能被重置过，请重新添加设备  */
    KSHStatusCode_DNAKeyWrong = -800007,
    /** No eigenvalue found */
    /** 未找到特征值 */
    KSHStatusCode_CharacteristicNotFound = -800008,
    /** No Bluetooth peripherals found */
    /** 未发现蓝牙外设 */
    KSHStatusCode_BluetoothNotFound = -800009,
    /** The user does not allow the App to access Bluetooth */
    /** 用户不允许App访问蓝牙 */
    KSHStatusCode_BluetoothStateDenied = -800010,
    /**wrong password*/
    /**密码错误*/
    KSHBLECommonStatus_PasswordError = 2,
    /**Remote unlock is not turned on (the local DIP switch of the lock is not turned on)*/
    /**远程开锁未开启(锁本地拨码开关未打上)*/
    KSHBLECommonStatus_NoAppUnlockFunction = 3,
    /**Parameter error*/
    /**参数错误*/
    KSHBLECommonStatus_ParameterError = 4,
    /**This operation is forbidden, please add an administrator first*/
    /**禁止此项操作,请先添加管理员*/
    KSHBLECommonStatus_NeedAddAdminFirst = 5,
    /**Door lock does not support this command or operation*/
    /**门锁不支持此命令或操作*/
    KSHBLECommonStatus_DoorlockNotSupported = 6,
    /**Add repeatedly (card/password, etc.)*/
    /**重复添加(卡片/密码等)*/
    KSHBLECommonStatus_KeysAlreadyExist = 7,
    /**Number error*/
    /**编号错误*/
    KSHBLECommonStatus_ErrorNo = 8,
    /**Unlocking is not allowed*/
    /**不允许开反锁*/
    KSHBLECommonStatus_AntiLockNotAllowed = 9,
    /**System is locked*/
    /**系统已锁定*/
    KSHBLECommonStatus_SystemLocked = 0xA,//10
    /**It is forbidden to delete the administrator*/
    /**禁止删除管理员*/
    KSHBLECommonStatus_AdmCannotBeDeleted = 0xB,//11
    /**The number of door locks stored is full, no more settings are allowed*/
    /**门锁存储数量已满,不允许再设置*/
    KSHBLECommonStatus_LockedMemorySpaceFull = 0xE,//14
    /**There are follow-up data packages*/
    /**还有后续数据包*/
    KSHBLECommonStatus_WaitForOtherPackets = 0xF,//15
    /**The door is locked, it is not allowed to open the lock*/
    /**门已反锁,不允许开反锁*/
    KSHBLECommonStatus_DoorIsLockedAndAntilockNotAllowed = 0x10,//16
    /**Exit adding key*/
    /**退出添加钥匙*/
    KSHBLECommonStatus_ExitAddKey = 0x11,
    /**Authentication failed*/
    /**鉴权失败*/
    KSHBLECommonStatus_AuthError = 0xE1,//225
    /**Commands sent frequently in the past*/
    /**命令发送过去频繁*/
    KSHBLECommonStatus_Busy = 0xE2,//226
    /**Encryption type error, you can try to initialize the device and add it again*/
    /**加密类型错误，可尝试初始化设备后重新添加*/
    KSHBLECommonStatus_TypeError = 0xE4,//228
    /**SessionId error*/
    /**SessionId错误*/
    KSHBLECommonStatus_SessionIdError = 0xE5,//229
    /**The device does not enter the pairing state*/
    /**设备未进入配对状态*/
    KSHBLECommonStatus_NotPairing = 0xE6,//230
    /**Command not allowed*/
    /**命令不允许*/
    KSHBLECommonStatus_CmdNotAllowed = 0xE7,//231
    /**Please add device first*/
    /**请先添加设备*/
    KSHBLECommonStatus_NeedToAddDeviceFirst = 0xE8,//232
    /**You already have the permission to use the device, no need to add it again*/
    /**您已拥有该设备的使用权限，不需要再重复添加*/
    KSHBLECommonStatus_DeviceHasBeenAdded = 0xEA,//234
    /**No permission*/
    /**无权限*/
    KSHBLECommonStatus_Forbidden = 0xEB,//235
    /**Command version not supported*/
    /**命令版本不支持*/
    KSHBLECommonStatus_notSupportedCmdVer = 0xEC,//236
    /**fail*/
    /**失败*/
    KSHBLECommonStatus_Failed = -100003,
    /**NB module is busy*/
    /**NB模组正忙*/
    KSHBLECommonStatus_NBBusy = 0x23,
    /**NB module does not enter AT mode*/
    /**NB模组未进入AT模式*/
    KSHBLECommonStatus_NBNotOpenATMode = 0x24,
    /**NB module is in AT mode and will not respond to other commands temporarily*/
    /**NB模组处于AT模式，暂不响应其它命令*/
    KSHBLECommonStatus_NBATMode = 0x25,
    /**Poor wireless module signal*/
    /**无线模组信号差*/
    KSHBLECommonStatus_rfModuleWeakSignal = 0x26,
    /**Wireless module is in flight mode*/
    /**无线模组处于飞行模式*/
    KSHBLECommonStatus_rfModuleInAirplaneMode = 0x27,
    /**Key has been replaced*/
    /**钥匙已被顶替*/
    KSHBLECommonStatus_keyReplaced= 0xEF,
};

/**
 蓝牙锁事件类型
 */
typedef NS_ENUM(int, KSHEventType) {
    /**
     0. Other
     0. 无区分
     */
    KSHEventType_Other = 0,
    /**
     1. Lock picking alarm (forced dismantling alarm)
     1.撬锁报警(强拆报警)
     */
    KSHEventType_PickAlarm = 1,
    /**
     2. The number of errors exceeds the limit, illegal operation, and the system is locked
     2.错误次数超限,非法操作，系统已锁定
     */
    KSHEventType_ExcessiveNumError = 2,
    /**
     3 Insufficient battery
     3电量不足
     */
    KSHEventType_Lowpower = 3,
    /**
     4 unlock event
     4开锁事件
     */
    KSHEventType_Unlock = 4,
    /**
     5 fortification (arming)
     5设防(布防)
     */
    KSHEventType_Arm = 5,
    /**
     6 Disarm
     6撤防
     */
    KSHEventType_Disarm = 6,
    /**
     7 Hijacking (duress) unlocking alarm
     7劫持（胁迫）开锁报警
     */
    KSHEventType_Hijack = 7,
    /**
     8 add users
     8添加用户
     */
    KSHEventType_AddUser = 8,
    /**
     9 delete user
     9删除用户
     */
    KSHEventType_DeleteUser = 9,
    /**
     10 anti-lock
     10反锁
     */
    KSHEventType_doubleLock = 10,
    /**
     11 Anti-lock release
     11反锁解除
     */
    KSHEventType_doubleLockRemove = 11,
    /**
     12Pick the lock core alarm
     12撬锁芯报警
     */
    KSHEventType_LockCoreAlarm = 12,
    /**
     13 doorbell incident
     13门铃事件
     */
    KSHEventType_DoorbellEvent = 13,
    /**
     14 false lock alarm (door lock is not closed)
     14假锁报警（门锁未关好）
     */
    KSHEventType_FakeLockAlarm = 14,
    /**
     15 Unclosed door alarm
     15未关门报警
     */
    KSHEventType_NoClosedDoorAlarm = 15,
    /**
     16 door lock normally open event
     16门锁常开事件
     */
    KSHEventType_DoorLockAlwaysOpen = 16,
    /**
     17 The door lock is locked (closed and normally open)
     17门锁已上锁（已关闭常开）
     */
    KSHEventType_ClosedNormallyOpen = 17,
    /**
     18 Lock failure
     18锁具故障
     */
    KSHEventType_DoorLockFailure = 18,
    /**
     19 APP synchronization door lock status event
     19APP同步门锁状态事件
     */
    KSHEventType_AppSynchronizeTheLockStatusEvent = 19,
    /**
     20 language system events
     20语言系统事件
     */
    KSHEventType_LanguageSystemEvent = 20,
    /**
     21 The system lock state has been released
     21系统锁定状态已解除
     */
    KSHEventType_SystemLockStatusHasBeenReleased = 21,
    /**
     22 time synchronization events
     22时间同步事件
     */
    KSHEventType_TimeSynchronization = 22,
    /**
     23 Factory reset event
     23恢复出厂设置事件
     */
    KSHEventType_RestoreFactorySettings = 23,
    /**
     24 modify password event
     24修改密码事件
     */
    KSHEventType_ChangePassword = 24,
    /**
     25 key not taken out event
     25钥匙未取出事件
     */
    KSHEventType_KeyWasNotTakenOut = 25,
    /**
     26 Open the lock cover head event
     26打开锁盖头事件
     */
    KSHEventType_OpenTheLockHead = 26,
    /**
     27 System parameter setting event
     27系统参数设置事件
     */
    KSHEventType_SystemParameterSetting = 27,
    /**
     28 key enable and disable events
     28钥匙的使能与禁止事件
     */
    KSHEventType_KeyEnableAndDisable = 28,
    /**
     33：无线模组唤醒事件
     */
    KSHEventType_LockEnable = 33,
    /**
     34 Modify the key validity period event
     34修改钥匙有效期事件
     */
    KSHEventType_ModifyKeyTime = 34,
    /**
     43 错误的开锁钥匙事件记录
    */
    KSHEventType_WrongKeyUnlock = 43,
    /**
     45 WiFi配网事件上报
    */
    KSHEventType_WiFiNetworkConfig = 45,
    /**
     47 按照钥匙内容修改钥匙信息事件记录 （例如修改卡号或密码）
    */
    KSHEventType_ModifyKeyValue = 47,

};

/**
 Door lock alarm type
 门锁报警类型
 */
typedef NS_ENUM(int, KSHServiceWarn) {
    /** Lock picking alarm */
    /** 撬锁报警 */
    KSHServiceWarn_PickALockAlarm = 1,
    /** Illegal operation alarm */
    /** 非法操作报警 */
    KSHServiceWarn_IllegalOperationAlarm = 2,
    /** Hijacking (duress) unlocking alarm */
    /** 劫持（胁迫）开锁报警 */
    KSHServiceWarn_Hijack = 7,
    /** Lock core alarm */
    /** 撬锁芯报警 */
    KSHServiceWarn_LockCoreAlarm = 12,
    /** False lock alarm (door lock is not closed)*/
    /** 假锁报警（门锁未关好）*/
    KSHServiceWarn_FakeLockAlarm = 14,
    /** Unclosed door alarm */
    /** 未关门报警 */
    KSHServiceWarn_NoClosedDoorAlarm = 15,
    /** Low battery alarm */
    /** 低电量报警 */
    KSHServiceWarn_LowBatteryAlarm = 16,
    /** Failure alarm: Button short circuit */
    /** 故障报警：按键短路 */
    KSHServiceWarn_FaultAlarm_ButtonShortCircuit = 17,
    /** Failure alarm: abnormal memory */
    /** 故障报警：存储器异常 */
    KSHServiceWarn_FaultAlarm_MemoryException = 18,
    /** Failure alarm: touch chip abnormal */
    /** 故障报警：触摸芯片异常 */
    KSHServiceWarn_FaultAlarm_AbnormalTouchChip = 19,
    /** Failure alarm: Low-voltage detection circuit is abnormal */
    /** 故障报警：低压检测电路异常 */
    KSHServiceWarn_FaultAlarm_LowVoltage = 20,
    /** Failure alarm: the card reading circuit is abnormal */
    /** 故障报警：读卡电路异常 */
    KSHServiceWarn_FaultAlarm_ReadCardCircuitAbnormal = 21,
    /** Failure alarm: Check card circuit is abnormal */
    /** 故障报警：检卡电路异常 */
    KSHServiceWarn_FaultAlarm_CheckTheAbnormalCircuit = 22,
    /** Failure alarm: fingerprint communication abnormal */
    /** 故障报警：指纹通讯异常 */
    KSHServiceWarn_FaultAlarm_FingerprintCommunicationDisorder = 23,
    /** Failure alarm: RTC crystal oscillator circuit is abnormal */
    /** 故障报警：RTC晶振电路异常 */
    KSHServiceWarn_FaultAlarm_CrystalOscillatorCircuit = 24,
    /** All alarms */
    /** 所有报警 */
    KSHServiceWarn_All = 255,
    
};

/**
 Key type
 钥匙类型
 */
typedef NS_OPTIONS(int, KSHKeyType) {
    /**
     fingerprint
     指纹
     */
    KSHKeyType_Fingerprint = 1 << 0,//1
    /**
     password
     密码
     */
    KSHKeyType_Password = 1 << 1,//2
    /**
     Card
     卡
     */
    KSHKeyType_Card = 1 << 2,//4
    /**
     Remote control
     遥控
     */
    KSHKeyType_RemoteControl = 1 << 3,//8
    /**
     人脸
     */
    KSHKeyType_Face = 1 << 6, //64
    /**
     App unlock
     App开锁
     */
    KSHKeyType_App = 1 << 7,//128
};

/** 人体感应的灵敏度 */
typedef NS_ENUM(int, kDetectionSensitivityLevel) {
    /**关闭 */
    kBLEDetectionSensitivityLevel_Close = 1,
    /**弱 */
    kBLEDetectionSensitivityLevel_Weak = 2,
    /**中 */
    kBLEDetectionSensitivityLevel_Middle = 3,
    /**强 */
    kBLEDetectionSensitivityLevel_Strong = 4,
};

/** Bluetooth lock operation record */
/** 蓝牙锁操作记录 */
typedef NS_ENUM(int, kSHBLEReadRecordType) {
    /** Unlock record */
    /** 开锁记录 */
    kSHBLEReadRecordType_unlock = 1,
    /** Lock record */
    /** 关锁记录 */
    kSHBLEReadRecordType_closeLock = 2,
    /** Add a key record */
    /** 添加一把钥匙记录 */
    kSHBLEReadRecordType_addKey = 3,
    /** Delete a key record */
    /** 删除一把钥匙记录 */
    kSHBLEReadRecordType_deleteKey = 4,
    /** Delete key records in batch */
    /** 批量删除钥匙记录 */
    kSHBLEReadRecordType_deleteGroupKey = 5,
    /** Modify key record */
    /** 修改钥匙记录 */
    kSHBLEReadRecordType_modifyKey = 6,
    /** Synchronize Bluetooth lock time record */
    /** 同步蓝牙锁时间记录 */
    kSHBLEReadRecordType_synTime = 7,
    /** Set system parameter record */
    /** 设置系统参数记录 */
    kSHBLEReadRecordType_setSysPram = 8,
    /** Key enable and disable records */
    /** 钥匙激活与禁用记录 */
    kSHBLEReadRecordType_keyEnable = 9,
    /** Verify password record */
    /** 验证密码记录 */
    kSHBLEReadRecordType_verifyPassword = 10,
    /** Alarm record */
    /** 告警记录 */
    kSHBLEReadRecordType_alarm = 11,
    /** Arm/disarm record */
    /** 布防/撤防记录 */
    kSHBLEReadRecordType_armDisarm = 12,
    /** Unlock/unlock release record */
    /** 反锁/反锁解除记录 */
    kSHBLEReadRecordType_antiLock = 13,
    /** Doorbell event record */
    /** 门铃事件记录 */
    kSHBLEReadRecordType_doorbell = 14,
    /** Modify the key validity period record */
    /** 修改钥匙有效期记录 */
    kSHBLEReadRecordType_modifyKeyTime = 15,
};

/**
 Week
 星期
*/
typedef NS_OPTIONS(int, kSHWeek) {
    kSHWeek_monday = 1 << 0,
    kSHWeek_tuesday = 1 << 1,
    kSHWeek_wednesday = 1 << 2,
    kSHWeek_thursday = 1 << 3,
    kSHWeek_friday = 1 << 4,
    kSHWeek_saturday = 1 << 5,
    kSHWeek_sunday = 1 << 6,
};

/**
 Types of alarms released
 解除的报警类型
 */
typedef NS_ENUM(int, KSHReleaseType) {
    /**
     Dismiss all alarms
     解除所有报警
     */
    KSHReleaseType_All = 0xff,
    /**
     Remove the forced demolition alarm
     解除强拆报警
     */
    KSHReleaseType_tollBreakdown = 1,
    /**
     Remove illegal operation alarm
     解除非法操作报警
     */
    KSHReleaseType_IllegalOperation = 2,
    /**
     Release the duress to unlock the alarm
     解除胁迫开锁报警
     */
    KSHReleaseType_CoerceUnlock = 7,
    /**
     Release the lock core alarm
     解除撬锁芯报警
     */
    KSHReleaseType_Picklock = 0x0C,
    /**
     Remove false lock alarm
     解除假锁报警
     */
    KSHReleaseType_FalseLock = 0x0E,
    /**
     Release the unclosed door alarm
     解除未关门报警
     */
    KSHReleaseType_NotClosed = 0x0F,
};

/**
 Bluetooth chip type
 蓝牙芯片类型
*/
typedef NS_ENUM(int, kBLEChipType) {
    kBLEChipType_D = 0,
    kBLEChipType_C = 1,
    kBLEChipType_B = 2,
    kBLEChipType_E = 3,
    kBLEChipType_Unknown = -1,
};

typedef NS_ENUM(NSInteger, KJQBluetoothState) {
    KJQBluetoothStateUnknown = 0,
    KJQBluetoothStateResetting,
    KJQBluetoothStateUnsupported,
    KJQBluetoothStateUnauthorized,
    KJQBluetoothStatePoweredOff,
    KJQBluetoothStatePoweredOn,
    ///User denied App access to Bluetooth
    ///用户拒绝App访问蓝牙
    KJQBluetoothStateDenied,
};

/**
 On/Off status
 开关状态
 */
typedef NS_ENUM(int, kSHOnOffState) {
    /** 关 */
    kSHOnOffState_off = 0,
    /** 开 */
    kSHOnOffState_on = 1,
};

/**
en:
 Bluetooth lock firmware upgrade callback
 @param phase is currently in a certain stage of Bluetooth lock firmware upgrade
 @param upgradeProgress phase == KSHBLEUpgradePhase_Updating is valid, indicating the upgrade progress (0 ~ 100)
 @param error Error message returned when the upgrade fails
 @param lockMac Bluetooth lock unique identifier (SDK supports concurrent upgrade of multiple Bluetooth locks, after the upgrade, you can determine which locks have been successfully upgraded or failed)
 */
/**
cn:
 蓝牙锁固件升级回调
 @param phase 当前处于蓝牙锁固件升级的某个阶段
 @param upgradeProgress phase == KSHBLEUpgradePhase_Updating时有效，表示升级进度（0 ~ 100）
 @param error 升级失败返回的错误信息
 @param lockMac 蓝牙锁唯一标识（SDK支持并发升级多个蓝牙锁，升级结束后可判断哪些锁升级成功或失败）
 */
typedef void(^BLEOTACallbackBlock)(KSHBLEUpgradePhase phase, int upgradeProgress, kBLEChipType chipType, NSError *error, NSString *lockMac);

#endif /* JQBLEDefines_h */


