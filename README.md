# Wise Apartment - BLE Smart Lock Flutter Plugin

A Flutter plugin for communicating with HXJ Bluetooth smart locks. This plugin wraps the native **Android_HXJBLESDK** and provides a unified Dart API for both Android and iOS platforms.

[![Platform](https://img.shields.io/badge/platform-android%20%7C%20ios-blue)](https://flutter.dev)
[![Flutter](https://img.shields.io/badge/flutter-%3E%3D3.3.0-blue)](https://flutter.dev)

---

## Features

- 🔓 **Lock Control** - Open, close, and delete smart locks via BLE
- 📡 **BLE Scanning** - Discover nearby HXJ Bluetooth devices
- 🔐 **Secure Authentication** - Server-based auth with `authCode` and `dnaKey`
- 📋 **Lock Records** - Sync access logs from the device
- ⚙️ **Device Configuration** - Set key expiration alarms, get device DNA
- 📱 **Cross-Platform** - Works on Android and iOS

---

## Table of Contents

- [Installation](#installation)
- [Platform Setup](#platform-setup)
  - [Android Setup](#android-setup)
  - [iOS Setup](#ios-setup)
- [Usage](#usage)
  - [Initialize](#initialize)
  - [Scan for Devices](#scan-for-devices)
  - [Open Lock](#open-lock)
  - [Close Lock](#close-lock)
  - [Delete Lock](#delete-lock)
  - [Sync Lock Records](#sync-lock-records)
- [API Reference](#api-reference)
- [Error Handling](#error-handling)
- [Example App](#example-app)
- [Troubleshooting](#troubleshooting)

---

## Installation

Add `wise_apartment` to your `pubspec.yaml`:

```yaml
dependencies:
  wise_apartment:
    path: ../wise_apartment  # Local path reference
```

Or if published to a repository:

```yaml
dependencies:
  wise_apartment: ^1.0.0
```

Then run:

```bash
flutter pub get
```

---

## Lock Key Fields (Add Key Parameters)

The following table documents fields used when adding keys or describing key metadata returned by the lock.

| Type | Field | Description |
|------|-------|-------------|
| `private int` | `authorMode` | Adding method: 0 = Make the door lock enter the mode of reading fingerprint/card/remote control; 1 = Add password or card number |
| `private int` | `addedKeyType` | Key type. When `authorMode==0`: `1` = fingerprint, `4` = card, `8` = remote control. When `authorMode==1`: `2` = password, `4` = card number |
| `private int` | `password` | When `authorMode==1`, the password or card number to be added (6-12 digits) |
| `private int` | `vaildMode` | Validity period mode: `0` = Validity period authorization; `1` = Periodic repetition authorization |
| `private long` | `vaildStartTime` | Authorization start timestamp (seconds). Fill in `0` to indicate unlimited start time |
| `private long` | `vaildEndTime` | Authorization end timestamp (seconds). Fill in `0xFFFFFFFF` to indicate unlimited end time |
| `private int` | `dayStartTimes` | Number of minutes from 0:00 when the cycle is repeated — the start time of the valid period of the day |
| `private int` | `dayEndTimes` | Number of minutes from 0:00 when the cycle is repeated — the end time of the valid period of the day |
| `private int` | `week` | Required when `vaildMode==1`. Bits 0..6 correspond to days of week (bit set = key valid on that day) |
| `private int` | `vaildNumber` | Number of authorizations: `0x01` = 1 time; `0xFF` = unlimited times; `0x00` = disabled |
| `private int` | `addedKeyGroupId` | The group id corresponding to the key (the user/group the key is assigned to) |
| `private int` | `addedKeyID` | Key id on the lock |

### `AddLockKeyActionModel` (usage & validation)

The `AddLockKeyActionModel` class encapsulates parameters used when calling `addLockKey`. The model performs no network I/O and can be validated locally before sending to the device.

Rules and validation enforced by `AddLockKeyActionModel.validate()` / `validateOrThrow()`:

- `localRemoteMode`: Delivery mode; default is `1`.
- `authorMode`: 0 = enter fingerprint/card/remote mode; 1 = add password/card number.
- `addedKeyType`: When `authMode==0`: `1` (fingerprint), `4` (card), `8` (remote). When `authMode==1`: `2` (password), `4` (card number).
- `password`: Required when `authorMode==1`. Must be 6-12 digits.
- `vaildMode`: `0` = single validity window; `1` = periodic repetition mode.
- When `vaildMode==1`: `week` must be non-zero; `dayStartTimes` and `dayEndTimes` must be in `0..1439` and `dayEndTimes > dayStartTimes`.
- `validStartTime` must be >= 0.
- `validEndTime` must be `0xFFFFFFFF` (unlimited) or >= `validStartTime`.
- `vaildNumber` must be between `0` and `255` (`0xFF` = unlimited).

Example usage:

```dart
final action = AddLockKeyActionModel(
  password: '123456', // when required
  authorMode: 1,
  addedKeyType: AddLockKeyActionModel.addedPassword,
  keyDataType: 0,
  vaildMode: 0,
  validStartTime: 0,
  validEndTime: 0xFFFFFFFF,
  localRemoteMode: 1,
  status: 0,
);

// Validate locally (optionally pass `authMode` to check addedKeyType validity):
action.validateOrThrow(authMode: 1);

// Call plugin (the plugin expects a map under the `action` key):
final res = await wiseApartment.addLockKey(authMap, {'action': action.toMap()});
```

Add these notes to ensure callers construct and validate the model before invoking `addLockKey`.

### Native SDK parameter reference (Objective-C)

The native HXJ SDK exposes a parameter object used for adding keys. For clarity, here is the Objective-C interface and notes (source comments):

```objc
@interface HXBLEAddKeyBaseParams : NSObject
/** Required, MAC for Bluetooth lock, used to determine when sending commands to the specified device */
@property (nonatomic, copy) NSString *lockMac;
/**
REQUIRED
User ID (i.e. key group ID)
(Note: When a key is added to this key group, a user can add multiple keys, corresponding to multiple lockKeyId)
Assign keyGroupIDs to your own server to ensure that the keyGroupIDs of users in a lock do not conflict
Value range: 900~4095
 */
@property (nonatomic, assign) int keyGroupId;
/**
REQUIRED
Enable times
0: Disabled
1~254: Effective times
255: Unlimited times
 */
@property (nonatomic, assign) int vaildNumber;
/**
REQUIRED
Effective start timestamp (seconds)
Permanent authorization: validStartTime=0x0000000
 */
@property (nonatomic, assign) long validStartTime;
/**
REQUIRED
Effective end timestamp (seconds)
Permanent authorization: validEndTime=0xFFFFFFFF
 */
@property (nonatomic, assign) long validEndTime;
/**
REQUIRED
Validity period authorization method
1: Validity period authorization
2: Cycle Repetition Time Period Authorization
 */
@property (nonatomic, assign) int authMode;
/**
Optional,
This value is valid when authMode==2
Weeks, for example: Monday and Tuesday are represented as kSWeek_Monday | kSWeex_days
 */
@property (nonatomic, assign) kSHWeek week;
/**
Optional,
This value is valid when authMode==2
Daily start time
Value range: 00:00~23:59
Unit: minutes
 */
@property (nonatomic, assign) int dayStartTimes;
/**
Optional,
This value is valid when authMode==2
Daily end time
Value range: 00:00~23:59
Unit: minutes
 */
@property (nonatomic, assign) int dayEndTimes;
@end
```

Notes & mapping to this Dart plugin:
- `keyGroupId` (server-assigned user/group id): recommended range 900–4095. Ensure no collisions when assigning IDs for users on the same lock.
- `vaildNumber`: 0 = disabled, 1..254 = limited-times, 255 = unlimited.
- `validStartTime` / `validEndTime`: epoch seconds; use `0` for "no start limit" and `0xFFFFFFFF` for "no end limit" (permanent).
- `authMode` in the native SDK is documented as `1` (single validity window) and `2` (cycle/repetition). In this Dart plugin the field is exposed as `vaildMode` and the accepted values are `0` (single window) and `1` (cycle). Do not use value `2` with the Dart model — only `0` or `1` are valid when calling `addLockKey` via this package.
- `week`, `dayStartTimes`, `dayEndTimes` are used for cycle mode. Use a bitmask for `week` (bit 0 = Monday, bit 6 = Sunday).
- Important: Some locks treat `(dayStartTimes==0 && dayEndTimes==0)` as "unset" rather than "all-day". To ensure the key is usable all day, prefer sending `dayStartTimes=0` and `dayEndTimes=1439` (23:59).
- Local menu access: keys whose `addedKeyID` (the lock-assigned key id) is between `1` and `10` (inclusive) are commonly used to grant access to the lock's local menu. This plugin provides `setKeyIdForLocalMenu(id)` and `hasLocalMenuAccess()` helpers on `AddLockKeyActionModel` to make this explicit; when granting local menu access from the example UI, ensure the admin chooses a `Key ID` in `1..10`.

If you maintain native integrations, map `authMode` ↔ `vaildMode` consistently: native `(1,2)` → Dart `(0,1)`.


## Platform Setup

### Android Setup

#### 1. Minimum SDK Version

Ensure your `android/app/build.gradle` has:

```groovy
android {
    defaultConfig {
        minSdkVersion 21  // Required for BLE
    }
}
```

#### 2. Add Required Permissions

Add the following to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Bluetooth permissions (Android 11 and below) -->
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    
    <!-- Location permissions (required for BLE scanning) -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- Bluetooth permissions (Android 12+) -->
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" 
        android:usesPermissionFlags="neverForLocation" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    
    <!-- BLE feature declaration -->
    <uses-feature 
        android:name="android.hardware.bluetooth_le" 
        android:required="true" />

    <application ...>
        <!-- Your app config -->
    </application>
</manifest>
```

#### 3. Add SDK AAR Files

Copy the following AAR files to `android/app/libs/`:

- `hxjblinklibrary-release.aar`
- `hblelibrary_base_a.aar`
- `hblelibrary_base_b.aar`

Then add to your `android/app/build.gradle`:

```groovy
dependencies {
    implementation fileTree(dir: 'libs', include: ['*.aar', '*.jar'])
}
```

#### Plugin AAR packaging note

> **Important:** When building the plugin as an AAR, the Android Gradle Plugin will fail if the library module declares direct local `.aar` dependencies because the produced AAR would be missing those libraries' classes and resources. To avoid this issue the plugin compiles against vendor AARs using `compileOnly` (see `wise_apartment/android/build.gradle`). Consumer apps must include the vendor AARs (for example by copying them into the app module's `libs/` folder or publishing them to a Maven repository) so the final APK/AAB contains the native SDK.

#### 4. Local Maven repository for examples

If you are building the `example` app or consuming the plugin locally, ensure Gradle can find the prebuilt vendor AARs by adding the following entries to the `repositories` block used for dependency resolution (for example in your module `build.gradle.kts` or under `dependencyResolutionManagement { repositories { ... } }` in `settings.gradle.kts`):

```kotlin
repositories {
  mavenLocal()
  maven { url = uri("../../android/maven-repo") }
  google()
  mavenCentral()
}
```

Reason: `mavenLocal()` allows Gradle to resolve artifacts from your local Maven cache (useful if vendor AARs were installed locally). The `maven { url = uri("../../android/maven-repo") }` entry points Gradle to the `android/maven-repo` folder bundled in this project, which contains the HXJ vendor AAR artifacts required by the plugin. Adding these ensures the build can resolve the native SDK dependencies without publishing them to a remote Maven repository.

#### 4. Request Permissions at Runtime

Use a package like [`permission_handler`](https://pub.dev/packages/permission_handler) to request permissions:

```dart
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestBlePermissions() async {
  if (Platform.isAndroid) {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
    
    return statuses.values.every((s) => s.isGranted);
  }
  return true;
}
```

---

### iOS Setup

#### 1. Info.plist Configuration

Add the following to `ios/Runner/Info.plist`:

```xml
<dict>
    <!-- Bluetooth usage descriptions (required for iOS 13+) -->
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>This app needs Bluetooth access to scan for and connect to smart lock devices for pairing and control.</string>
    
    <key>NSBluetoothPeripheralUsageDescription</key>
    <string>This app needs Bluetooth access to scan for and connect to smart lock devices for pairing and control.</string>
    
    <key>NSBluetoothWhileUsingUsageDescription</key>
    <string>This app needs Bluetooth access to scan for and connect to smart lock devices for pairing and control.</string>
    
    <!-- Location permissions (required for BLE scanning on iOS) -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Location access is required for Bluetooth scanning on iOS. Your location is not tracked or stored.</string>
    
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>Location access is required for Bluetooth scanning on iOS. Your location is not tracked or stored.</string>
    
    <!-- Local network access (for WiFi configuration features) -->
    <key>NSLocalNetworkUsageDescription</key>
    <string>This app needs local network access to configure WiFi settings on smart lock devices.</string>
    
    <!-- Background BLE mode (optional, for background operations) -->
    <key>UIBackgroundModes</key>
    <array>
        <string>bluetooth-central</string>
    </array>
</dict>
```

**Required Permissions Explained:**
- **NSBluetooth*** - Required for Bluetooth Low Energy (BLE) operations
- **NSLocation*** - iOS requires location permission for BLE scanning (Apple privacy policy)
- **NSLocalNetworkUsageDescription** - Required for WiFi configuration features
- **UIBackgroundModes** - Optional, enables BLE operations in background

#### 2. Minimum iOS Version

Ensure your `ios/Podfile` has:

```ruby
platform :ios, '12.0'
```

> ⚠️ **Note:** iOS implementation is currently in progress. BLE methods return `UNAVAILABLE` error until completed.

---

## Usage

### Import the Package

```dart
import 'package:wise_apartment/wise_apartment.dart';
```

### Initialize

Create an instance and initialize the BLE client:

```dart
final wiseApartment = WiseApartment();

Future<void> initializeBle() async {
  try {
    final success = await wiseApartment.initBleClient();
    print('BLE initialized: $success');
  } catch (e) {
    print('Failed to initialize BLE: $e');
  }
}
```

### Scan for Devices

Discover nearby BLE locks:

```dart
Future<void> scanForLocks() async {
  try {
    // Scan for 5 seconds
    final devices = await wiseApartment.startScan(timeoutMs: 5000);
    
    for (final device in devices) {
      print('Found: ${device['name']} - ${device['mac']} (${device['rssi']} dBm)');
    }
  } catch (e) {
    print('Scan failed: $e');
  }
}

// Stop an ongoing scan
await wiseApartment.stopScan();
```

### Open Lock

Unlock a smart lock with authentication:

```dart
Future<void> unlockDoor() async {
  // Authentication data from your server
  final auth = {
    'mac': 'AA:BB:CC:DD:EE:FF',      // Device MAC address
    'authCode': 'your_auth_code',     // From server
    'dnaKey': 'your_dna_key',         // From server
    'keyGroupId': 1,                   // Key group ID
    'bleProtocolVer': 12,              // BLE protocol version
  };

  try {
    final success = await wiseApartment.openLock(auth);
    print('Lock opened: $success');
  } on WiseApartmentException catch (e) {
    print('Failed to open lock: ${e.code} - ${e.message}');
  }
}
```

### Close Lock

Close/lock the device:

```dart
Future<void> lockDoor() async {
  final auth = {
    'mac': 'AA:BB:CC:DD:EE:FF',
    'authCode': 'your_auth_code',
    'dnaKey': 'your_dna_key',
    'keyGroupId': 1,
    'bleProtocolVer': 12,
  };

  try {
    final success = await wiseApartment.closeLock(auth);
    print('Lock closed: $success');
  } catch (e) {
    print('Failed to close lock: $e');
  }
}
```

### Delete Lock

Remove a lock from the device:

```dart
Future<void> removeLock() async {
  final auth = {
    'mac': 'AA:BB:CC:DD:EE:FF',
    'authCode': 'your_auth_code',
    'dnaKey': 'your_dna_key',
    'keyGroupId': 1,
    'bleProtocolVer': 12,
  };

  try {
    final success = await wiseApartment.deleteLock(auth);
    print('Lock deleted: $success');
  } catch (e) {
    print('Failed to delete lock: $e');
  }
}
```

### Sync Lock Records

Retrieve access logs from the lock:

```dart
Future<void> getLockHistory() async {
  final auth = {
    'mac': 'AA:BB:CC:DD:EE:FF',
    'authCode': 'your_auth_code',
    'dnaKey': 'your_dna_key',
    'keyGroupId': 1,
    'bleProtocolVer': 12,
  };

  try {
    final records = await wiseApartment.syncLockRecords(auth, 0);
    
    for (final record in records) {
      // Each record is a flat map coming from the native
      // HXJ SDK. Common fields include:
      //   - recordTime (int, seconds timestamp)
      //   - recordType (int, LogType enum value)
      //   - logVersion (1 = first gen, 2 = second gen)
      //   - modelType (HXRecord* concrete model name)
      //   - eventFlag / power and other model-specific fields.
      print('Record: $record');
    }
  } catch (e) {
    print('Failed to sync records: $e');
  }
}
```

---

## API Reference

### Core Methods

| Method | Description | Returns |
|--------|-------------|---------|
| `initBleClient()` | Initialize the BLE client | `Future<bool>` |
| `startScan({timeoutMs})` | Scan for BLE devices | `Future<List<Map<String, dynamic>>>` |
| `stopScan()` | Stop ongoing scan | `Future<bool>` |
| `disconnect({mac})` | Disconnect from device | `Future<bool>` |
| `clearSdkState()` | Clear cached SDK state | `Future<bool>` |

### Lock Operations

| Method | Description | Returns |
|--------|-------------|---------|
| `openLock(auth)` | Unlock the device | `Future<bool>` |
| `closeLock(auth)` | Lock the device | `Future<bool>` |
| `deleteLock(auth)` | Delete/reset the lock | `Future<bool>` |
| `getDna(auth)` | Get device DNA info | `Future<Map<String, dynamic>>` |

### Device Information

| Method | Description | Returns |
|--------|-------------|---------|
| `getDeviceInfo()` | Get device info (model, OS) | `Future<Map<String, dynamic>>` |
| `getPlatformVersion()` | Get platform version string | `Future<String?>` |
| `getAndroidBuildConfig()` | Android build config (Android only) | `Future<Map<String, dynamic>?>` |
| `getNBIoTInfo(auth)` | Get NB-IoT module info | `Future<Map<String, dynamic>>` |
| `getCat1Info(auth)` | Get Cat1 module info | `Future<Map<String, dynamic>>` |

### Configuration

| Method | Description | Returns |
|--------|-------------|---------|
| `setKeyExpirationAlarmTime(auth, time)` | Set key expiration alarm | `Future<bool>` |
| `syncLockRecords(auth, logVersion)` | Sync access records | `Future<List<Map<String, dynamic>>>` |
| `addDevice(mac, chipType)` | Add new device | `Future<Map<String, dynamic>>` |

### Authentication Object

All lock operations require an `auth` map with these fields:

```dart
final auth = {
  'mac': String,            // Device MAC address (required)
  'authCode': String,       // Authentication code from server (required)
  'dnaKey': String,         // DNA key from server (required)
  'keyGroupId': int,        // Key group identifier (required)
  'bleProtocolVer': int,    // BLE protocol version (required)
};
```

---

## Error Handling

The plugin throws `WiseApartmentException` for errors:

```dart
try {
  await wiseApartment.openLock(auth);
} on WiseApartmentException catch (e) {
  switch (e.code) {
    case 'PERMISSION_DENIED':
      print('Missing Bluetooth permissions');
      break;
    case 'FAILED':
      print('Operation failed: ${e.message}');
      break;
    case 'ERROR':
      print('Error: ${e.message}');
      break;
    case 'UNAVAILABLE':
      print('Feature not available on this platform');
      break;
    default:
      print('Unknown error: ${e.code}');
  }
}
```

### Error Codes

| Code | Description |
|------|-------------|
| `PERMISSION_DENIED` | Missing Bluetooth or Location permissions |
| `FAILED` | Operation completed but was unsuccessful |
| `ERROR` | Exception occurred during operation |
| `UNAVAILABLE` | Feature not implemented on this platform |
| `TIMEOUT` | Operation timed out |

---

## Safety & Permission Changes (2026-01-11)

This release introduces two important fixes to make the plugin more robust
when interacting with the native Android BLE SDK:

- OneShotResult (Android-side)
- Runtime permission enforcement for BLE calls

### OneShotResult (what and why)

Location: `android/src/main/java/com/example/wise_apartment/utils/OneShotResult.java`

The native HXJ BLE SDK can invoke callbacks multiple times and often from
background threads. Previously those callbacks forwarded replies directly to
the Flutter `MethodChannel.Result`, which could lead to a crash with the
exception "java.lang.IllegalStateException: Reply already submitted" when an
attempt was made to reply more than once.

`OneShotResult` is a small Java utility that wraps a `MethodChannel.Result` and
enforces three rules:

1. Thread-safety: only the first reply is accepted using an `AtomicBoolean`.
2. Main-thread delivery: the delegate call is always executed on the Android
   main/UI thread (via `Handler` + `Looper.getMainLooper()`).
3. Non-destructive logging: duplicate replies are ignored and logged with
   `Log.w(TAG, ...)` so behavior is observable in logcat without crashing.

How to use: the plugin wraps the incoming `Result` at the start of
`onMethodCall` with `new OneShotResult(result, TAG)` and then uses that wrapped
result (`safeResult`) for all replies and for passing into manager helper
methods. This prevents double-reply crashes without changing the Dart API.

### Permission behavior

BLE-related methods now explicitly check Android runtime permissions and will
fail fast with a clear error when permissions are missing. This applies to
methods such as `startScan`, `connectBle`, `disconnectBle`, `openLock`,
`deleteLock` and others that interact with the BLE radio.

- On Android 12+ (API 31+) the plugin checks for `BLUETOOTH_SCAN` and
  `BLUETOOTH_CONNECT` (plus location where appropriate).
- On older Android releases the plugin checks for `ACCESS_FINE_LOCATION`.
- If permissions are missing the plugin returns a `PlatformException` with
  code `PERMISSION_DENIED` (Dart) or replies with `PERMISSION_DENIED` on the
  Java side.

Migration notes for app developers:

- Ensure the Android manifest includes the new permissions (see the
  "Android Setup" section above). For Android 12+ include
  `BLUETOOTH_SCAN` and `BLUETOOTH_CONNECT` and continue to include legacy
  Bluetooth/location permissions for older devices.
- Request runtime permissions before calling BLE methods. The example app
  demonstrates an `_ensureBlePermissions()` helper that uses
  `permission_handler` to request permissions on demand.
- If your app depends on receiving multiple asynchronous messages (for
  example per-scan-result callbacks), consider migrating those flows to an
  `EventChannel` — `OneShotResult` intentionally suppresses duplicate replies
  for the same `MethodChannel` invocation.

### Log diagnostics

`OneShotResult` logs duplicate replies using `Log.w(TAG, ...)`. When
diagnosing issues look for messages that contain "Duplicate reply ignored" in
logcat. The plugin TAG `WiseApartmentPlugin` is used so messages are easy to
find.

### Summary

These changes improve stability and make permission failures explicit. They do
not change the Dart API surface; instead they harden the native side so apps
don't crash when the vendor SDK behaves unexpectedly.


## Example App

A fully functional example app is included in the `example/` directory:

```bash
cd example
flutter run
```

The example demonstrates:
- BLE scanning with pull-to-refresh
- Device discovery and selection
- Lock/unlock operations
- Error handling

---

## Troubleshooting

### "PERMISSION_DENIED" on Android

1. Ensure all permissions are declared in `AndroidManifest.xml`
2. Request permissions at runtime before scanning
3. On Android 12+, both `BLUETOOTH_SCAN` and `BLUETOOTH_CONNECT` are required

### Scan returns empty list

1. Ensure Bluetooth is enabled on the device
2. Ensure Location services are enabled (required for BLE scanning on Android)
3. Ensure you have granted location permission
4. Make sure the lock is powered on and in range

### Connection timeout

1. Ensure the lock is not connected to another device
2. Move closer to the lock (within 2-5 meters)
3. Check that authentication credentials are correct

### iOS: "UNAVAILABLE" error

iOS implementation is currently in progress. Use Android for testing until iOS support is complete.

---

## Requirements

| Platform | Minimum Version |
|----------|-----------------|
| Android | API 21 (Lollipop) |
| iOS | 12.0 |
| Flutter | 3.3.0 |
| Dart | 3.0.0 |

---

## License

This project is proprietary software. All rights reserved.

---

## Support

For issues and feature requests, please contact the development team.

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## New API: Exit / Abort Command

This release adds a cross-platform method to abort long-running Bluetooth lock operations
(such as synchronization, adding keys, or long vendor commands).

- Dart API:

  - `Future<Map<String, dynamic>> exitCmd(Map<String, dynamic> auth)` — call with a map
    that contains at least `mac` (the lock MAC). Returns a response map with `code`,
    `ackMessage`, and `isSuccessful`.

  - `Future<Map<String, dynamic>> exitCmdWithLockMac(String lockMac)` — convenience wrapper.

- Android: invokes `abortCurrentCmd` on the underlying HXJ BLE client; returns the
  numeric code and ack message.

- iOS: invokes `exitCmdWithLockMac:completionBlock:` from the HXJ SDK and returns
  the `KSHStatusCode` and `reason` as part of the response map.

Usage example:

```dart
final res = await wiseApartment.exitCmdWithLockMac('AA:BB:CC:11:22:33');
if (res['isSuccessful'] == true) {
  print('Exit command succeeded');
} else {
  print('Exit failed: ${res['ackMessage']}');
}
```
