/// Model representing parameters for modifying a lock key's validity period.
/// This command is only supported when bleProtoVer >= 0x0d (13).
class ModifyKeyActionModel {
  /// 1: Validity period authorization, 2: Time period authorization
  int authorMode;

  /// If changeMode = 0x01: key ID; if changeMode = 0x02: user ID
  int changeID;

  /// 0x01: Modify by key ID, 0x02: Modify by user ID
  int changeMode;

  /// Valid when AuthMode=2, format 00:00~23:59, unit: minutes from 0:00
  /// Start must be less than end time
  int dayEndTimes;

  /// Valid when AuthMode=2, format 00:00~23:59, unit: minutes from 0:00
  int dayStartTimes;

  /// Key creation timestamp
  int modifyTimestamp;

  /// Status flags. Bit 3 == 1: door lock does not give voice prompts
  int status;

  /// 0x00: Number remains unchanged
  /// 0x01 ~ 0xFE: Number of valid times
  /// 0xFF: Unlimited times
  int vaildNumber;

  /// Key's end validity period (second timestamp)
  /// Permanent authorization: ValidEndTime = 0xFFFFFFFF
  int validEndTime;

  /// Key's start validity period (second timestamp)
  /// Permanent authorization: ValidStartTime = 0x00000000
  int validStartTime;

  /// Valid when AuthMode=2, bit fields bit0~bit6 respectively
  /// Set corresponding bit to 1 means key is valid on that day
  int weeks;

  ModifyKeyActionModel({
    this.authorMode = 1,
    this.changeID = 0,
    this.changeMode = 1,
    this.dayEndTimes = 1439, // 23:59
    this.dayStartTimes = 0, // 00:00
    this.modifyTimestamp = 0,
    this.status = 0,
    this.vaildNumber = 0xFF, // Unlimited by default
    this.validEndTime = 0xFFFFFFFF, // Permanent by default
    this.validStartTime = 0,
    this.weeks = 0x7F, // All days by default (bit0-bit6 set)
  });

  factory ModifyKeyActionModel.fromMap(Map<String, dynamic>? m) {
    if (m == null) return ModifyKeyActionModel();

    int? parseInt(Object? v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return ModifyKeyActionModel(
      authorMode: parseInt(m['authorMode']) ?? 1,
      changeID: parseInt(m['changeID']) ?? 0,
      changeMode: parseInt(m['changeMode']) ?? 1,
      dayEndTimes: parseInt(m['dayEndTimes']) ?? 1439,
      dayStartTimes: parseInt(m['dayStartTimes']) ?? 0,
      modifyTimestamp: parseInt(m['modifyTimestamp']) ?? 0,
      status: parseInt(m['status']) ?? 0,
      vaildNumber: parseInt(m['vaildNumber']) ?? 0xFF,
      validEndTime: parseInt(m['validEndTime']) ?? 0xFFFFFFFF,
      validStartTime: parseInt(m['validStartTime']) ?? 0,
      weeks: parseInt(m['weeks'] ?? m['week']) ?? 0x7F,
    );
  }

  Map<String, dynamic> toMap() => {
    'authorMode': authorMode,
    'changeID': changeID,
    'changeMode': changeMode,
    'dayEndTimes': dayEndTimes,
    'dayStartTimes': dayStartTimes,
    'modifyTimestamp': modifyTimestamp,
    'status': status,
    'vaildNumber': vaildNumber,
    'validEndTime': validEndTime,
    'validStartTime': validStartTime,
    'weeks': weeks,
  };

  /// Validates the model and returns a list of error messages.
  /// Returns empty list if valid.
  List<String> validate() {
    final errors = <String>[];

    // AuthorMode validation
    if (authorMode != 1 && authorMode != 2) {
      errors.add('authorMode must be 1 (validity period) or 2 (time period)');
    }

    // ChangeMode validation
    if (changeMode != 1 && changeMode != 2) {
      errors.add('changeMode must be 1 (by key ID) or 2 (by user ID)');
    }

    // ChangeID validation
    if (changeID < 0) {
      errors.add('changeID must be non-negative');
    }

    // Day times validation (only when AuthMode = 2)
    if (authorMode == 2) {
      if (dayStartTimes < 0 || dayStartTimes > 1439) {
        errors.add('dayStartTimes must be 0-1439 (00:00-23:59 in minutes)');
      }
      if (dayEndTimes < 0 || dayEndTimes > 1439) {
        errors.add('dayEndTimes must be 0-1439 (00:00-23:59 in minutes)');
      }
      if (dayStartTimes >= dayEndTimes) {
        errors.add('dayStartTimes must be less than dayEndTimes');
      }
      if (weeks < 0 || weeks > 0x7F) {
        errors.add('weeks must be 0-127 (bit fields for days 0-6)');
      }
    }

    // ValidNumber validation
    if (vaildNumber < 0 || vaildNumber > 0xFF) {
      errors.add('vaildNumber must be 0-255');
    }

    // Timestamp validation
    if (validStartTime < 0) {
      errors.add('validStartTime must be non-negative');
    }
    if (validEndTime < 0) {
      errors.add('validEndTime must be non-negative');
    }
    if (validStartTime > 0 &&
        validEndTime > 0 &&
        validStartTime >= validEndTime) {
      errors.add(
        'validStartTime must be less than validEndTime (unless using permanent values)',
      );
    }

    return errors;
  }

  /// Validates and throws [ArgumentError] if invalid.
  void validateOrThrow() {
    final errors = validate();
    if (errors.isNotEmpty) {
      throw ArgumentError(
        'ModifyKeyActionModel validation failed:\n${errors.join('\n')}',
      );
    }
  }

  @override
  String toString() {
    return 'ModifyKeyActionModel(authorMode: $authorMode, changeID: $changeID, changeMode: $changeMode, '
        'validStartTime: $validStartTime, validEndTime: $validEndTime, vaildNumber: $vaildNumber)';
  }
}
