/// Model representing parameters for deleting a lock key action.
/// 
/// This model supports four deletion modes:
/// - Mode 0: Delete by key number (requires keyType and keyId)
/// - Mode 1: Delete by key type (deletes all non-admin keys of specified type)
/// - Mode 2: Delete by content (requires keyType and cardNumOrPassword)
/// - Mode 3: Delete by user ID (deletes all keys for specified keyGroupId)
class DeleteLockKeyActionModel {
  /// Required: Delete method
  /// - 0: Delete by key number (key type + number)
  /// - 1: Delete by key type (delete all non-administrator keys of the specified key type)
  /// - 2: Delete according to content (card number or password + key type)
  /// - 3: Delete by keyGroupId (user Id), all keys related to this Id will be deleted at once
  int deleteMode;

  /// Optional: Valid when deleteMode == 3
  /// Indicates deletion based on user ID (keyGroupId)
  int? deleteKeyGroupId;

  /// Optional: Valid when deleteMode == 0, 1, or 2
  /// Indicates the key type to delete
  /// 1 = Password, 2 = Fingerprint, 3 = Card, 4 = Remote
  int? deleteKeyType;

  /// Optional: Valid when deleteMode == 0
  /// Indicates the key ID to be deleted
  int? deleteKeyId;

  /// Optional: Valid when deleteMode == 2
  /// Card number: Maximum length of 8 bytes (unused bytes must be reset to zero)
  /// Password: 6-12 digits, can only be numbers, saved as ASCII code
  String? cardNumOrPassword;

  // Key type constants
  static const int keyTypePassword = 1;
  static const int keyTypeFingerprint = 2;
  static const int keyTypeCard = 3;
  static const int keyTypeRemote = 4;

  DeleteLockKeyActionModel({
    this.deleteMode = 0,
    this.deleteKeyGroupId,
    this.deleteKeyType,
    this.deleteKeyId,
    this.cardNumOrPassword,
  });

