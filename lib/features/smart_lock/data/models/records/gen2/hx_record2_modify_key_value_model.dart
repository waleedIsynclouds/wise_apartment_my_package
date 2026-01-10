// Doc fields: opporKeyGroupId, keyType, keyLen, key, vaildNumber, modifyLockKeyId, modifyKeyGroupId
import 'package:wise_apartment/features/smart_lock/data/models/records/shared/record_base_parsers.dart';
import 'package:wise_apartment/features/smart_lock/data/models/records/gen2/hx_record2_base_model.dart';

class HXRecord2ModifyKeyValueModel extends HXRecord2BaseModel {
  final int opporKeyGroupId;
  final int keyType;
  final int keyLen;
  final String key;
  final int vaildNumber;
  final int modifyLockKeyId;
  final int modifyKeyGroupId;

  const HXRecord2ModifyKeyValueModel({
    required super.recordTime,
    required super.recordType,
    required super.logVersion,
    required super.modelType,
    super.eventFlag,
    super.power,
    required super.raw,
    required this.opporKeyGroupId,
    required this.keyType,
    required this.keyLen,
    required this.key,
    required this.vaildNumber,
    required this.modifyLockKeyId,
    required this.modifyKeyGroupId,
  });

  factory HXRecord2ModifyKeyValueModel.fromMap(Map<String, dynamic> map) {
    final int recordTime = asInt(map['recordTime']);
    final int recordType = asInt(map['recordType']);
    final int logVersion = asInt(map['logVersion']);
    final String modelType = asString(map['modelType']);
    final int? eventFlag = asIntOrNull(map['eventFlag']);
    final int? power = asIntOrNull(map['power']);

    final int opporKeyGroupId = asInt(map['opporKeyGroupId']);
    final int keyType = asInt(map['keyType']);
    final int keyLen = asInt(map['keyLen']);
    final String key = asString(map['key']);
    final int vaildNumber = asInt(map['vaildNumber']);
    final int modifyLockKeyId = asInt(map['modifyLockKeyId']);
    final int modifyKeyGroupId = asInt(map['modifyKeyGroupId']);

    final raw = Map<String, dynamic>.from(map);
    for (final k in [
      'recordTime',
      'recordType',
      'logVersion',
      'modelType',
      'eventFlag',
      'power',
      'opporKeyGroupId',
      'keyType',
      'keyLen',
      'key',
      'vaildNumber',
      'modifyLockKeyId',
      'modifyKeyGroupId',
    ])
      raw.remove(k);

    return HXRecord2ModifyKeyValueModel(
      recordTime: recordTime,
      recordType: recordType,
      logVersion: logVersion,
      modelType: modelType,
      eventFlag: eventFlag,
      power: power,
      raw: raw,
      opporKeyGroupId: opporKeyGroupId,
      keyType: keyType,
      keyLen: keyLen,
      key: key,
      vaildNumber: vaildNumber,
      modifyLockKeyId: modifyLockKeyId,
      modifyKeyGroupId: modifyKeyGroupId,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final m = baseToMap();
    m['opporKeyGroupId'] = opporKeyGroupId;
    m['keyType'] = keyType;
    m['keyLen'] = keyLen;
    m['key'] = key;
    m['vaildNumber'] = vaildNumber;
    m['modifyLockKeyId'] = modifyLockKeyId;
    m['modifyKeyGroupId'] = modifyKeyGroupId;
    m.addAll(raw);
    return m;
  }
}
