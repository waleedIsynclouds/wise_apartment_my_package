import 'dart:async';
import 'wise_apartment_platform_interface.dart';
export 'src/wise_apartment_exception.dart';
export 'src/models/hxj_bluetooth_device_model.dart';

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
  Future<bool> openLock(Map<String, dynamic> auth) {
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

  Future<bool> deleteLock(Map<String, dynamic> auth) {
    return WiseApartmentPlatform.instance.deleteLock(auth);
  }

  Future<Map<String, dynamic>> getDna(Map<String, dynamic> auth) {
    return WiseApartmentPlatform.instance.getDna(auth);
  }

  Future<Map<String, dynamic>> addDevice(String mac, int chipType) {
    return WiseApartmentPlatform.instance.addDevice(mac, chipType);
  }
}
