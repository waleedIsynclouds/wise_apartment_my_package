import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'wise_apartment.dart';
import 'wise_apartment_platform_interface.dart';
import 'src/wise_status_store.dart';

class MethodChannelWiseApartment extends WiseApartmentPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('wise_apartment/methods');

  @visibleForTesting
  final eventChannel = const EventChannel('wise_apartment/ble_events');

  Stream<Map<String, dynamic>>? _syncLockKeyStream;
  Stream<Map<String, dynamic>>? _syncLockRecordsStream;

  @override
  Stream<Map<String, dynamic>> get syncLockKeyStream {
    _syncLockKeyStream ??= eventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return Map<String, dynamic>.from(event);
      }
      return <String, dynamic>{'type': 'unknown', 'data': event};
    });
    return _syncLockKeyStream!;
  }

  @override
  Stream<Map<String, dynamic>> get syncLockRecordsStream {
    _syncLockRecordsStream ??= eventChannel.receiveBroadcastStream().map((
      event,
    ) {
      if (event is Map) {
        return Map<String, dynamic>.from(event);
      }
      return <String, dynamic>{'type': 'unknown', 'data': event};
    });
    return _syncLockRecordsStream!;
  }

  Map<String, dynamic> _iosMacArgsFromAuth(Map<String, dynamic> auth) {
    final dynamic mac = auth['mac'];
    if (mac is String && mac.isNotEmpty) {
      return <String, dynamic>{'mac': mac};
    }
    // Keep a minimal but predictable payload; native will error if missing.
    return <String, dynamic>{};
  }

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
  Future<Map<String, dynamic>> openLock(Map<String, dynamic> auth) async {
    final args = Map<String, dynamic>.from(auth);
    try {
      final Map<String, dynamic>? result = await methodChannel
          .invokeMapMethod<String, dynamic>('openLock', args);
      if (result == null) return <String, dynamic>{};
      // Persist status info if present
      try {
        WiseStatusStore.setFromMap(result);
      } catch (_) {}
      return result;
    } on PlatformException catch (e) {
      throw WiseApartmentException(e.code, e.message, e.details);
    }
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
    final args = Map<String, dynamic>.from(auth);
    return _invokeBool('closeLock', args);
  }

  @override
  Future<Map<String, dynamic>> getNBIoTInfo(Map<String, dynamic> auth) async {
    final args = Map<String, dynamic>.from(auth);
    final result = await methodChannel.invokeMapMethod<String, dynamic>(
      'getNBIoTInfo',
      args,
    );
    return result ?? {};
  }

  @override
  Future<Map<String, dynamic>> getCat1Info(Map<String, dynamic> auth) async {
    final args = Map<String, dynamic>.from(auth);
    final result = await methodChannel.invokeMapMethod<String, dynamic>(
      'getCat1Info',
      args,
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
    // If the caller no longer passes `logVersion`, infer it from
    // `menuFeature` (third bit -> gen2). Otherwise fall back to
    // the provided `logVersion` argument.
    int effectiveLogVersion = logVersion;
    if (args.containsKey('menuFeature')) {
      final dynamic mf = args['menuFeature'];
      int mfInt = 0;
      if (mf is int) {
        mfInt = mf;
      } else if (mf is String) {
        mfInt = int.tryParse(mf) ?? 0;
      }
      effectiveLogVersion = ((mfInt & 0x4) != 0) ? 2 : 1;
    }
    args['logVersion'] = effectiveLogVersion;
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
      throw WiseApartmentException(e.code, e.message, e.details);
    }
  }

  @override
  Future<Map<String, dynamic>> syncLockRecordsPage(
    Map<String, dynamic> auth,

    int startNum,
    int readCnt,
  ) async {
    final args = Map<String, dynamic>.from(auth);
    // If the caller provided `menuFeature` in the auth/DNA map, prefer
    // its third bit to determine the lock record generation: bit 3 (0x4)
    // set => generation 2, otherwise generation 1. If `menuFeature` is
    // absent, fall back to the provided `logVersion` argument.
    int effectiveLogVersion = 1;

    if (args.containsKey('menuFeature')) {
      final dynamic mf = args['menuFeature'];
      int mfInt = 0;
      if (mf is int) {
        mfInt = mf;
      } else if (mf is String) {
        mfInt = int.tryParse(mf) ?? 0;
      }
      effectiveLogVersion = isSecondGenerationRecord(mfInt) ? 2 : 1;
    }

    args['logVersion'] = effectiveLogVersion;
    args['startNum'] = startNum;
    args['readCnt'] = readCnt;
    args['readCnt'] = readCnt;
    try {
      final result = await methodChannel.invokeMapMethod<String, dynamic>(
        'syncLockRecordsPage',
        args,
      );
      return result ?? <String, dynamic>{};
    } on PlatformException catch (e) {
      throw WiseApartmentException(e.code, e.message, e.details);
    }
  }

  /// Returns true if the lock supports ONLY 2nd generation operation records.
  /// According to spec:
  /// - third bit = 1  → Gen2 only
  /// - otherwise     → Gen1 only
  bool isSecondGenerationRecord(int menuFeature) {
    return (menuFeature & 0x4) != 0; // 0x4 = third bit
  }

  @override
  Future<bool> deleteLock(Map<String, dynamic> auth) async {
    final args = Map<String, dynamic>.from(auth);
    return _invokeBool('deleteLock', args);
  }

  @override
  Future<Map<String, dynamic>> getDna(Map<String, dynamic> auth) async {
    final args = Map<String, dynamic>.from(auth);
    final result = await methodChannel.invokeMapMethod<String, dynamic>(
      'getDna',
      args,
    );
    return result ?? {};
  }

  @override
  Future<Map<String, dynamic>> addDevice(HxjBluetoothDeviceModel device) async {
    late final Map<String, dynamic>? result;
    if (Platform.isAndroid) {
      result = await methodChannel.invokeMapMethod<String, dynamic>(
        'addDevice',
        {'mac': device.getMac(), 'chipType': device.chipType},
      );
    } else {
      // iOS have different approach
      result = await methodChannel.invokeMapMethod<String, dynamic>(
        'addDevice',
        device.toMap(),
      );
    }

    return result ?? <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> registerWifi(
    String wifiJson,
    Map<String, dynamic> dna,
  ) async {
    try {
      final args = {'wifi': wifiJson, 'dna': dna};
      final Map<String, dynamic>? result = await methodChannel
          .invokeMapMethod<String, dynamic>('regWifi', args);
      if (result != null) return result;
    } catch (e) {
      // fallthrough to simulated response
    }

    // Platform not available or returned null — simulate a response in Dart
    final Map<String, dynamic> simulated = {
      'code': 0,
      'message': 'Simulated registerWifi',
      'ackMessage': 'Operation successful',
      'isSuccessful': true,
      'isError': false,
      'lockMac': dna['mac'],
      'body': wifiJson,
    };
    return simulated;
  }

  @override
  Future<bool> connectBle(Map<String, dynamic> auth) async {
    final args = Map<String, dynamic>.from(auth);
    return _invokeBool('connectBle', args);
  }

  @override
  Future<bool> disconnectBle() async {
    return _invokeBool('disconnectBle');
  }

  @override
  Future<Map<String, dynamic>> addLockKey(
    Map<String, dynamic> auth,
    dynamic params,
  ) async {
    final args = Map<String, dynamic>.from(auth);

    // Accept either an AddLockKeyActionModel or a Map. If a model is
    // provided, use it directly; otherwise build the model from the Map.
    AddLockKeyActionModel actionModel;
    if (params is AddLockKeyActionModel) {
      actionModel = params;
    } else if (params is Map) {
      final dynamic maybeAction = params['action'];
      if (maybeAction is Map) {
        actionModel = AddLockKeyActionModel.fromMap(
          Map<String, dynamic>.from(maybeAction),
        );
      } else {
        actionModel = AddLockKeyActionModel.fromMap(
          Map<String, dynamic>.from(params),
        );
      }
    } else {
      // Fallback: attempt to parse via toMap if available, otherwise empty
      try {
        actionModel = (params as AddLockKeyActionModel);
      } catch (_) {
        actionModel = AddLockKeyActionModel();
      }
    }

    // Attach the action map under the `action` key for the native side.
    args['action'] = actionModel.toMap();

    try {
      final Map<String, dynamic>? result = await methodChannel
          .invokeMapMethod<String, dynamic>('addLockKey', args);
      return result ?? <String, dynamic>{};
    } on PlatformException catch (e) {
      throw WiseApartmentException(e.code, e.message, e.details);
    }
  }

  @override
  Future<Map<String, dynamic>> syncLockKey(Map<String, dynamic> auth) async {
    try {
      final args = Map<String, dynamic>.from(auth);
      // Trigger the sync - actual results come via syncLockKeyStream
      await methodChannel.invokeMethod<void>('syncLockKey', args);
      // Return immediately - caller should listen to syncLockKeyStream
      return <String, dynamic>{
        'message': 'Sync started - listen to syncLockKeyStream for results',
      };
    } on PlatformException catch (e) {
      throw WiseApartmentException(e.code, e.message, e.details);
    }
  }

  @override
  Future<bool> syncLockTime(Map<String, dynamic> auth) async {
    final args = Map<String, dynamic>.from(auth);
    return _invokeBool('syncLockTime', args);
  }

  @override
  Future<Map<String, dynamic>> getSysParam(Map<String, dynamic> auth) async {
    try {
      final args = Map<String, dynamic>.from(auth);
      final Map<String, dynamic>? result = await methodChannel
          .invokeMapMethod<String, dynamic>('getSysParam', args);
      return result ?? <String, dynamic>{};
    } on PlatformException catch (e) {
      throw WiseApartmentException(e.code, e.message, e.details);
    }
  }

  Future<bool> _invokeBool(String method, [dynamic arguments]) async {
    try {
      final dynamic result = await methodChannel.invokeMethod<dynamic>(
        method,
        arguments,
      );

      if (result == null) return false;

      if (result is bool) {
        // No numeric code provided — clear stored status
        WiseStatusStore.clear();
        return result;
      }

      if (result is Map) {
        final Map<String, dynamic> m = Map<String, dynamic>.from(result);
        // store numeric code/ackMessage if present and get a status object
        final status = WiseStatusStore.setFromMap(m);

        // Interpret success: prefer explicit flags, otherwise success == ACK_STATUS_SUCCESS
        if (m.containsKey('isSuccessful')) {
          final dynamic v = m['isSuccessful'];
          if (v is bool) return v;
        }
        if (m.containsKey('ok')) {
          final dynamic v = m['ok'];
          if (v is bool) return v;
        }
        // Fallback: if code == 0x01 consider success
        if (Platform.isAndroid) {
          if (status != null && status.code == 0x01) {
            return true;
          }
        } else if (Platform.isIOS) {
          if (status != null && status.code == 0) {
            return true;
          }
        }
        return false;
      }

      // Unexpected type — try to coerce to bool
      return result == true;
    } on PlatformException catch (e) {
      // If platform returns details with numeric code, capture it
      try {
        final details = e.details;
        if (details is Map) {
          final _ = WiseStatusStore.setFromMap(
            Map<String, dynamic>.from(details),
          );
        }
      } catch (_) {}
      throw WiseApartmentException(e.code, e.message, e.details);
    }
  }
}
