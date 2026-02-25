import 'dart:async';

import 'src/models/hxj_bluetooth_device_model.dart';
import 'wise_apartment_platform_interface.dart';
export 'src/wise_apartment_exception.dart';
export 'src/models/export_hxj_models.dart';

class WiseApartment {
  /// Returns the platform version (e.g. "Android 12", "iOS 15.0").
  Future<String?> getPlatformVersion() {
    return WiseApartmentPlatform.instance.getPlatformVersion();
  }

  /// Retrieves device information including model, manufacturer, etc.
  Future<Map<String, dynamic>> getDeviceInfo() {
    return WiseApartmentPlatform.instance.getDeviceInfo();
  }

  /// Retrieves Android Build Config parameters. Returns null on iOS.
  Future<Map<String, dynamic>?> getAndroidBuildConfig() {
    return WiseApartmentPlatform.instance.getAndroidBuildConfig();
  }

  /// Initializes the BLE Client and sets up necessary callbacks.
  /// Must be called before scanning or connecting.
  Future<bool> initBleClient() {
    return WiseApartmentPlatform.instance.initBleClient();
  }

  /// Starts scanning for BLE devices.
  /// [timeoutMs] defaults to 10000 (10 seconds).
  Future<List<Map<String, dynamic>>> startScan({int timeoutMs = 10000}) {
    return WiseApartmentPlatform.instance.startScan(timeoutMs: timeoutMs);
  }

  /// Stops an ongoing scan.
  Future<bool> stopScan() {
    return WiseApartmentPlatform.instance.stopScan();
  }

  /// Sends the Open Lock command to a device.
  /// [auth] must contain: authCode, dnaKey, keyGroupId, bleProtocolVer, mac.
  Future<Map<String, dynamic>> openLock(Map<String, dynamic> auth) {
    return WiseApartmentPlatform.instance.openLock(auth);
  }

  /// Disconnects from the specified device (if supported/active).
  Future<bool> disconnect({required String mac}) {
    return WiseApartmentPlatform.instance.disconnect(mac: mac);
  }

  /// Clears sdk state (e.g. cached prefs).
  Future<bool> clearSdkState() {
    return WiseApartmentPlatform.instance.clearSdkState();
  }

  Future<bool> closeLock(Map<String, dynamic> auth) {
    return WiseApartmentPlatform.instance.closeLock(auth);
  }

  /// Connects to a BLE device using the provided auth/DNA map.
  /// Returns true on success. See platform-specific implementation for details.
  Future<bool> connectBle(Map<String, dynamic> auth) {
    return WiseApartmentPlatform.instance.connectBle(auth);
  }

  /// Disconnects an active BLE connection that was established via `connectBle`.
  Future<bool> disconnectBle() {
    return WiseApartmentPlatform.instance.disconnectBle();
  }

  Future<Map<String, dynamic>> getNBIoTInfo(Map<String, dynamic> auth) {
    return WiseApartmentPlatform.instance.getNBIoTInfo(auth);
  }

  Future<Map<String, dynamic>> getCat1Info(Map<String, dynamic> auth) {
    return WiseApartmentPlatform.instance.getCat1Info(auth);
  }

  Future<bool> setKeyExpirationAlarmTime(Map<String, dynamic> auth, int time) {
    return WiseApartmentPlatform.instance.setKeyExpirationAlarmTime(auth, time);
  }

  Future<List<Map<String, dynamic>>> syncLockRecords(
    Map<String, dynamic> auth,
    int logVersion,
  ) {
    return WiseApartmentPlatform.instance.syncLockRecords(auth, logVersion);
  }

  Future<Map<String, dynamic>> syncLockRecordsPage(
    Map<String, dynamic> auth,
    int startNum,
    int readCnt,
  ) {
    return WiseApartmentPlatform.instance.syncLockRecordsPage(
      auth,
      startNum,
      readCnt,
    );
  }

  Future<bool> deleteLock(Map<String, dynamic> auth) {
    return WiseApartmentPlatform.instance.deleteLock(auth);
  }

  Future<Map<String, dynamic>> getDna(Map<String, dynamic> auth) {
    return WiseApartmentPlatform.instance.getDna(auth);
  }

  Future<Map<String, dynamic>> addDevice(HxjBluetoothDeviceModel device) {
    return WiseApartmentPlatform.instance.addDevice(device);
  }

  /// Register WiFi configuration on the lock's RF module.
  /// `wifiConfig` is a Map containing the payload (SSID, Password, tokenId, etc).
  /// `dna` is a Map with DNA fields required for auth (mac, authCode, dnaKey, protocolVer, ...).
  Future<Map<String, dynamic>> registerWifi(
    String wifiConfig,
    Map<String, dynamic> dna,
  ) {
    return WiseApartmentPlatform.instance.registerWifi(wifiConfig, dna);
  }

