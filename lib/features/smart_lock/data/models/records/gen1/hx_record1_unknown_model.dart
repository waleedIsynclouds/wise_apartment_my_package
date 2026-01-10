// Unknown fallback for gen1
import 'package:wise_apartment/features/smart_lock/data/models/records/gen1/hx_record1_base_model.dart';
import 'package:wise_apartment/features/smart_lock/data/models/records/shared/record_base_parsers.dart';

class HXRecord1UnknownModel extends HXRecord1BaseModel {
  const HXRecord1UnknownModel({
    required super.recordTime,
    required super.recordType,
    required super.logVersion,
    required super.modelType,
    super.eventFlag,
    super.power,
    required super.raw,
  });

  factory HXRecord1UnknownModel.fromMap(Map<String, dynamic> map) {
    final int recordTime = asInt(map['recordTime']);
    final int recordType = asInt(map['recordType']);
    final int logVersion = asInt(map['logVersion']);
    final String modelType = asString(map['modelType']);
    final int? eventFlag = asIntOrNull(map['eventFlag']);
    final int? power = asIntOrNull(map['power']);

    final raw = Map<String, dynamic>.from(map);
    for (final k in [
      'recordTime',
      'recordType',
      'logVersion',
      'modelType',
      'eventFlag',
      'power',
    ])
      raw.remove(k);

    return HXRecord1UnknownModel(
      recordTime: recordTime,
      recordType: recordType,
      logVersion: logVersion,
      modelType: modelType,
      eventFlag: eventFlag,
      power: power,
      raw: raw,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final m = baseToMap();
    m.addAll(raw);
    return m;
  }
}
