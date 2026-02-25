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
  Future<Map<String, dynamic>> openLock(Map<String, dynamic> auth) =>
      Future.value({});

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
  Future<Map<String, dynamic>> addDevice(HxjBluetoothDeviceModel device) {
    return Future.value({});
  }

  @override
  Future<Map<String, dynamic>> startAddLockKeyStream(
    Map<String, dynamic> auth,
    dynamic params,
  ) {
    return Future.value({});
  }

  @override
  /*************  ✨ Windsurf Command ⭐  *************/
  /*******  a33f4824-019e-40ee-97ff-15ceb18c8035  *******/
  Future<Map<String, dynamic>> registerWifi(
    String wifiJson,
    Map<String, dynamic> dna,
  ) {
    return Future.value({});
  }

  @override
  Future<Map<String, dynamic>> syncLockRecordsPage(
    Map<String, dynamic> auth,

    int startNum,
    int readCnt,
  ) {
    return Future.value({});
  }

  @override
  Future<bool> connectBle(Map<String, dynamic> auth) {
    // TODO: implement connectBle
    throw UnimplementedError();
  }

  @override
  Future<bool> disconnectBle() {
    // TODO: implement disconnectBle
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> addLockKey(
    Map<String, dynamic> auth,
    dynamic params,
  ) {
    // TODO: implement addLockKey
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> syncLockKey(Map<String, dynamic> auth) {
    return Future.value({});
  }

  @override
  Stream<Map<String, dynamic>> get syncLockKeyStream {
    return Stream.value({});
  }

  @override
  Future<bool> syncLockTime(Map<String, dynamic> auth) {
    return Future.value(true);
  }

  @override
  Future<Map<String, dynamic>> getSysParam(Map<String, dynamic> auth) {
    return Future.value({});
  }

  @override
  Stream<Map<String, dynamic>> get getSysParamStream {
    return Stream.value({});
  }

  @override
  Future<bool> startGetSysParamStream(Map<String, dynamic> auth) {
    return Future.value(true);
  }

  @override
  Stream<Map<String, dynamic>> get syncLockRecordsStream {
    return const Stream<Map<String, dynamic>>.empty();
  }

  @override
  Stream<Map<String, dynamic>> get wifiRegistrationStream {
    return Stream.value({});
  }

  @override
  Stream<Map<String, dynamic>> get regwithRfSignStream {
    return Stream.value({});
  }

  @override
  Stream<Map<String, dynamic>> get bleEventStream {
    return Stream.value({});
  }

  @override
  Stream<Map<String, dynamic>> get addLockKeyStream {
    return Stream.value({});
  }

  @override
  Future<Map<String, dynamic>> deleteLockKey(
    Map<String, dynamic> auth,
    params,
  ) {
    // TODO: implement deleteLockKey
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> changeLockKeyPwd(
    Map<String, dynamic> auth,
    params,
  ) {
    return Future.value({});
  }

  @override
  Future<Map<String, dynamic>> modifyLockKey(
    Map<String, dynamic> auth,
    params,
  ) {
    return Future.value({});
  }

  @override
  Future<Map<String, dynamic>> enableKeyById({
    required Map<String, dynamic> auth,
    required int lockKeyId,
    required int keyType,
    required int userId,
    required bool enabled,
  }) {
    // TODO: implement enableKeyById
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> enableKeyByType({
    required Map<String, dynamic> auth,
    required int keyTypeBitmask,
    required bool enabled,
  }) {
    // TODO: implement enableKeyByType
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> enableKeyByUserId({
    required Map<String, dynamic> auth,
    required int userId,
    required bool enabled,
  }) {
    // TODO: implement enableKeyByUserId
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> exitCmd(Map<String, dynamic> auth) {
    // TODO: implement exitCmd
    throw UnimplementedError();
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
