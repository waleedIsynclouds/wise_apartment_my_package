// Doc fields: operKeyGroupId, operMode, modifyLockKeyId, modifyKeyTypes, modifyKeyGroupId, enable
import 'package:wise_apartment/features/smart_lock/data/models/records/shared/record_base_parsers.dart';
import 'package:wise_apartment/features/smart_lock/data/models/records/gen2/hx_record2_base_model.dart';

class HXRecord2KeyenableModel extends HXRecord2BaseModel {
  final int operKeyGroupId;
  final int operMode;
  final int modifyLockKeyId;
  final int modifyKeyTypes;
  final int modifyKeyGroupId;
  final int enable;

  const HXRecord2KeyenableModel({
    required super.recordTime,
    required super.recordType,
    required super.logVersion,
    required super.modelType,
    super.eventFlag,
    super.power,
    required super.raw,
    required this.operKeyGroupId,
    required this.operMode,
    required this.modifyLockKeyId,
    required this.modifyKeyTypes,
    required this.modifyKeyGroupId,
    required this.enable,
  });

  factory HXRecord2KeyenableModel.fromMap(Map<String, dynamic> map) {
    final int recordTime = asInt(map['recordTime']);
    final int recordType = asInt(map['recordType']);
    final int logVersion = asInt(map['logVersion']);
    final String modelType = asString(map['modelType']);
    final int? eventFlag = asIntOrNull(map['eventFlag']);
    final int? power = asIntOrNull(map['power']);

    final int operKeyGroupId = asInt(map['operKeyGroupId']);
    final int operMode = asInt(map['operMode']);
    final int modifyLockKeyId = asInt(map['modifyLockKeyId']);
    final int modifyKeyTypes = asInt(map['modifyKeyTypes']);
    final int modifyKeyGroupId = asInt(map['modifyKeyGroupId']);
    final int enable = asInt(map['enable']);

    final raw = Map<String, dynamic>.from(map);
    for (final k in [
      'recordTime',
      'recordType',
      'logVersion',
      'modelType',
      'eventFlag',
      'power',
      'operKeyGroupId',
      'operMode',
      'modifyLockKeyId',
      'modifyKeyTypes',
      'modifyKeyGroupId',
      'enable',
    ])
      raw.remove(k);

    return HXRecord2KeyenableModel(
      recordTime: recordTime,
      recordType: recordType,
      logVersion: logVersion,
      modelType: modelType,
      eventFlag: eventFlag,
      power: power,
      raw: raw,
      operKeyGroupId: operKeyGroupId,
      operMode: operMode,
      modifyLockKeyId: modifyLockKeyId,
      modifyKeyTypes: modifyKeyTypes,
      modifyKeyGroupId: modifyKeyGroupId,
      enable: enable,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final m = baseToMap();
    m['operKeyGroupId'] = operKeyGroupId;
    m['operMode'] = operMode;
    m['modifyLockKeyId'] = modifyLockKeyId;
    m['modifyKeyTypes'] = modifyKeyTypes;
    m['modifyKeyGroupId'] = modifyKeyGroupId;
    m['enable'] = enable;
    m.addAll(raw);
    return m;
  }
}
