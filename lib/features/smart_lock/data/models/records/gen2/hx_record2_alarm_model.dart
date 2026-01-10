// Doc fields: faultType, lockKeyId
import 'package:wise_apartment/features/smart_lock/data/models/records/shared/record_base_parsers.dart';
import 'package:wise_apartment/features/smart_lock/data/models/records/gen2/hx_record2_base_model.dart';

class HXRecord2AlarmModel extends HXRecord2BaseModel {
  final int faultType;
  final int lockKeyId;

  const HXRecord2AlarmModel({
    required super.recordTime,
    required super.recordType,
    required super.logVersion,
    required super.modelType,
    super.eventFlag,
    super.power,
    required super.raw,
    required this.faultType,
    required this.lockKeyId,
  });

  factory HXRecord2AlarmModel.fromMap(Map<String, dynamic> map) {
    final int recordTime = asInt(map['recordTime']);
    final int recordType = asInt(map['recordType']);
    final int logVersion = asInt(map['logVersion']);
    final String modelType = asString(map['modelType']);
    final int? eventFlag = asIntOrNull(map['eventFlag']);
    final int? power = asIntOrNull(map['power']);

    final int faultType = asInt(map['faultType']);
    final int lockKeyId = asInt(map['lockKeyId']);

    final raw = Map<String, dynamic>.from(map);
    for (final k in [
      'recordTime',
      'recordType',
      'logVersion',
      'modelType',
      'eventFlag',
      'power',
      'faultType',
      'lockKeyId',
    ]) {
      raw.remove(k);
    }

    return HXRecord2AlarmModel(
      recordTime: recordTime,
      recordType: recordType,
      logVersion: logVersion,
      modelType: modelType,
      eventFlag: eventFlag,
      power: power,
      raw: raw,
      faultType: faultType,
      lockKeyId: lockKeyId,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final m = baseToMap();
    m['faultType'] = faultType;
    m['lockKeyId'] = lockKeyId;
    m.addAll(raw);
    return m;
  }
}
