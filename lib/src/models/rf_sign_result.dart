/// RF Sign registration result from the lock device.
///
/// This model represents real-time status updates during RF module registration.
/// Events are emitted through [WiseApartment.regwithRfSignStream].
class RfSignResult {
  /// Operation mode / status code from the device
  ///
  /// Status codes:
  /// - 0x02: NB-IoT (WIFI module) is in the process of network distribution binding operation
  /// - 0x04: WiFi module is successfully connected to the router (may not return)
  /// - 0x05: WiFi module is successfully connected to the cloud (network configuration is successful) (may not return)
  /// - 0x06: Incorrect password (may not return)
  /// - 0x07: WIFI pairing timeout (may not return)
  final int operMode;

  /// MAC address of the wireless module (0 for less than 8 Bytes)
  final String moduleMac;

  /// Original module MAC address from the device
  final String originalModuleMac;

  /// Timestamp when the event was received
  final DateTime timestamp;

  const RfSignResult({
    required this.operMode,
    required this.moduleMac,
    required this.originalModuleMac,
    required this.timestamp,
  });

  /// Creates a [RfSignResult] from a Map received from native platform
  factory RfSignResult.fromMap(Map<String, dynamic> map) {
    return RfSignResult(
      operMode: (map['operMode'] as num?)?.toInt() ?? 0,
      moduleMac: map['moduleMac'] as String? ?? '',
      originalModuleMac: map['originalModuleMac'] as String? ?? '',
      timestamp: DateTime.now(),
    );
  }

  /// Converts this result to a Map
  Map<String, dynamic> toMap() {
    return {
      'operMode': operMode,
      'moduleMac': moduleMac,
      'originalModuleMac': originalModuleMac,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Status code constants
  static const int statusBindingInProgress = 0x02;
  static const int statusRouterConnected = 0x04;
  static const int statusCloudConnected = 0x05;
  static const int statusIncorrectPassword = 0x06;
  static const int statusTimeout = 0x07;

  /// Returns true if this is a success status (0x05)
  bool get isSuccess => operMode == statusCloudConnected;

  /// Returns true if this is an error status (0x06, 0x07)
  bool get isError =>
      operMode == statusIncorrectPassword || operMode == statusTimeout;

  /// Returns true if this is a progress status (0x02, 0x04)
  bool get isProgress =>
      operMode == statusBindingInProgress || operMode == statusRouterConnected;

  /// Returns true if this is a terminal state (success or error)
  bool get isTerminal => isSuccess || isError;

  /// Returns the operation mode as a hex string (e.g., "0x05")
  String get operModeHex => '0x${operMode.toRadixString(16).padLeft(2, '0')}';

  /// Returns a friendly name for the operation mode
  String get operModeName {
    switch (operMode) {
      case statusBindingInProgress:
        return 'Network Binding in Progress';
      case statusRouterConnected:
        return 'Router Connected';
      case statusCloudConnected:
        return 'Cloud Connected (Success)';
      case statusIncorrectPassword:
        return 'Incorrect Password';
      case statusTimeout:
        return 'Configuration Timeout';
      default:
        return 'Unknown Status ($operModeHex)';
    }
  }

  /// Returns a human-readable status message
  String get statusMessage => operModeName;

  /// Returns an emoji representing the current status
  String get statusEmoji {
    if (isSuccess) return '✅';
    if (isError) return '❌';
    if (isProgress) return '⏳';
    return 'ℹ️';
  }

  /// Returns a color code for UI representation
  /// 0 = grey (unknown), 1 = blue (progress), 2 = green (success), 3 = red (error)
  int get statusColor {
    if (isProgress) return 1;
    if (isSuccess) return 2;
    if (isError) return 3;
    return 0;
  }

  @override
  String toString() {
    return 'RfSignResult{operMode: $operModeHex ($operModeName), '
        'moduleMac: $moduleMac, originalModuleMac: $originalModuleMac, '
        'timestamp: $timestamp}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RfSignResult &&
          runtimeType == other.runtimeType &&
          operMode == other.operMode &&
          moduleMac == other.moduleMac &&
          originalModuleMac == other.originalModuleMac;

  @override
  int get hashCode =>
      operMode.hashCode ^ moduleMac.hashCode ^ originalModuleMac.hashCode;
}
