class DnaInfoModel {
  String? deviceDnaInfoStr;
  String? mac;
  String? initTag;
  int? deviceType;
  String? hardWareVer;
  String? softWareVer;
  int? protocolVer;
  int? appCmdSets;
  String? dnaAes128Key;
  String? authorizedRoot;
  String? authorizedUser;
  String? authorizedTempUser;
  int? rFMoudleType;
  int? lockFunctionType;
  int? maximumVolume;
  int? maximumUserNum;
  int? menuFeature;
  int? fingerPrintfNum;
  int? projectID;
  String? RFModuleMac;
  int? motorDriverMode;
  int? motorSetMenuFunction;
  int? MoudleFunction;
  int? BleActiveTimes;
  int? ModuleSoftwareVer;
  int? ModuleHardwareVer;
  int? passwordNumRange;
  int? OfflinePasswordVer;
  int? supportSystemLanguage;
  int? hotelFunctionEn;
  int? schoolOpenNormorl;
  int? cabinetLock;
  int? lockSystemFunction;
  int? lockNetSystemFunction;
  int? sysLanguage;
  int? keyAddMenuType;
  int? functionFlag;
  int? bleSmartCardNfcFunction;
  int? wisapartmentCardFunction;
  int? lockCompanyId;

  DnaInfoModel({
    this.deviceDnaInfoStr,
    this.mac,
    this.initTag,
    this.deviceType,
    this.hardWareVer,
    this.softWareVer,
    this.protocolVer,
    this.appCmdSets,
    this.dnaAes128Key,
    this.authorizedRoot,
    this.authorizedUser,
    this.authorizedTempUser,
    this.rFMoudleType,
    this.lockFunctionType,
    this.maximumVolume,
    this.maximumUserNum,
    this.menuFeature,
    this.fingerPrintfNum,
    this.projectID,
    this.RFModuleMac,
    this.motorDriverMode,
    this.motorSetMenuFunction,
    this.MoudleFunction,
    this.BleActiveTimes,
    this.ModuleSoftwareVer,
    this.ModuleHardwareVer,
    this.passwordNumRange,
    this.OfflinePasswordVer,
    this.supportSystemLanguage,
    this.hotelFunctionEn,
    this.schoolOpenNormorl,
    this.cabinetLock,
    this.lockSystemFunction,
    this.lockNetSystemFunction,
    this.sysLanguage,
    this.keyAddMenuType,
    this.functionFlag,
    this.bleSmartCardNfcFunction,
    this.wisapartmentCardFunction,
    this.lockCompanyId,
  });