  factory DeleteLockKeyActionModel.fromMap(Map<String, dynamic>? m) {
    if (m == null) return DeleteLockKeyActionModel();
    
    int? parseInt(Object? v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return DeleteLockKeyActionModel(
      deleteMode: parseInt(m['deleteMode']) ?? 0,
      deleteKeyGroupId: parseInt(m['deleteKeyGroupId']),
      deleteKeyType: parseInt(m['deleteKeyType']),
      deleteKeyId: parseInt(m['deleteKeyId']),
      cardNumOrPassword: m['cardNumOrPassword']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'deleteMode': deleteMode,
    };

    // Only include optional fields if they're set
    if (deleteKeyGroupId != null) map['deleteKeyGroupId'] = deleteKeyGroupId;
    if (deleteKeyType != null) map['deleteKeyType'] = deleteKeyType;
    if (deleteKeyId != null) map['deleteKeyId'] = deleteKeyId;
    if (cardNumOrPassword != null) map['cardNumOrPassword'] = cardNumOrPassword;

    return map;
  }

  /// Validates the model based on the delete mode
  /// Returns a list of validation error messages (empty if valid)
  List<String> validate() {
    final errors = <String>[];

    // Validate deleteMode is in valid range
    if (deleteMode < 0 || deleteMode > 3) {
      errors.add('deleteMode must be 0, 1, 2, or 3');
    }

    // Mode-specific validations
    switch (deleteMode) {
      case 0:
        // Delete by key number: requires keyType and keyId
        if (deleteKeyType == null) {
          errors.add('deleteKeyType is required when deleteMode is 0');
        } else if (deleteKeyType! < 1 || deleteKeyType! > 4) {
          errors.add('deleteKeyType must be 1 (Password), 2 (Fingerprint), 3 (Card), or 4 (Remote)');
        }
        
        if (deleteKeyId == null) {
          errors.add('deleteKeyId is required when deleteMode is 0');
        } else if (deleteKeyId! < 0) {
          errors.add('deleteKeyId must be >= 0');
        }
        break;

      case 1:
        // Delete by key type: requires keyType only
        if (deleteKeyType == null) {
          errors.add('deleteKeyType is required when deleteMode is 1');
        } else if (deleteKeyType! < 1 || deleteKeyType! > 4) {
          errors.add('deleteKeyType must be 1 (Password), 2 (Fingerprint), 3 (Card), or 4 (Remote)');
        }
        break;

      case 2:
        // Delete by content: requires keyType and cardNumOrPassword
        if (deleteKeyType == null) {
          errors.add('deleteKeyType is required when deleteMode is 2');
        } else if (deleteKeyType! < 1 || deleteKeyType! > 4) {
          errors.add('deleteKeyType must be 1 (Password), 2 (Fingerprint), 3 (Card), or 4 (Remote)');
        }
        
        if (cardNumOrPassword == null || cardNumOrPassword!.isEmpty) {
          errors.add('cardNumOrPassword is required when deleteMode is 2');
        } else {
          // Validate based on key type
          if (deleteKeyType == keyTypePassword) {
            // Password: 6-12 digits, only numbers
            if (cardNumOrPassword!.length < 6 || cardNumOrPassword!.length > 12) {
              errors.add('Password must be 6-12 digits');
            }
            if (!RegExp(r'^\d+$').hasMatch(cardNumOrPassword!)) {
              errors.add('Password can only contain numbers');
            }
          } else if (deleteKeyType == keyTypeCard) {
            // Card number: maximum 8 bytes
            if (cardNumOrPassword!.length > 16) {  // 8 bytes = 16 hex chars
              errors.add('Card number maximum length is 8 bytes (16 hex characters)');
            }
          }
        }
        break;

      case 3:
        // Delete by keyGroupId: requires keyGroupId only
        if (deleteKeyGroupId == null) {
          errors.add('deleteKeyGroupId is required when deleteMode is 3');
        } else if (deleteKeyGroupId! < 0) {
          errors.add('deleteKeyGroupId must be >= 0');
        }
        break;
    }

    return errors;
  }

  /// Validates and throws an exception if invalid
  void validateOrThrow() {
    final errors = validate();
    if (errors.isNotEmpty) {
      throw ArgumentError('DeleteLockKeyActionModel validation failed:\n${errors.join('\n')}');
    }
  }

  /// Returns true if the model is valid
  bool get isValid => validate().isEmpty;

  /// Helper: Create a model for deleting by key number
  factory DeleteLockKeyActionModel.byKeyNumber({
    required int keyType,
    required int keyId,
  }) {
    return DeleteLockKeyActionModel(
      deleteMode: 0,
      deleteKeyType: keyType,
      deleteKeyId: keyId,
    );
  }

  /// Helper: Create a model for deleting by key type
  factory DeleteLockKeyActionModel.byKeyType({
    required int keyType,
  }) {
    return DeleteLockKeyActionModel(
      deleteMode: 1,
      deleteKeyType: keyType,
    );
  }

  /// Helper: Create a model for deleting by content
  factory DeleteLockKeyActionModel.byContent({
    required int keyType,
    required String cardNumOrPassword,
  }) {
    return DeleteLockKeyActionModel(
      deleteMode: 2,
      deleteKeyType: keyType,
      cardNumOrPassword: cardNumOrPassword,
    );
  }

  /// Helper: Create a model for deleting by user ID
  factory DeleteLockKeyActionModel.byUserId({
    required int keyGroupId,
  }) {
    return DeleteLockKeyActionModel(
      deleteMode: 3,
      deleteKeyGroupId: keyGroupId,
    );
  }

  @override
  String toString() {
    return 'DeleteLockKeyActionModel(deleteMode: $deleteMode, '
        'deleteKeyGroupId: $deleteKeyGroupId, '
        'deleteKeyType: $deleteKeyType, '
        'deleteKeyId: $deleteKeyId, '
        'cardNumOrPassword: ${cardNumOrPassword != null ? "***" : "null"})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeleteLockKeyActionModel &&
        other.deleteMode == deleteMode &&
        other.deleteKeyGroupId == deleteKeyGroupId &&
        other.deleteKeyType == deleteKeyType &&
        other.deleteKeyId == deleteKeyId &&
        other.cardNumOrPassword == cardNumOrPassword;
  }

  @override
  int get hashCode {
    return Object.hash(
      deleteMode,
      deleteKeyGroupId,
      deleteKeyType,
      deleteKeyId,
      cardNumOrPassword,
    );
  }

  /// Create a copy with updated fields
  DeleteLockKeyActionModel copyWith({
    int? deleteMode,
    int? deleteKeyGroupId,
    int? deleteKeyType,
    int? deleteKeyId,
    String? cardNumOrPassword,
  }) {
    return DeleteLockKeyActionModel(
      deleteMode: deleteMode ?? this.deleteMode,
      deleteKeyGroupId: deleteKeyGroupId ?? this.deleteKeyGroupId,
      deleteKeyType: deleteKeyType ?? this.deleteKeyType,
      deleteKeyId: deleteKeyId ?? this.deleteKeyId,
      cardNumOrPassword: cardNumOrPassword ?? this.cardNumOrPassword,
    );
  }
}
