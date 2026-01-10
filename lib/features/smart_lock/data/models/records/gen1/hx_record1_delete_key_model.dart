// Doc fields: opporKeyGroupId, delLockKeyId
import 'package:wise_apartment/features/smart_lock/data/models/records/gen1/hx_record1_base_model.dart';
import 'package:wise_apartment/features/smart_lock/data/models/records/shared/record_base_parsers.dart';

class HXRecord1DeleteKeyModel extends HXRecord1BaseModel {
  final int opporKeyGroupId;
  final int delLockKeyId;

  const HXRecord1DeleteKeyModel({
    required super.recordTime,
    required super.recordType,
    required super.logVersion,
    required super.modelType,
    super.eventFlag,
    super.power,
    required super.raw,
    required this.opporKeyGroupId,
    required this.delLockKeyId,
  });

  factory HXRecord1DeleteKeyModel.fromMap(Map<String, dynamic> map) {
    final int recordTime = asInt(map['recordTime']);
    final int recordType = asInt(map['recordType']);
    final int logVersion = asInt(map['logVersion']);
    final String modelType = asString(map['modelType']);
    final int? eventFlag = asIntOrNull(map['eventFlag']);
    final int? power = asIntOrNull(map['power']);

    final int opporKeyGroupId = asInt(map['opporKeyGroupId']);
    final int delLockKeyId = asInt(map['delLockKeyId']);

    final raw = Map<String, dynamic>.from(map);
    for (final k in [
      'recordTime',
      'recordType',
      'logVersion',
      'modelType',
      'eventFlag',
      'power',
      'opporKeyGroupId',
      'delLockKeyId',
    ])
      raw.remove(k);

    return HXRecord1DeleteKeyModel(
      recordTime: recordTime,
      recordType: recordType,
      logVersion: logVersion,
      modelType: modelType,
      eventFlag: eventFlag,
      power: power,
      raw: raw,
      opporKeyGroupId: opporKeyGroupId,
      delLockKeyId: delLockKeyId,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final m = baseToMap();
    m['opporKeyGroupId'] = opporKeyGroupId;
    m['delLockKeyId'] = delLockKeyId;
    m.addAll(raw);
    return m;
  }
}
