// Doc fields: opporKeyGroupId, openMode, normalyOpenMode, volumeEnable, systemiVolume, shakeAlarmEnable, lockCylinderAlarmEnable, antiLockEnable, lockCoverAlarmEnable, systemLanguage
import 'package:wise_apartment/features/smart_lock/data/models/records/shared/record_base_parsers.dart';
import 'package:wise_apartment/features/smart_lock/data/models/records/gen2/hx_record2_base_model.dart';

class HXRecord2SetSysPramModel extends HXRecord2BaseModel {
  final int opporKeyGroupId;
  final int openMode;
  final int normalyOpenMode;
  final int volumeEnable;
  final int systemiVolume;
  final int shakeAlarmEnable;
  final int lockCylinderAlarmEnable;
  final int antiLockEnable;
  final int lockCoverAlarmEnable;
  final int systemLanguage;

  const HXRecord2SetSysPramModel({
    required super.recordTime,
    required super.recordType,
    required super.logVersion,
    required super.modelType,
    super.eventFlag,
    super.power,
    required super.raw,
    required this.opporKeyGroupId,
    required this.openMode,
    required this.normalyOpenMode,
    required this.volumeEnable,
    required this.systemiVolume,
    required this.shakeAlarmEnable,
    required this.lockCylinderAlarmEnable,
    required this.antiLockEnable,
    required this.lockCoverAlarmEnable,
    required this.systemLanguage,
  });

  factory HXRecord2SetSysPramModel.fromMap(Map<String, dynamic> map) {
    final int recordTime = asInt(map['recordTime']);
    final int recordType = asInt(map['recordType']);
    final int logVersion = asInt(map['logVersion']);
    final String modelType = asString(map['modelType']);
    final int? eventFlag = asIntOrNull(map['eventFlag']);
    final int? power = asIntOrNull(map['power']);

    final int opporKeyGroupId = asInt(map['opporKeyGroupId']);
    final int openMode = asInt(map['openMode']);
    final int normalyOpenMode = asInt(map['normalyOpenMode']);
    final int volumeEnable = asInt(map['volumeEnable']);
    final int systemiVolume = asInt(map['systemiVolume']);
    final int shakeAlarmEnable = asInt(map['shakeAlarmEnable']);
    final int lockCylinderAlarmEnable = asInt(map['lockCylinderAlarmEnable']);
    final int antiLockEnable = asInt(map['antiLockEnable']);
    final int lockCoverAlarmEnable = asInt(map['lockCoverAlarmEnable']);
    final int systemLanguage = asInt(map['systemLanguage']);

    final raw = Map<String, dynamic>.from(map);
    for (final k in [
      'recordTime',
      'recordType',
      'logVersion',
      'modelType',
      'eventFlag',
      'power',
      'opporKeyGroupId',
      'openMode',
      'normalyOpenMode',
      'volumeEnable',
      'systemiVolume',
      'shakeAlarmEnable',
      'lockCylinderAlarmEnable',
      'antiLockEnable',
      'lockCoverAlarmEnable',
      'systemLanguage',
    ])
      raw.remove(k);

    return HXRecord2SetSysPramModel(
      recordTime: recordTime,
      recordType: recordType,
      logVersion: logVersion,
      modelType: modelType,
      eventFlag: eventFlag,
      power: power,
      raw: raw,
      opporKeyGroupId: opporKeyGroupId,
      openMode: openMode,
      normalyOpenMode: normalyOpenMode,
      volumeEnable: volumeEnable,
      systemiVolume: systemiVolume,
      shakeAlarmEnable: shakeAlarmEnable,
      lockCylinderAlarmEnable: lockCylinderAlarmEnable,
      antiLockEnable: antiLockEnable,
      lockCoverAlarmEnable: lockCoverAlarmEnable,
      systemLanguage: systemLanguage,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final m = baseToMap();
    m['opporKeyGroupId'] = opporKeyGroupId;
    m['openMode'] = openMode;
    m['normalyOpenMode'] = normalyOpenMode;
    m['volumeEnable'] = volumeEnable;
    m['systemiVolume'] = systemiVolume;
    m['shakeAlarmEnable'] = shakeAlarmEnable;
    m['lockCylinderAlarmEnable'] = lockCylinderAlarmEnable;
    m['antiLockEnable'] = antiLockEnable;
    m['lockCoverAlarmEnable'] = lockCoverAlarmEnable;
    m['systemLanguage'] = systemLanguage;
    m.addAll(raw);
    return m;
  }
}
