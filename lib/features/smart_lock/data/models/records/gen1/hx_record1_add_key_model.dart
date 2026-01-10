// Doc fields: opporKeyGroupId, addLockKeyId, keyType
import 'package:wise_apartment/features/smart_lock/data/models/records/gen1/hx_record1_base_model.dart';
import 'package:wise_apartment/features/smart_lock/data/models/records/shared/record_base_parsers.dart';

class HXRecord1AddKeyModel extends HXRecord1BaseModel {
  final int opporKeyGroupId;
  final int addLockKeyId;
  final int keyType;

  const HXRecord1AddKeyModel({
    required super.recordTime,
    required super.recordType,
    required super.logVersion,
    required super.modelType,
    super.eventFlag,
    super.power,
    required super.raw,
    required this.opporKeyGroupId,
    required this.addLockKeyId,
    required this.keyType,
  });

  factory HXRecord1AddKeyModel.fromMap(Map<String, dynamic> map) {
    final int recordTime = asInt(map['recordTime']);
    final int recordType = asInt(map['recordType']);
    final int logVersion = asInt(map['logVersion']);
    final String modelType = asString(map['modelType']);
    final int? eventFlag = asIntOrNull(map['eventFlag']);
    final int? power = asIntOrNull(map['power']);

    final int opporKeyGroupId = asInt(map['opporKeyGroupId']);
    final int addLockKeyId = asInt(map['addLockKeyId']);
    final int keyType = asInt(map['keyType']);

    final raw = Map<String, dynamic>.from(map);
    for (final k in [
      'recordTime',
      'recordType',
      'logVersion',
      'modelType',
      'eventFlag',
      'power',
      'opporKeyGroupId',
      'addLockKeyId',
      'keyType',
    ])
      raw.remove(k);

    return HXRecord1AddKeyModel(
      recordTime: recordTime,
      recordType: recordType,
      logVersion: logVersion,
      modelType: modelType,
      eventFlag: eventFlag,
      power: power,
      raw: raw,
      opporKeyGroupId: opporKeyGroupId,
      addLockKeyId: addLockKeyId,
      keyType: keyType,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final m = baseToMap();
    m['opporKeyGroupId'] = opporKeyGroupId;
    m['addLockKeyId'] = addLockKeyId;
    m['keyType'] = keyType;
    m.addAll(raw);
    return m;
  }
}