  /// Add a key to the lock. `auth` should contain auth/DNA fields; `params`
  /// contains action-specific parameters required by the native SDK.
  Future<Map<String, dynamic>> addLockKey(
    Map<String, dynamic> auth,
    dynamic params,
  ) {
    return WiseApartmentPlatform.instance.addLockKey(auth, params);
  }

  /// Start a streaming add-key operation. Must call `startAddLockKeyStream` on the
  /// native side while listening to `addLockKeyStream` in Dart to receive
  /// intermediate progress and final result events.
  Future<Map<String, dynamic>> startAddLockKeyStream(
    Map<String, dynamic> auth,
    dynamic params,
  ) {
    return WiseApartmentPlatform.instance.startAddLockKeyStream(auth, params);
  }

  /// Delete a key from the lock. `auth` should contain auth/DNA fields; `params`
  /// contains action-specific parameters required by the native SDK.
  /// Use DeleteLockKeyActionModel to build the params with proper validation.
  Future<Map<String, dynamic>> deleteLockKey(
    Map<String, dynamic> auth,
    dynamic params,
  ) {
    return WiseApartmentPlatform.instance.deleteLockKey(auth, params);
  }

  /// Change/modify a key password on the lock.
  /// Performs Dart-side validation before calling native platform code.
  /// `auth` is the DNA/auth map required by native SDKs.
  /// `params` can be a Map with keys: `status` (int, default 0),
  /// `lockKeyId` (int), `oldPassword` (String), `newPassword` (String).
  Future<Map<String, dynamic>> changeLockKeyPwd(
    Map<String, dynamic> auth,
    dynamic params,
  ) {
    final args = Map<String, dynamic>.from(auth);

    Map<String, dynamic> actionMap;
    if (params is Map<String, dynamic>) {
      actionMap = Map<String, dynamic>.from(params);
    } else {
      try {
        // attempt to call toMap if provided by a model
        actionMap = Map<String, dynamic>.from((params as dynamic).toMap());
      } catch (_) {
        throw ArgumentError('params must be a Map or ChangeKeyPwdActionModel');
      }
    }

    // Basic validation
    final lpId = actionMap['lockKeyId'];
    final oldPwd = actionMap['oldPassword']?.toString() ?? '';
    final newPwd = actionMap['newPassword']?.toString() ?? '';

    if (lpId == null ||
        (lpId is! int && int.tryParse(lpId.toString()) == null)) {
      throw ArgumentError('lockKeyId is required and must be an int');
    }

    if (oldPwd.isEmpty) throw ArgumentError('oldPassword is required');

    if (newPwd.length < 6 || newPwd.length > 12) {
      throw ArgumentError('newPassword must be 6-12 digits');
    }

    if (oldPwd == newPwd)
      throw ArgumentError('newPassword must differ from oldPassword');

    args['action'] = actionMap;
    return WiseApartmentPlatform.instance.changeLockKeyPwd(args, actionMap);
  }

  /// Modify the validity period of a lock key.
  /// This command is only supported when bleProtoVer >= 0x0d (13).
  /// Performs Dart-side validation before calling native platform code.
  /// `auth` is the DNA/auth map required by native SDKs.
  /// `params` can be a Map or a `ModifyKeyActionModel`.
  Future<Map<String, dynamic>> modifyLockKey(
    Map<String, dynamic> auth,
    dynamic params,
  ) {
    final args = Map<String, dynamic>.from(auth);

    Map<String, dynamic> actionMap;
    if (params is Map<String, dynamic>) {
      actionMap = Map<String, dynamic>.from(params);
    } else {
      try {
        // attempt to call toMap if provided by a model
        actionMap = Map<String, dynamic>.from((params as dynamic).toMap());
      } catch (_) {
        throw ArgumentError('params must be a Map or ModifyKeyActionModel');
      }
    }

    // Basic validation
    final authorMode = actionMap['authorMode'];
    if (authorMode != null && authorMode != 1 && authorMode != 2) {
      throw ArgumentError(
        'authorMode must be 1 (validity period) or 2 (time period)',
      );
    }

    final changeMode = actionMap['changeMode'];
    if (changeMode != null && changeMode != 1 && changeMode != 2) {
      throw ArgumentError('changeMode must be 1 (by key ID) or 2 (by user ID)');
    }

    final changeID = actionMap['changeID'];
    if (changeID == null ||
        (changeID is! int && int.tryParse(changeID.toString()) == null)) {
      throw ArgumentError('changeID is required and must be an int');
    }

    // If using time period authorization (authorMode=2), validate day times
    if (authorMode == 2) {
      final dayStartTimes = actionMap['dayStartTimes'] ?? 0;
      final dayEndTimes = actionMap['dayEndTimes'] ?? 1439;

      if (dayStartTimes is int && dayEndTimes is int) {
        if (dayStartTimes < 0 || dayStartTimes > 1439) {
          throw ArgumentError(
            'dayStartTimes must be 0-1439 (00:00-23:59 in minutes)',
          );
        }
        if (dayEndTimes < 0 || dayEndTimes > 1439) {
          throw ArgumentError(
            'dayEndTimes must be 0-1439 (00:00-23:59 in minutes)',
          );
        }
        if (dayStartTimes >= dayEndTimes) {
          throw ArgumentError('dayStartTimes must be less than dayEndTimes');
        }
      }
    }

    args['action'] = actionMap;
    return WiseApartmentPlatform.instance.modifyLockKey(args, actionMap);
  }

