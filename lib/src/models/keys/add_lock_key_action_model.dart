/// Model representing parameters for adding a lock key action.
class AddLockKeyActionModel {
  String? password;
  int status;
  int localRemoteMode;
  int? authorMode; // nullable per request

  int vaildMode;
  int addedKeyType;
  int addedKeyID;
  int addedKeyGroupId;
  int modifyTimestamp;
  int validStartTime;
  int validEndTime;
  int week;
  int dayStartTimes;
  int dayEndTimes;
  int vaildNumber;

  AddLockKeyActionModel({
    this.password,
    this.status = 0,
    this.localRemoteMode = 1,
    this.authorMode,

    this.vaildMode = 0,
    this.addedKeyType = 0,
    this.addedKeyID = 0,
    this.addedKeyGroupId = 0,
    this.modifyTimestamp = 0,
    this.validStartTime = 0,
    this.validEndTime = 0,
    this.week = 0,
    this.dayStartTimes = 0,
    this.dayEndTimes = 0,
    this.vaildNumber = 255, // Number of authorizations: 0x01: 1 means 1 time
    // 0xFF: 255 means unlimited times
    // 0x00: 0 disable
  });

  factory AddLockKeyActionModel.fromMap(Map<String, dynamic>? m) {
    if (m == null) return AddLockKeyActionModel();
    int? parseInt(Object? v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return AddLockKeyActionModel(
      password: m['password']?.toString(),
      status: parseInt(m['status']) ?? 0,
      localRemoteMode: parseInt(m['localRemoteMode']) ?? 1,
      authorMode: m.containsKey('authorMode')
          ? parseInt(m['authorMode'])
          : null,
      vaildMode: parseInt(m['vaildMode']) ?? 0,
      addedKeyType: parseInt(m['addedKeyType']) ?? 0,
      addedKeyID: parseInt(m['addedKeyID']) ?? 0,
      addedKeyGroupId: parseInt(m['addedKeyGroupId']) ?? 0,
      modifyTimestamp: parseInt(m['modifyTimestamp']) ?? 0,
      validStartTime: parseInt(m['validStartTime']) ?? 0,
      validEndTime: parseInt(m['validEndTime']) ?? 0,
      week: parseInt(m['week']) ?? 0,
      dayStartTimes: parseInt(m['dayStartTimes']) ?? 0,
      dayEndTimes: parseInt(m['dayEndTimes']) ?? 0,
      vaildNumber: parseInt(m['vaildNumber']) ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'password': password,
    'status': status,
    'localRemoteMode': localRemoteMode,
    if (authorMode != null) 'authorMode': authorMode,

    'vaildMode': vaildMode,
    'addedKeyType': addedKeyType,
    'addedKeyID': addedKeyID,
    'addedKeyGroupId': addedKeyGroupId,
    'modifyTimestamp': modifyTimestamp,
    'validStartTime': validStartTime,
    'validEndTime': validEndTime,
    'week': week,
    'dayStartTimes': dayStartTimes,
    'dayEndTimes': dayEndTimes,
    'vaildNumber': vaildNumber,
  };

  /// Validate the model fields according to the rules expected by the lock.
  ///
  /// Returns a list of validation error messages. If the list is empty, the
  /// model is considered valid.
  List<String> validate({int? authMode}) {
    final errors = <String>[];

    // authorMode == 1 requires a 6-12 digit password (or card number)
    if (authorMode == 1) {
      if (password == null || !RegExp(r'^\d{6,12}$').hasMatch(password!)) {
        errors.add(
          'When authorMode==1, password (or card number) is required and must be 6-12 digits.',
        );
      }
    }

    // vaildMode==1 requires valid week and daily start/end times
    if (vaildMode == 1) {
      if (week == 0) errors.add('vaildMode==1 requires non-zero week bitmask.');
      if (dayStartTimes < 0 || dayStartTimes > 1439) {
        errors.add('dayStartTimes must be in 0..1439.');
      }
      if (dayEndTimes < 0 || dayEndTimes > 1439) {
        errors.add('dayEndTimes must be in 0..1439.');
      }
      if (dayEndTimes <= dayStartTimes) {
        errors.add('dayEndTimes must be greater than dayStartTimes.');
      }
    }

    // start/end time rules
    if (validStartTime < 0) errors.add('validStartTime must be >= 0.');
    if (!(validEndTime == 0xFFFFFFFF || validEndTime >= validStartTime)) {
      errors.add('validEndTime must be 0xFFFFFFFF or >= validStartTime.');
    }

    // valid number range
    if (vaildNumber < 0 || vaildNumber > 0xFF) {
      errors.add('vaildNumber must be between 0 and 255.');
    }

    // optional authMode-aware check for addedKeyType
    if (authMode != null) {
      final allowedAuth0 = {addedFingerprint, addedCard, addedRemote};
      final allowedAuth1 = {addedPassword, addedCard};
      if (authMode == 0) {
        if (!allowedAuth0.contains(addedKeyType)) {
          errors.add('For authMode==0, addedKeyType must be one of: 1,4,8.');
        }
      } else if (authMode == 1) {
        if (!allowedAuth1.contains(addedKeyType)) {
          errors.add('For authMode==1, addedKeyType must be one of: 2,4.');
        }
      }
    }

    // status/localRemoteMode basic sanity
    if (localRemoteMode < 0) errors.add('localRemoteMode must be >= 0.');
    if (status < 0) errors.add('status must be >= 0.');

    // ensure group id is provided
    if (addedKeyGroupId <= 0)
      errors.add('addedKeyGroupId must be > 0 and is required.');

    return errors;
  }

  /// Validate and throw [ArgumentError] on first failure.
  void validateOrThrow({int? authMode}) {
    final errs = validate(authMode: authMode);
    if (errs.isNotEmpty) throw ArgumentError(errs.join('; '));
  }

  /// Helper constants and methods for `addedKeyType`.
  ///
  /// Mapping:
  /// - When authMode == 0 (lock in normal mode):
  ///   1 -> fingerprint
  ///   4 -> card
  ///   8 -> remote control
  /// - When authMode == 1 (password mode):
  ///   2 -> password
  ///   4 -> card number
  static const int addedFingerprint = 1;
  static const int addedCard = 4;
  static const int addedRemote = 8;
  static const int addedPassword = 2;
  // vaildNumber sentinel values
  static const int vaildNumberOneTime = 0x01;
  static const int vaildNumberUnlimited = 0xFF;
  static const int vaildNumberDisable = 0x00;

  /// Force delivery mode to the fixed value expected by the protocol.
  /// The protocol defines `localRemoteMode` default as `1` and it should
  /// not be changed by callers; this helper enforces that.
  void enforceLocalRemoteMode() {
    localRemoteMode = 1;
  }

  /// Set author mode and apply sensible defaults for `addedKeyType` when not
  /// already set. `mode` should be 0 or 1 per protocol.
  void setAuthorMode(int mode) {
    authorMode = mode;
    if (addedKeyType == 0) {
      addedKeyType = (mode == 1) ? addedPassword : addedFingerprint;
    }
  }

  /// Set `addedKeyType` from a textual `choice`, using the current
  /// `authorMode` (defaults to 0 if unset).
  void setAddedKeyTypeFromChoice(String choice) {
    final mode = authorMode ?? 0;
    final t = computeAddedKeyType(authMode: mode, choice: choice);
    if (t != 0) addedKeyType = t;
  }

  /// Compute the proper `addedKeyType` value for a given `authMode` and a textual choice.
  /// `choice` can be one of: 'fingerprint','card','remote','password','cardNumber'.
  static int computeAddedKeyType({
    required int authMode,
    required String choice,
  }) {
    final c = choice.toLowerCase();
    if (authMode == 0) {
      if (c == 'fingerprint') return addedFingerprint;
      if (c == 'card') return addedCard;
      if (c == 'remote' || c == 'remotecontrol' || c == 'remote_control') {
        return addedRemote;
      }
    } else if (authMode == 1) {
      if (c == 'password') return addedPassword;
      if (c == 'card' || c == 'cardnumber' || c == 'card_number') {
        return addedCard;
      }
    }
    return 0;
  }

  /// Compute flag as per original Java logic.
  int getFlag() {
    int var1 = (localRemoteMode == 1) ? 1 : 0;
    int var2 = (authorMode == 1) ? 2 : 0;
    int var3 = (vaildMode == 1) ? 4 : 0;
    return var1 | var2 | var3;
  }

  /// Convert a set of weekday indexes (1..7) into a week bitmask used by the
  /// lock: bit 0 -> day 1, bit 1 -> day 2, ... bit 6 -> day 7.
  /// Example: days {1,3,5} -> bits (1<<0)|(1<<2)|(1<<4)
  static int computeWeekMaskFromDays(Set<int> days) {
    if (days.isEmpty) return 0;
    var mask = 0;
    for (final d in days) {
      if (d >= 1 && d <= 7) mask |= (1 << (d - 1));
    }
    return mask;
  }

  /// Convert a [DateTime] to epoch seconds (UTC). Returns 0 for null.
  static int dateTimeToEpochSeconds(DateTime? dt) {
    if (dt == null) return 0;
    return dt.toUtc().millisecondsSinceEpoch ~/ 1000;
  }

  /// Configure this model as a one-time key. Optional [start] and [end]
  /// control the single-use time window. If [end] is omitted, it will be set
  /// to [start] (if provided) or 0.
  void applyOneTime({DateTime? start, DateTime? end, int? groupId}) {
    vaildMode = 0;
    validStartTime = dateTimeToEpochSeconds(start);
    if (end != null) {
      validEndTime = dateTimeToEpochSeconds(end);
    } else {
      validEndTime = validStartTime > 0 ? validStartTime : 0;
    }
    vaildNumber = 0x01;
    week = 0;
    dayStartTimes = 0;
    dayEndTimes = 0;
    if (groupId != null) addedKeyGroupId = groupId;
  }

  /// Configure this model as a permanent key (unlimited times, no time bounds).
  void applyPermanent({int? groupId}) {
    vaildMode = 0;
    validStartTime = 0;
    validEndTime = 0xFFFFFFFF;
    vaildNumber = 0xFF;
    week = 0;
    dayStartTimes = 0;
    dayEndTimes = 0;
    if (groupId != null) addedKeyGroupId = groupId;
  }

  /// Configure this model as a repeating (cycle) key.
  /// [days] are 1..7 (day-of-week). [dailyStartMinutes]/[dailyEndMinutes]
  /// are minutes since midnight (0..1439). Optional [start]/[end] are the
  /// overall active range. [vaildNumberVal] defaults to unlimited (0xFF).
  void applyCycle({
  required Set<int> days,
  required int dailyStartMinutes,
  required int dailyEndMinutes,
  DateTime? start,
  DateTime? end,
  int vaildNumberVal = 0xFF,
}) {
  // Cycle mode
  vaildMode = 1;

  // Week mask MUST be non-zero in cycle mode
  week = computeWeekMaskFromDays(days);
  if (week == 0) {
    // If caller passes empty/invalid days => SDK will throw parameter error
    // Choose a safe default (all week) instead of sending 0
    week = 0x7F; // 0b1111111 (7 days)
  }

  // Clamp minutes to 0..1439
  int clampMinutes(int v) {
    if (v < 0) return 0;
    if (v > 1439) return 1439;
    return v;
  }

  dayStartTimes = clampMinutes(dailyStartMinutes);
  dayEndTimes = clampMinutes(dailyEndMinutes);

  // SDK expects end > start when validMode==1
  if (dayEndTimes <= dayStartTimes) {
    // Auto-fix: make it at least +1 minute
    dayEndTimes = (dayStartTimes == 1439) ? 1439 : (dayStartTimes + 1);
  }

  // Overall active range (epoch seconds)
  validStartTime = dateTimeToEpochSeconds(start);

  // IMPORTANT:
  // Many native SDKs use 0xFFFFFFFF as "unlimited", but passing 4294967295
  // through MethodChannel can cause parameter errors (int/long conversion).
  // Using -1 is safer and usually treated as 0xFFFFFFFF on native side.
  validEndTime = (end != null) ? dateTimeToEpochSeconds(end) : -1;

  // valid number clamp (0..255)
  if (vaildNumberVal < 0) {
    vaildNumber = 0;
  } else if (vaildNumberVal > 0xFF) {
    vaildNumber = 0xFF;
  } else {
    vaildNumber = vaildNumberVal;
  }
}

  /// Configure this model as a limited-use key with an explicit number of
  /// usages. [vaildNumberVal] must be in 0..255. Optional [start]/[end]
  /// define the active period.
  void applyLimit({
    required int vaildNumberVal,
    DateTime? start,
    DateTime? end,
  }) {
    vaildMode = 0;
    validStartTime = dateTimeToEpochSeconds(start);
    validEndTime = end != null ? dateTimeToEpochSeconds(end) : 0;
    vaildNumber = (vaildNumberVal < 0)
        ? 0
        : (vaildNumberVal > 0xFF ? 0xFF : vaildNumberVal);
    week = 0;
    dayStartTimes = 0;
    dayEndTimes = 0;
  }
}

/// Result returned by the lock after an AddKey operation.
class AddLockKeyResult {
  final int authorNum;
  final int authorTimes;
  final int keyId;

  AddLockKeyResult({this.authorNum = 0, this.authorTimes = 0, this.keyId = 0});

  factory AddLockKeyResult.fromMap(Map<String, dynamic>? m) {
    if (m == null) return AddLockKeyResult();
    int parseInt(Object? v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    final authorNum = parseInt(
      m['authorNum'] ?? m['AuthorNum'] ?? m['author_num'],
    );
    final authorTimes = parseInt(
      m['AuthorTimes'] ?? m['authorTimes'] ?? m['author_times'],
    );
    final keyId = parseInt(
      m['lockKeyId'] ?? m['lockKeyID'] ?? m['keyId'] ?? m['key_id'],
    );

    return AddLockKeyResult(
      authorNum: authorNum,
      authorTimes: authorTimes,
      keyId: keyId,
    );
  }
}
