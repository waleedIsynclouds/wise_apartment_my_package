// Doc fields: opporKeyGroupId, keyStatus, keyType, keyLen, key
import 'package:wise_apartment/features/smart_lock/data/models/records/shared/record_base_parsers.dart';
import 'package:wise_apartment/features/smart_lock/data/models/records/gen2/hx_record2_base_model.dart';

class HXRecord2WrongKeyUnlockModel extends HXRecord2BaseModel {
  final int opporKeyGroupId;
  final int keyStatus;
  final int keyType;
  final int keyLen;
  final String key;

  const HXRecord2WrongKeyUnlockModel({
    required super.recordTime,
    required super.recordType,
    required super.logVersion,
    required super.modelType,
    super.eventFlag,
    super.power,
    required super.raw,
    required this.opporKeyGroupId,
    required this.keyStatus,
    required this.keyType,
    required this.keyLen,
    required this.key,
  });

  factory HXRecord2WrongKeyUnlockModel.fromMap(Map<String, dynamic> map) {
    final int recordTime = asInt(map['recordTime']);
    final int recordType = asInt(map['recordType']);
    final int logVersion = asInt(map['logVersion']);
    final String modelType = asString(map['modelType']);
    final int? eventFlag = asIntOrNull(map['eventFlag']);
    final int? power = asIntOrNull(map['power']);

    final int opporKeyGroupId = asInt(map['opporKeyGroupId']);
    final int keyStatus = asInt(map['keyStatus']);
    final int keyType = asInt(map['keyType']);
    final int keyLen = asInt(map['keyLen']);
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
      'keyStatus',
      'keyType',
      'keyLen',
      'key',
    ])
      raw.remove(k);

    return HXRecord2WrongKeyUnlockModel(
      recordTime: recordTime,
      recordType: recordType,
      logVersion: logVersion,
      modelType: modelType,
      eventFlag: eventFlag,
      power: power,
      raw: raw,
      opporKeyGroupId: opporKeyGroupId,
      keyStatus: keyStatus,
      keyType: keyType,
      keyLen: keyLen,
      key: key,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final m = baseToMap();
    m['opporKeyGroupId'] = opporKeyGroupId;
    m['keyStatus'] = keyStatus;
    m['keyType'] = keyType;
    m['keyLen'] = keyLen;
    m['key'] = key;
    m.addAll(raw);
    return m;
  }
}
