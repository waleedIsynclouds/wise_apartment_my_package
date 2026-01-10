// Doc fields: operKeyGroupId, deleteMode, lockKeyId, keyType, keyLen, key, keyGroupId
import 'package:wise_apartment/features/smart_lock/data/models/records/shared/record_base_parsers.dart';
import 'package:wise_apartment/features/smart_lock/data/models/records/gen2/hx_record2_base_model.dart';

class HXRecord2DeleteKeyModel extends HXRecord2BaseModel {
  final int operKeyGroupId;
  final int deleteMode;
  final int lockKeyId;
  final int keyType;
  final int keyLen;
  final String key;
  final int keyGroupId;

  const HXRecord2DeleteKeyModel({
    required super.recordTime,
    required super.recordType,
    required super.logVersion,
    required super.modelType,
    super.eventFlag,
    super.power,
    required super.raw,
    required this.operKeyGroupId,
    required this.deleteMode,
    required this.lockKeyId,
    required this.keyType,
    required this.keyLen,
    required this.key,
    required this.keyGroupId,
  });

  factory HXRecord2DeleteKeyModel.fromMap(Map<String, dynamic> map) {
    final int recordTime = asInt(map['recordTime']);
    final int recordType = asInt(map['recordType']);
    final int logVersion = asInt(map['logVersion']);
    final String modelType = asString(map['modelType']);
    final int? eventFlag = asIntOrNull(map['eventFlag']);
    final int? power = asIntOrNull(map['power']);

    final int operKeyGroupId = asInt(map['operKeyGroupId']);
    final int deleteMode = asInt(map['deleteMode']);
    final int lockKeyId = asInt(map['lockKeyId']);
    final int keyType = asInt(map['keyType']);
    final int keyLen = asInt(map['keyLen']);
    final String key = asString(map['key']);
    final int keyGroupId = asInt(map['keyGroupId']);

    final raw = Map<String, dynamic>.from(map);
    for (final k in [
      'recordTime',
      'recordType',
      'logVersion',
      'modelType',
      'eventFlag',
      'power',
      'operKeyGroupId',
      'deleteMode',
      'lockKeyId',
      'keyType',
      'keyLen',
      'key',
      'keyGroupId',
    ])
      raw.remove(k);

    return HXRecord2DeleteKeyModel(
      recordTime: recordTime,
      recordType: recordType,
      logVersion: logVersion,
      modelType: modelType,
      eventFlag: eventFlag,
      power: power,
      raw: raw,
      operKeyGroupId: operKeyGroupId,
      deleteMode: deleteMode,
      lockKeyId: lockKeyId,
      keyType: keyType,
      keyLen: keyLen,
      key: key,
      keyGroupId: keyGroupId,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final m = baseToMap();
    m['operKeyGroupId'] = operKeyGroupId;
    m['deleteMode'] = deleteMode;
    m['lockKeyId'] = lockKeyId;
    m['keyType'] = keyType;
    m['keyLen'] = keyLen;
    m['key'] = key;
    m['keyGroupId'] = keyGroupId;
    m.addAll(raw);
    return m;
  }
}