  factory DnaInfoModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return DnaInfoModel();
    return DnaInfoModel(
      deviceDnaInfoStr: map['deviceDnaInfoStr'] as String?,
      mac: map['mac'] as String?,
      initTag: map['initTag'].toString(),
      deviceType: map['deviceType'] as int?,
      hardWareVer: map['hardWareVer'] as String?,
      softWareVer: map['softWareVer'] as String?,
      protocolVer: map['protocolVer'] is int
          ? map['protocolVer'] as int
          : (map['protocolVer'] != null
                ? int.tryParse(map['protocolVer'].toString())
                : null),
      appCmdSets: map['appCmdSets'] as int?,
      dnaAes128Key: map['dnaAes128Key'] as String?,
      authorizedRoot: map['authorizedRoot'] as String?,
      authorizedUser: map['authorizedUser'] as String?,
      authorizedTempUser: map['authorizedTempUser'] as String?,
      rFMoudleType: map['rFModuleType'] as int?,
      lockFunctionType: map['lockFunctionType'] as int?,
      maximumVolume: map['maximumVolume'] as int?,
      maximumUserNum: map['maximumUserNum'] as int?,
      menuFeature: map['menuFeature'] as int?,
      fingerPrintfNum: map['fingerPrintfNum'] as int?,
      projectID: map['projectID'] is int
          ? map['projectID'] as int
          : (map['projectID'] != null
                ? int.tryParse(map['projectID'].toString())
                : null),
      RFModuleMac:
          map['rFModuleMac'] as String? ?? map['RFModuleMac'] as String?,
      motorDriverMode: map['motorDriverMode'] as int?,
      motorSetMenuFunction: map['motorSetMenuFunction'] as int?,
      MoudleFunction: map['MoudleFunction'] as int?,
      BleActiveTimes: map['BleActiveTimes'] as int?,
      ModuleSoftwareVer: map['ModuleSoftwareVer'] as int?,
      ModuleHardwareVer: map['ModuleHardwareVer'] as int?,
      passwordNumRange: map['passwordNumRange'] as int?,
      OfflinePasswordVer: map['OfflinePasswordVer'] as int?,
      supportSystemLanguage: map['supportSystemLanguage'] as int?,
      hotelFunctionEn: map['hotelFunctionEn'] as int?,
      schoolOpenNormorl: map['schoolOpenNormorl'] as int?,
      cabinetLock: map['cabinetLock'] as int?,
      lockSystemFunction: map['lockSystemFunction'] is int
          ? (map['lockSystemFunction'] as int)
          : (map['lockSystemFunction'] != null
                ? int.tryParse(map['lockSystemFunction'].toString())
                : null),
      lockNetSystemFunction: map['lockNetSystemFunction'] is int
          ? (map['lockNetSystemFunction'] as int)
          : (map['lockNetSystemFunction'] != null
                ? int.tryParse(map['lockNetSystemFunction'].toString())
                : null),
      sysLanguage: map['sysLanguage'] as int?,
      keyAddMenuType: map['keyAddMenuType'] as int?,
      functionFlag: map['functionFlag'] as int?,
      bleSmartCardNfcFunction: map['bleSmartCardNfcFunction'] as int?,
      wisapartmentCardFunction: map['wisapartmentCardFunction'] as int?,
      lockCompanyId: map['lockCompanyId'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceDnaInfoStr': deviceDnaInfoStr,
      'mac': mac,
      'initTag': initTag,
      'deviceType': deviceType,
      'hardWareVer': hardWareVer,
      'softWareVer': softWareVer,
      'protocolVer': protocolVer,
      'appCmdSets': appCmdSets,
      'dnaAes128Key': dnaAes128Key,
      'authorizedRoot': authorizedRoot,
      'authorizedUser': authorizedUser,
      'authorizedTempUser': authorizedTempUser,
      'rFModuleType': rFMoudleType,
      'lockFunctionType': lockFunctionType,
      'maximumVolume': maximumVolume,
      'maximumUserNum': maximumUserNum,
      'menuFeature': menuFeature,
      'fingerPrintfNum': fingerPrintfNum,
      'projectID': projectID,
      'rFModuleMac': RFModuleMac,
      'motorDriverMode': motorDriverMode,
      'motorSetMenuFunction': motorSetMenuFunction,
      'MoudleFunction': MoudleFunction,
      'BleActiveTimes': BleActiveTimes,
      'ModuleSoftwareVer': ModuleSoftwareVer,
      'ModuleHardwareVer': ModuleHardwareVer,
      'passwordNumRange': passwordNumRange,
      'OfflinePasswordVer': OfflinePasswordVer,
      'supportSystemLanguage': supportSystemLanguage,
      'hotelFunctionEn': hotelFunctionEn,
      'schoolOpenNormorl': schoolOpenNormorl,
      'cabinetLock': cabinetLock,
      'lockSystemFunction': lockSystemFunction,
      'lockNetSystemFunction': lockNetSystemFunction,
      'sysLanguage': sysLanguage,
      'keyAddMenuType': keyAddMenuType,
      'functionFlag': functionFlag,
      'bleSmartCardNfcFunction': bleSmartCardNfcFunction,
      'wisapartmentCardFunction': wisapartmentCardFunction,
      'lockCompanyId': lockCompanyId,
    };
  }

  @override
  String toString() => 'DnaInfoModel(mac=$mac, protocolVer=$protocolVer)';
}
