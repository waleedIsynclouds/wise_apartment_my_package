import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'wise_apartment_platform_interface.dart';
import 'src/wise_apartment_exception.dart';

class MethodChannelWiseApartment extends WiseApartmentPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('wise_apartment/methods');

  @override
  Future<String?> getPlatformVersion() async {
    return await methodChannel.invokeMethod<String>('getPlatformVersion');
  }

  @override
  Future<Map<String, dynamic>> getDeviceInfo() async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>(
      'getDeviceInfo',
    );
    return result ?? {};
  }

  @override
  Future<Map<String, dynamic>?> getAndroidBuildConfig() async {
    return await methodChannel.invokeMapMethod<String, dynamic>(
      'getAndroidBuildConfig',
    );
  }

  @override
  Future<bool> initBleClient() async {
    return _invokeBool('initBleClient');
  }

  @override
  Future<List<Map<String, dynamic>>> startScan({int timeoutMs = 10000}) async {
    try {
      final List<dynamic>? result = await methodChannel.invokeMethod(
        'startScan',
        {'timeoutMs': timeoutMs},
      );
      if (result == null) return [];
      return result
          .cast<Map<dynamic, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } on PlatformException catch (e) {
      throw WiseApartmentException(e.code, e.message);
    }
  }

  @override
  Future<bool> stopScan() async {
    return _invokeBool('stopScan');
  }

  @override
  Future<bool> openLock(Map<String, dynamic> auth) async {
    return _invokeBool('openLock', auth);
  }

  @override
  Future<bool> disconnect({required String mac}) async {
    return _invokeBool('disconnect', {'mac': mac});
  }

  @override
  Future<bool> clearSdkState() async {
    return _invokeBool('clearSdkState');
  }

  @override
  Future<bool> closeLock(Map<String, dynamic> auth) async {
    return _invokeBool('closeLock', auth);
  }

  @override
  Future<Map<String, dynamic>> getNBIoTInfo(Map<String, dynamic> auth) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>(
      'getNBIoTInfo',
      auth,
    );
    return result ?? {};
  }

  @override
  Future<Map<String, dynamic>> getCat1Info(Map<String, dynamic> auth) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>(
      'getCat1Info',
      auth,
    );
    return result ?? {};
  }

  @override
  Future<bool> setKeyExpirationAlarmTime(
    Map<String, dynamic> auth,
    int time,
  ) async {
    final args = Map<String, dynamic>.from(auth);
    args['time'] = time;
    return _invokeBool('setKeyExpirationAlarmTime', args);
  }

  @override
  Future<List<Map<String, dynamic>>> syncLockRecords(
    Map<String, dynamic> auth,
    int logVersion,
  ) async {
    final args = Map<String, dynamic>.from(auth);
    args['logVersion'] = logVersion;
    try {
      final List<dynamic>? result = await methodChannel.invokeMethod(
        'syncLockRecords',
        args,
      );
      if (result == null) return [];
      return result
          .cast<Map<dynamic, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } on PlatformException catch (e) {
      throw WiseApartmentException(e.code, e.message);
    }
  }

  @override
  Future<bool> deleteLock(Map<String, dynamic> auth) async {
    return _invokeBool('deleteLock', auth);
  }

  @override
  Future<Map<String, dynamic>> getDna(Map<String, dynamic> auth) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>(
      'getDna',
      auth,
    );
    return result ?? {};
  }

  @override
  Future<Map<String, dynamic>> addDevice(String mac, int chipType) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>(
      'addDevice',
      {'mac': mac, 'chipType': chipType},
    );
    return result ?? {};
  }

  Future<bool> _invokeBool(String method, [dynamic arguments]) async {
    try {
      final bool? result = await methodChannel.invokeMethod<bool>(
        method,
        arguments,
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw WiseApartmentException(e.code, e.message);
    }
  }
}
