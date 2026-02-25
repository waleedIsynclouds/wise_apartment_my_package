import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wise_apartment/src/models/hxj_bluetooth_device_model.dart';
// (removed unused import)
import 'wise_apartment_method_channel.dart';

abstract class WiseApartmentPlatform extends PlatformInterface {
  WiseApartmentPlatform() : super(token: _token);

  static final Object _token = Object();
  static WiseApartmentPlatform _instance = MethodChannelWiseApartment();

  static WiseApartmentPlatform get instance => _instance;

  static set instance(WiseApartmentPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion();
  Future<Map<String, dynamic>> getDeviceInfo();
  Future<Map<String, dynamic>?> getAndroidBuildConfig();
  Future<bool> initBleClient();
  Future<List<Map<String, dynamic>>> startScan({int timeoutMs = 10000});
  Future<bool> stopScan();
  Future<Map<String, dynamic>> openLock(Map<String, dynamic> auth);
  Future<bool> disconnect({required String mac});
  Future<bool> clearSdkState();

  // New Methods from HomeFragment
  Future<bool> closeLock(Map<String, dynamic> auth);
  Future<Map<String, dynamic>> getNBIoTInfo(Map<String, dynamic> auth);
  Future<Map<String, dynamic>> getCat1Info(Map<String, dynamic> auth);
  Future<bool> setKeyExpirationAlarmTime(Map<String, dynamic> auth, int time);
  Future<List<Map<String, dynamic>>> syncLockRecords(
    Map<String, dynamic> auth,
    int logVersion,
  );
  Future<Map<String, dynamic>> syncLockRecordsPage(
    Map<String, dynamic> auth,
    int startNum,
    int readCnt,
  );

  Future<bool> deleteLock(Map<String, dynamic> auth);
  Future<Map<String, dynamic>> getDna(Map<String, dynamic> auth);

  // New Methods from AddSecondFragment
  Future<Map<String, dynamic>> addDevice(HxjBluetoothDeviceModel device);

  /// Register/configure WiFi on the lock's RF module.
  /// `wifiJson` is a JSON string containing the configuration payload.
  /// `dna` contains the DNA info fields required to build the auth action.
  Future<Map<String, dynamic>> registerWifi(
    String wifiJson,
    Map<String, dynamic> dna,
  );

  // BLE connect/disconnect helpers (native implementations may use callbacks)
  Future<bool> connectBle(Map<String, dynamic> auth);
  Future<bool> disconnectBle();

  // Add Key feature
  /// Adds a lock key using provided auth and action parameters.
  /// Returns a Map describing the result (code/ackMessage/body...).
  Future<Map<String, dynamic>> addLockKey(
    Map<String, dynamic> auth,
    dynamic params,
  );

  /// Starts a streaming add-key operation. When Flutter is listening to
  /// the `addLockKeyStream` EventChannel, native will emit intermediate
  /// progress events and the final result via the stream.
  /// Returns an acknowledgement Map when the stream is started.
  Future<Map<String, dynamic>> startAddLockKeyStream(
    Map<String, dynamic> auth,
    dynamic params,
  );

  /// Stream of add-key events (chunks, done, errors).
  /// Event types:
  /// - 'addLockKeyChunk'
  /// - 'addLockKeyDone'
  /// - 'addLockKeyError'
  Stream<Map<String, dynamic>> get addLockKeyStream;

  /// Starts a streaming fingerprint addition operation. When Flutter is listening to
  /// the `bleEventStream` EventChannel, native will emit intermediate progress events
  /// and the final result via the stream.
  ///
  /// Stream of BLE events (WiFi registration, key addition, etc.)
  Stream<Map<String, dynamic>> get bleEventStream;

  /// Change/modify a key's password on the lock.
  /// `auth` contains DNA/auth fields; `params` may be a Map or a
  /// `ChangeKeyPwdActionModel` describing the operation.
  Future<Map<String, dynamic>> changeLockKeyPwd(
    Map<String, dynamic> auth,
    dynamic params,
  );

  /// Modify the validity period of a lock key.
  /// This command is only supported when bleProtoVer >= 0x0d (13).
  /// `auth` contains DNA/auth fields; `params` may be a Map or a
  /// `ModifyKeyActionModel` describing the operation.
  Future<Map<String, dynamic>> modifyLockKey(
    Map<String, dynamic> auth,
    dynamic params,
  );

  /// Deletes a lock key using provided auth and action parameters.
  /// Returns a Map describing the result (code/ackMessage/body...).
  Future<Map<String, dynamic>> deleteLockKey(
    Map<String, dynamic> auth,
    dynamic params,
  );

  /// Synchronize keys on the lock. Accepts auth/DNA map and returns a Map
  /// describing the sync result or a list of keys inside the returned Map.
  Future<Map<String, dynamic>> syncLockKey(Map<String, dynamic> auth);

  /// Stream of syncLockKey events (chunks, done, errors)
  Stream<Map<String, dynamic>> get syncLockKeyStream;

  /// Stream of syncLockRecords events (chunks, done, errors)
  Stream<Map<String, dynamic>> get syncLockRecordsStream;

  /// Stream that emits system parameter responses from native as they arrive.
  Stream<Map<String, dynamic>> get getSysParamStream;

  /// Stream that emits WiFi registration events from the device.
  /// Events contain status codes and module/lock MAC addresses.
  Stream<Map<String, dynamic>> get wifiRegistrationStream;

  Future<bool> syncLockTime(Map<String, dynamic> auth);

  /// Start the native getSysParam stream. Emits events on `getSysParamStream`.
  Future<bool> startGetSysParamStream(Map<String, dynamic> auth);

  /// Retrieve system parameters from the lock (SysParamResult).
  /// Returns a Map containing the response metadata and a `body` map of fields.
  Future<Map<String, dynamic>> getSysParam(Map<String, dynamic> auth);

  /// Enable or disable an individual key by its key ID (Operation Mode 1).
  Future<Map<String, dynamic>> enableKeyById({
    required Map<String, dynamic> auth,
    required int lockKeyId,
    required int keyType,
    required int userId,
    required bool enabled,
  });

  /// Enable or disable keys by their type (Operation Mode 2).
  Future<Map<String, dynamic>> enableKeyByType({
    required Map<String, dynamic> auth,
    required int keyTypeBitmask,
    required bool enabled,
  });

  /// Enable or disable all keys for a specific user/key group (Operation Mode 3).
  Future<Map<String, dynamic>> enableKeyByUserId({
    required Map<String, dynamic> auth,
    required int userId,
    required bool enabled,
  });

  /// Exit/abort a long-running lock operation (sync, add-key, etc.)
  /// `auth` should contain at least the `mac` of the lock to abort.
  /// Returns a Map with `code`, `ackMessage`, and optional `reason`.
  Future<Map<String, dynamic>> exitCmd(Map<String, dynamic> auth);
}
