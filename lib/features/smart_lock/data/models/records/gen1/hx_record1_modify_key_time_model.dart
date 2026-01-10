// Doc fields: changeMode, lockKeyId, keyGroupId, authMode, validStartTime, validEndTime, weeks, dayStartTimes, dayEndTimes, vaildNumber
import 'package:wise_apartment/features/smart_lock/data/models/records/gen1/hx_record1_base_model.dart';
import 'package:wise_apartment/features/smart_lock/data/models/records/shared/record_base_parsers.dart';

class HXRecord1ModifyKeyTimeModel extends HXRecord1BaseModel {
  final int changeMode;
  final int lockKeyId;
  final int keyGroupId;
  final int authMode;
  final int validStartTime;
  final int validEndTime;
  final int weeks;
  final String dayStartTimes;
  final String dayEndTimes;
  final int vaildNumber;

  const HXRecord1ModifyKeyTimeModel({
    required super.recordTime,
    required super.recordType,
    required super.logVersion,
    required super.modelType,
    super.eventFlag,
    super.power,
    required super.raw,
    required this.changeMode,
    required this.lockKeyId,
    required this.keyGroupId,
    required this.authMode,
    required this.validStartTime,
    required this.validEndTime,
    required this.weeks,
    required this.dayStartTimes,
    required this.dayEndTimes,
    required this.vaildNumber,
  });

  factory HXRecord1ModifyKeyTimeModel.fromMap(Map<String, dynamic> map) {
    final int recordTime = asInt(map['recordTime']);
    final int recordType = asInt(map['recordType']);
    final int logVersion = asInt(map['logVersion']);
    final String modelType = asString(map['modelType']);
    final int? eventFlag = asIntOrNull(map['eventFlag']);
    final int? power = asIntOrNull(map['power']);

    final int changeMode = asInt(map['changeMode']);
    final int lockKeyId = asInt(map['lockKeyId']);
    final int keyGroupId = asInt(map['keyGroupId']);
    final int authMode = asInt(map['authMode']);
    final int validStartTime = asInt(map['validStartTime']);
    final int validEndTime = asInt(map['validEndTime']);
    final int weeks = asInt(map['weeks']);
    final String dayStartTimes = asString(map['dayStartTimes']);
    final String dayEndTimes = asString(map['dayEndTimes']);
    final int vaildNumber = asInt(map['vaildNumber']);

    final raw = Map<String, dynamic>.from(map);
    for (final k in [
      'recordTime',
      'recordType',
      'logVersion',
      'modelType',
      'eventFlag',
      'power',
      'changeMode',
      'lockKeyId',
      'keyGroupId',
      'authMode',
      'validStartTime',
      'validEndTime',
      'weeks',
      'dayStartTimes',
      'dayEndTimes',
      'vaildNumber',
    ])
      raw.remove(k);

    return HXRecord1ModifyKeyTimeModel(
      recordTime: recordTime,
      recordType: recordType,
      logVersion: logVersion,
      modelType: modelType,
      eventFlag: eventFlag,
      power: power,
      raw: raw,
      changeMode: changeMode,
      lockKeyId: lockKeyId,
      keyGroupId: keyGroupId,
      authMode: authMode,
      validStartTime: validStartTime,
      validEndTime: validEndTime,
      weeks: weeks,
      dayStartTimes: dayStartTimes,
      dayEndTimes: dayEndTimes,
      vaildNumber: vaildNumber,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final m = baseToMap();
    m['changeMode'] = changeMode;
    m['lockKeyId'] = lockKeyId;
    m['keyGroupId'] = keyGroupId;
    m['authMode'] = authMode;
    m['validStartTime'] = validStartTime;
    m['validEndTime'] = validEndTime;
    m['weeks'] = weeks;
    m['dayStartTimes'] = dayStartTimes;
    m['dayEndTimes'] = dayEndTimes;
    m['vaildNumber'] = vaildNumber;
    m.addAll(raw);
    return m;
  }
}
