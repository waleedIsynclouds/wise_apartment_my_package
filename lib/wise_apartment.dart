import 'dart:async';
import 'package:wise_apartment/src/models/hxj_bluetooth_device_model.dart';

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
}
