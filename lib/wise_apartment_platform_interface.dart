import 'package:plugin_platform_interface/plugin_platform_interface.dart';
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
  Future<bool> openLock(Map<String, dynamic> auth);
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
  Future<bool> deleteLock(Map<String, dynamic> auth);
  Future<Map<String, dynamic>> getDna(Map<String, dynamic> auth);

  // New Methods from AddSecondFragment
  Future<Map<String, dynamic>> addDevice(String mac, int chipType);
}
