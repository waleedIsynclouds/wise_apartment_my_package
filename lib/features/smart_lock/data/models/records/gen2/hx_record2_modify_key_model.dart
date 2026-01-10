// Doc fields: opporKeyGroupId, modifyLockKeyId, modifyLockKeyType, key
import 'package:wise_apartment/features/smart_lock/data/models/records/shared/record_base_parsers.dart';
import 'package:wise_apartment/features/smart_lock/data/models/records/gen2/hx_record2_base_model.dart';

class HXRecord2ModifyKeyModel extends HXRecord2BaseModel {
  final int opporKeyGroupId;
  final int modifyLockKeyId;
  final int modifyLockKeyType;
  final String key;

  const HXRecord2ModifyKeyModel({
    required super.recordTime,
    required super.recordType,
    required super.logVersion,
    required super.modelType,
    super.eventFlag,
    super.power,
    required super.raw,
    required this.opporKeyGroupId,
    required this.modifyLockKeyId,
    required this.modifyLockKeyType,
    required this.key,
  });

  factory HXRecord2ModifyKeyModel.fromMap(Map<String, dynamic> map) {
    final int recordTime = asInt(map['recordTime']);
    final int recordType = asInt(map['recordType']);
    final int logVersion = asInt(map['logVersion']);
    final String modelType = asString(map['modelType']);
    final int? eventFlag = asIntOrNull(map['eventFlag']);
    final int? power = asIntOrNull(map['power']);

    final int opporKeyGroupId = asInt(map['opporKeyGroupId']);
    final int modifyLockKeyId = asInt(map['modifyLockKeyId']);
    final int modifyLockKeyType = asInt(map['modifyLockKeyType']);
    final String key = asString(map['key']);

    final raw = Map<String, dynamic>.from(map);
    for (final k in [
      'recordTime',
      'recordType',
      'logVersion',
      'modelType',
      'eventFlag',
      'power',
      'opporKeyGroupId',
      'modifyLockKeyId',
      'modifyLockKeyType',
      'key',
    ])
      raw.remove(k);

    return HXRecord2ModifyKeyModel(
      recordTime: recordTime,
      recordType: recordType,
      logVersion: logVersion,
      modelType: modelType,
      eventFlag: eventFlag,
      power: power,
      raw: raw,
      opporKeyGroupId: opporKeyGroupId,
      modifyLockKeyId: modifyLockKeyId,
      modifyLockKeyType: modifyLockKeyType,
      key: key,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final m = baseToMap();
    m['opporKeyGroupId'] = opporKeyGroupId;
    m['modifyLockKeyId'] = modifyLockKeyId;
    m['modifyLockKeyType'] = modifyLockKeyType;
    m['key'] = key;
    m.addAll(raw);
    return m;
  }
}
