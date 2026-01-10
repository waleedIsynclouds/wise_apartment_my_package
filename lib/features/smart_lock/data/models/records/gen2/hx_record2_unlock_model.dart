// Doc fields: operKeyGroupId1, keyType1, lockKeyId1, opporKeyGroupId2, keyType2, lockKeyId2, keyLen1, key1, Key1RemainingTimes, key2RemainingTimes
import 'package:wise_apartment/features/smart_lock/data/models/records/shared/record_base_parsers.dart';
import 'package:wise_apartment/features/smart_lock/data/models/records/gen2/hx_record2_base_model.dart';

class HXRecord2UnlockModel extends HXRecord2BaseModel {
  final int operKeyGroupId1;
  final int keyType1;
  final int lockKeyId1;
  final int opporKeyGroupId2;
  final int keyType2;
  final int lockKeyId2;
  final int keyLen1;
  final String key1;
  final int key1RemainingTimes;
  final int key2RemainingTimes;

  const HXRecord2UnlockModel({
    required super.recordTime,
    required super.recordType,
    required super.logVersion,
    required super.modelType,
    super.eventFlag,
    super.power,
    required super.raw,
    required this.operKeyGroupId1,
    required this.keyType1,
    required this.lockKeyId1,
    required this.opporKeyGroupId2,
    required this.keyType2,
    required this.lockKeyId2,
    required this.keyLen1,
    required this.key1,
    required this.key1RemainingTimes,
    required this.key2RemainingTimes,
  });

  factory HXRecord2UnlockModel.fromMap(Map<String, dynamic> map) {
    final int recordTime = asInt(map['recordTime']);
    final int recordType = asInt(map['recordType']);
    final int logVersion = asInt(map['logVersion']);
    final String modelType = asString(map['modelType']);
    final int? eventFlag = asIntOrNull(map['eventFlag']);
    final int? power = asIntOrNull(map['power']);

    final int operKeyGroupId1 = asInt(map['operKeyGroupId1']);
    final int keyType1 = asInt(map['keyType1']);
    final int lockKeyId1 = asInt(map['lockKeyId1']);
    final int opporKeyGroupId2 = asInt(map['opporKeyGroupId2']);
    final int keyType2 = asInt(map['keyType2']);
    final int lockKeyId2 = asInt(map['lockKeyId2']);
    final int keyLen1 = asInt(map['keyLen1']);
    final String key1 = asString(map['key1']);
    final int key1RemainingTimes = asInt(map['Key1RemainingTimes']);
    final int key2RemainingTimes = asInt(map['key2RemainingTimes']);

    final raw = Map<String, dynamic>.from(map);
    for (final k in [
      'recordTime',
      'recordType',
      'logVersion',
      'modelType',
      'eventFlag',
      'power',
      'operKeyGroupId1',
      'keyType1',
      'lockKeyId1',
      'opporKeyGroupId2',
      'keyType2',
      'lockKeyId2',
      'keyLen1',
      'key1',
      'Key1RemainingTimes',
      'key2RemainingTimes',
    ])
      raw.remove(k);

    return HXRecord2UnlockModel(
      recordTime: recordTime,
      recordType: recordType,
      logVersion: logVersion,
      modelType: modelType,
      eventFlag: eventFlag,
      power: power,
      raw: raw,
      operKeyGroupId1: operKeyGroupId1,
      keyType1: keyType1,
      lockKeyId1: lockKeyId1,
      opporKeyGroupId2: opporKeyGroupId2,
      keyType2: keyType2,
      lockKeyId2: lockKeyId2,
      keyLen1: keyLen1,
      key1: key1,
      key1RemainingTimes: key1RemainingTimes,
      key2RemainingTimes: key2RemainingTimes,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final m = baseToMap();
    m['operKeyGroupId1'] = operKeyGroupId1;
    m['keyType1'] = keyType1;
    m['lockKeyId1'] = lockKeyId1;
    m['opporKeyGroupId2'] = opporKeyGroupId2;
    m['keyType2'] = keyType2;
    m['lockKeyId2'] = lockKeyId2;
    m['keyLen1'] = keyLen1;
    m['key1'] = key1;
    m['Key1RemainingTimes'] = key1RemainingTimes;
    m['key2RemainingTimes'] = key2RemainingTimes;
    m.addAll(raw);
    return m;
  }
}