  /// Synchronize keys on the lock. Returns a Map describing the sync result.
  Future<Map<String, dynamic>> syncLockKey(Map<String, dynamic> auth) {
    return WiseApartmentPlatform.instance.syncLockKey(auth);
  }

  /// Stream of syncLockKey events containing incremental updates.
  /// Each chunk event contains a single key (LockKeyResult represents one key).
  ///
  /// Event types:
  /// - 'syncLockKeyChunk': { type, item (single key Map), keyNum, totalSoFar }
  /// - 'syncLockKeyDone': { type, items (all keys List), total }
  /// - 'syncLockKeyError': { type, message, code }
  Stream<Map<String, dynamic>> get syncLockKeyStream {
    return WiseApartmentPlatform.instance.syncLockKeyStream;
  }

  /// Stream of add-key events emitted by native while performing an
  /// interactive key addition (fingerprint/card/password flows).
  Stream<Map<String, dynamic>> get addLockKeyStream {
    return WiseApartmentPlatform.instance.addLockKeyStream;
  }

  /// Stream of system parameter events coming from native.
  Stream<Map<String, dynamic>> get getSysParamStream {
    return WiseApartmentPlatform.instance.getSysParamStream;
  }

  /// Stream of WiFi registration status events from the device.
  /// Emits events as the device progresses through WiFi configuration.
  ///
  /// Event format:
  /// - type: 'wifiRegistration'
  /// - status: int (0x02, 0x04, 0x05, 0x06, 0x07, etc.)
  /// - statusMessage: String (human-readable status)
  /// - moduleMac: String (RF module MAC address)
  /// - lockMac: String (lock MAC address)
  ///
  /// Status codes:
  /// - 0x02: Network distribution binding in progress
  /// - 0x04: WiFi module connected to router
  /// - 0x05: WiFi module connected to cloud (success)
  /// - 0x06: Incorrect password
  /// - 0x07: WiFi configuration timeout
  Stream<Map<String, dynamic>> get wifiRegistrationStream {
    return WiseApartmentPlatform.instance.wifiRegistrationStream;
  }

  /// Subscribe to a WiFi registration stream and start native registration
  /// immediately with the provided `wifiJson` and `dna` map. The native
  /// side will begin the registration when the Dart listener attaches.
  Stream<Map<String, dynamic>> wifiRegistrationStreamWithArgs(
    String wifiJson,
    Map<String, dynamic> dna,
  ) {
    return WiseApartmentPlatform.instance.wifiRegistrationStreamWithArgs(
      wifiJson,
      dna,
    );
  }

  /// Stream of RF sign registration results from the device.
  /// Emits events as the device progresses through RF module registration.
  ///
  /// Event format:
  /// - type: 'rfSignRegistration'
  /// - operMode: int (0x02, 0x04, 0x05, 0x06, 0x07)
  /// - moduleMac: String (wireless module MAC address)
  /// - originalModuleMac: String (original module MAC address)
  ///
  /// Operation mode codes:
  /// - 0x02: NB-IoT (WIFI module) is in the process of network distribution binding operation
  /// - 0x04: WiFi module successfully connected to the router (may not return)
  /// - 0x05: WiFi module successfully connected to the cloud (network configuration successful)
  /// - 0x06: Incorrect password (may not return)
  /// - 0x07: WIFI pairing timeout (may not return)
  Stream<Map<String, dynamic>> get regwithRfSignStream {
    return WiseApartmentPlatform.instance.regwithRfSignStream;
  }

