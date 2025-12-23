import 'package:flutter_test/flutter_test.dart';
import 'package:wise_apartment/wise_apartment.dart';
import 'package:wise_apartment/wise_apartment_platform_interface.dart';
import 'package:wise_apartment/wise_apartment_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWiseApartmentPlatform
    with MockPlatformInterfaceMixin
    implements WiseApartmentPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Map<String, dynamic>> getDeviceInfo() => Future.value({});

  @override
  Future<Map<String, dynamic>?> getAndroidBuildConfig() => Future.value(null);

  @override
  Future<bool> initBleClient() => Future.value(true);

  @override
  Future<List<Map<String, dynamic>>> startScan({int timeoutMs = 10000}) =>
      Future.value([]);

  @override
  Future<bool> stopScan() => Future.value(true);

  @override
  Future<bool> openLock(Map<String, dynamic> auth) => Future.value(true);

  @override
  Future<bool> disconnect({required String mac}) => Future.value(true);

  @override
  Future<bool> clearSdkState() => Future.value(true);

  @override
  Future<bool> closeLock(Map<String, dynamic> auth) => Future.value(true);

  @override
  Future<Map<String, dynamic>> getNBIoTInfo(Map<String, dynamic> auth) =>
      Future.value({});

  @override
  Future<Map<String, dynamic>> getCat1Info(Map<String, dynamic> auth) =>
      Future.value({});

  @override
  Future<bool> setKeyExpirationAlarmTime(Map<String, dynamic> auth, int time) =>
      Future.value(true);

  @override
  Future<List<Map<String, dynamic>>> syncLockRecords(
    Map<String, dynamic> auth,
    int logVersion,
  ) => Future.value([]);

  @override
  Future<bool> deleteLock(Map<String, dynamic> auth) => Future.value(true);

  @override
  Future<Map<String, dynamic>> getDna(Map<String, dynamic> auth) =>
      Future.value({});

  @override
  Future<Map<String, dynamic>> addDevice(String mac, int chipType) {
    return Future.value({});
  }
}

void main() {
  final WiseApartmentPlatform initialPlatform = WiseApartmentPlatform.instance;

  test('$MethodChannelWiseApartment is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWiseApartment>());
  });

  test('getPlatformVersion', () async {
    WiseApartment wiseApartmentPlugin = WiseApartment();
    MockWiseApartmentPlatform fakePlatform = MockWiseApartmentPlatform();
    WiseApartmentPlatform.instance = fakePlatform;

    expect(await wiseApartmentPlugin.getPlatformVersion(), '42');
  });
}
