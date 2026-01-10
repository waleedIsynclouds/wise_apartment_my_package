// Doc fields: alarmType, alarmLockKeyId, faultType
import 'package:wise_apartment/features/smart_lock/data/models/records/gen1/hx_record1_base_model.dart';
import 'package:wise_apartment/features/smart_lock/data/models/records/shared/record_base_parsers.dart';

class HXRecord1AlarmModel extends HXRecord1BaseModel {
  final int alarmType;
  final int alarmLockKeyId;
  final int faultType;

  const HXRecord1AlarmModel({
    required super.recordTime,
    required super.recordType,
    required super.logVersion,
    required super.modelType,
    super.eventFlag,
    super.power,
    required super.raw,
    required this.alarmType,
    required this.alarmLockKeyId,
    required this.faultType,
  });

  factory HXRecord1AlarmModel.fromMap(Map<String, dynamic> map) {
    final int recordTime = asInt(map['recordTime']);
    final int recordType = asInt(map['recordType']);
    final int logVersion = asInt(map['logVersion']);
    final String modelType = asString(map['modelType']);
    final int? eventFlag = asIntOrNull(map['eventFlag']);
    final int? power = asIntOrNull(map['power']);

    final int alarmType = asInt(map['alarmType']);
    final int alarmLockKeyId = asInt(map['alarmLockKeyId']);
    final int faultType = asInt(map['faultType']);

    final raw = Map<String, dynamic>.from(map);
    for (final k in [
      'recordTime',
      'recordType',
      'logVersion',
      'modelType',
      'eventFlag',
      'power',
      'alarmType',
      'alarmLockKeyId',
      'faultType',
    ])
      raw.remove(k);

    return HXRecord1AlarmModel(
      recordTime: recordTime,
      recordType: recordType,
      logVersion: logVersion,
      modelType: modelType,
      eventFlag: eventFlag,
      power: power,
      raw: raw,
      alarmType: alarmType,
      alarmLockKeyId: alarmLockKeyId,
      faultType: faultType,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final m = baseToMap();
    m['alarmType'] = alarmType;
    m['alarmLockKeyId'] = alarmLockKeyId;
    m['faultType'] = faultType;
    m.addAll(raw);
    return m;
  }
}