  /// Start native sysParam stream for the provided auth/DNA map.
  Future<bool> startGetSysParamStream(Map<String, dynamic> auth) {
    return WiseApartmentPlatform.instance.startGetSysParamStream(auth);
  }

  /// Stream-based synchronization of lock records from the device.
  /// Emits incremental results as records are fetched from the lock.
  /// Each chunk event contains a batch of 10 records.
  ///
  /// Event types:
  /// - 'syncLockRecordsChunk': { type, items (record batch List), totalSoFar, isMore }
  /// - 'syncLockRecordsDone': { type, items (all records List), total }
  /// - 'syncLockRecordsError': { type, message, code }
  Stream<Map<String, dynamic>> get syncLockRecordsStream {
    return WiseApartmentPlatform.instance.syncLockRecordsStream;
  }

  /// Synchronize the lock's internal clock/time. Returns true on success.
  Future<bool> syncLockTime(Map<String, dynamic> auth) {
    return WiseApartmentPlatform.instance.syncLockTime(auth);
  }

  /// Retrieve system parameters from the lock.
  /// Returns a Map with response metadata and `body` containing SysParam fields.
  Future<Map<String, dynamic>> getSysParam(Map<String, dynamic> auth) {
    return WiseApartmentPlatform.instance.getSysParam(auth);
  }

  /// Exit/abort a long-running lock operation (sync, add-key, etc.).
  /// Provide `auth` map containing `mac` (lock MAC) and optional auth fields.
  Future<Map<String, dynamic>> exitCmd(Map<String, dynamic> auth) {
    return WiseApartmentPlatform.instance.exitCmd(auth);
  }

  /// Convenience overload: call exitCmd with `lockMac` only.
  Future<Map<String, dynamic>> exitCmdWithLockMac(String lockMac) {
    return WiseApartmentPlatform.instance.exitCmd({'mac': lockMac});
  }

  /// Enable or disable an individual key by its key ID (Operation Mode 1).
  /// This is the most specific way to enable/disable a single key.
  ///
  /// `auth` is the DNA/auth map required by native SDKs.
  /// `lockKeyId` is the specific key ID to enable/disable.
  /// `keyType` is the type of key (01=Fingerprint, 02=Password, 04=Card, etc).
  /// `userId` is the user/key group ID associated with the key (optional, defaults to 0).
  /// `enabled` true to enable, false to disable.
  Future<Map<String, dynamic>> enableKeyById({
    required Map<String, dynamic> auth,
    required int lockKeyId,
    required int keyType,
    int userId = 0,
    required bool enabled,
  }) {
    if (lockKeyId < 0) {
      throw ArgumentError('lockKeyId must be non-negative');
    }
    return WiseApartmentPlatform.instance.enableKeyById(
      auth: auth,
      lockKeyId: lockKeyId,
      keyType: keyType,
      userId: userId,
      enabled: enabled,
    );
  }

  /// Enable or disable keys by their type (Operation Mode 2).
  /// This affects all keys of the specified type(s).
  ///
  /// `auth` is the DNA/auth map required by native SDKs.
  /// `keyTypeBitmask` selects which key types to affect:
  ///   - 01 (0x01): Fingerprint
  ///   - 02 (0x02): Password
  ///   - 04 (0x04): Card
  ///   - 08 (0x08): Remote control
  ///   - 64 (0x40): App temporary password
  ///   - 128 (0x80): App key
  ///   - 255 (0xFF): All types
  /// `enabled` true to enable, false to disable.
  Future<Map<String, dynamic>> enableKeyByType({
    required Map<String, dynamic> auth,
    required int keyTypeBitmask,
    required bool enabled,
  }) {
    if (keyTypeBitmask <= 0) {
      throw ArgumentError('keyTypeBitmask must be positive');
    }
    return WiseApartmentPlatform.instance.enableKeyByType(
      auth: auth,
      keyTypeBitmask: keyTypeBitmask,
      enabled: enabled,
    );
  }

  /// Enable or disable all keys for a specific user/key group (Operation Mode 3).
  /// This affects all keys belonging to a user.
  ///
  /// `auth` is the DNA/auth map required by native SDKs.
  /// `userId` is the user ID / key group ID.
  /// `enabled` true to enable, false to disable.
  Future<Map<String, dynamic>> enableKeyByUserId({
    required Map<String, dynamic> auth,
    required int userId,
    required bool enabled,
  }) {
    if (userId < 0) {
      throw ArgumentError('userId must be non-negative');
    }
    return WiseApartmentPlatform.instance.enableKeyByUserId(
      auth: auth,
      userId: userId,
      enabled: enabled,
    );
  }
}
