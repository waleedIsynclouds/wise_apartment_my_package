# RF Sign Registration Stream Implementation

## Overview

This document describes the implementation of the **RF Sign Registration Stream** feature that enables real-time monitoring of RF module registration events from smart lock devices on both Android and iOS platforms.

---

## ✨ Features

- ✅ **Real-time event streaming** - Get instant updates during RF module registration
- ✅ **Cross-platform support** - Identical behavior on Android and iOS
- ✅ **Comprehensive status codes** - Support for all RF registration states (0x02-0x07)
- ✅ **Event-driven architecture** - Uses Flutter EventChannel for efficient streaming
- ✅ **Easy integration** - Simple API that follows existing stream patterns

---

## 📦 Files Modified/Created

### Flutter Layer

1. **`lib/src/models/rf_sign_result.dart`** (NEW)
   - Created model class for RF sign registration results
   - Properties: `operMode`, `moduleMac`, `originalModuleMac`, `timestamp`
   - Helper methods: `isSuccess`, `isError`, `isProgress`, `isTerminal`
   - Status constants and user-friendly status messages

2. **`lib/src/models/export_hxj_models.dart`**
   - Added export for `rf_sign_result.dart`

3. **`lib/wise_apartment_platform_interface.dart`**
   - Added abstract getter: `Stream<Map<String, dynamic>> get regwithRfSignStream;`

4. **`lib/wise_apartment_method_channel.dart`**
   - Added private field: `Stream<Map<String, dynamic>>? _regwithRfSignStream;`
   - Implemented stream getter that filters EventChannel for `rfSignRegistration` type events

5. **`lib/wise_apartment.dart`**
   - Added public getter `regwithRfSignStream` with comprehensive documentation

### Android Implementation

6. **`android/src/main/java/com/example/wise_apartment/utils/MyBleClient.java`**
   - Added `RfSignRegistrationCallback` interface with method `onRfSignRegistrationEvent(int operMode, String moduleMac, String originalModuleMac)`
   - Added private field `rfSignCallback`
   - Added setter `setRfSignRegistrationCallback(RfSignRegistrationCallback callback)`
   - Added getter `getRfSignCallback()`

7. **`android/src/main/java/com/example/wise_apartment/utils/BleLockManager.java`**
   - Modified `registerWifi()` method to emit RF sign registration events
   - Extracts `RfSignRegResult` from response body
   - Invokes callback with `operMode`, `moduleMac`, and `originalModuleMac`

8. **`android/src/main/java/com/example/wise_apartment/WiseApartmentPlugin.java`**
   - Added RF sign registration callback setup in `initClient()`
   - Emits events with type `rfSignRegistration` to EventChannel
   - Maps status codes to human-readable messages

### iOS Implementation

9. **`ios/Classes/WiseApartmentPlugin.m`**
   - Modified `handleWiFiNetworkConfigNotification:` to emit both WiFi and RF sign events
   - iOS SDK uses the same notification (`KSHNotificationWiFiNetworkConfig`) for both
   - Maps fields: `wifiStatus` → `operMode`, `rfModuleMac` → `moduleMac`, `originalRfModuleMac` → `originalModuleMac`

### Test Implementation

10. **`example/lib/screens/wifi_registration_screen.dart`**
    - Added RF sign registration stream listener
    - Displays RF sign events in a separate card for debugging
    - Shows latest event with operMode, module MAC, and status message

11. **`test/wise_apartment_test.dart`**
    - Added mock implementation for `regwithRfSignStream` getter
    - Returns empty stream for testing purposes

---

## 🔧 API Usage

### 1. Listen to RF Sign Registration Stream

```dart
import 'package:wise_apartment/wise_apartment.dart';
import 'package:wise_apartment/src/models/rf_sign_result.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final _plugin = WiseApartment();
  StreamSubscription<Map<String, dynamic>>? _subscription;
  String _currentStatus = 'Not started';

  @override
  void initState() {
    super.initState();
    _setupListener();
  }

  void _setupListener() {
    _subscription = _plugin.regwithRfSignStream.listen((event) {
      if (event['type'] == 'rfSignRegistration') {
        // Use the model for type-safe access
        final rfResult = RfSignResult.fromMap(event);
        
        setState(() {
          _currentStatus = rfResult.statusMessage;
        });

        // Handle different status codes
        if (rfResult.isSuccess) {
          print('✅ SUCCESS: ${rfResult.statusMessage}');
        } else if (rfResult.isError) {
          print('❌ ERROR: ${rfResult.statusMessage}');
        } else if (rfResult.isProgress) {
          print('⏳ PROGRESS: ${rfResult.statusMessage}');
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
```

### 2. Trigger RF Module Registration

```dart
// Connect to device first
await _plugin.connectBle(auth);

// Build WiFi configuration
final wifiConfig = WifiConfig(
  ssid: 'MyWiFi',
  password: 'MyPassword',
  serverHost: 'mqtt.example.com',
  serverPort: '1883',
);

// Start registration - events will come through the stream
await _plugin.registerWifi(wifiConfig.toRfCodeString(), dna);
```

---

## 📦 Event Format

Each event from the stream has the following structure:

```dart
{
  "type": "rfSignRegistration",        // String - Always "rfSignRegistration"
  "operMode": 5,                       // int - Operation mode (0x02-0x07)
  "moduleMac": "AA:BB:CC:DD:EE:FF",   // String - Wireless module MAC
  "originalModuleMac": "...",          // String - Original module MAC
  "statusMessage": "WiFi module co..." // String - Human-readable message
}
```

### Field Descriptions

- **`type`**: Event type identifier (always `"rfSignRegistration"`)
- **`operMode`**: Integer operation mode indicating current state
- **`statusMessage`**: Human-readable description of the status
- **`moduleMac`**: MAC address of the wireless module
- **`originalModuleMac`**: Original module MAC address from device

---

## 📊 Status Codes

| Code | Name | Description | Terminal? |
|------|------|-------------|-----------|
| 0x02 | Binding in Progress | NB-IoT (WIFI module) is in the process of network distribution binding operation | ❌ |
| 0x04 | Router Connected | WiFi module successfully connected to the router | ❌ |
| 0x05 | Cloud Connected | WiFi module successfully connected to the cloud (success) | ✅ |
| 0x06 | Incorrect Password | Password is incorrect | ✅ |
| 0x07 | Configuration Timeout | WIFI pairing timeout | ✅ |

---

## 🧪 Testing

### Test Screen Location

The WiFi registration test screen at:
```
example/lib/screens/wifi_registration_screen.dart
```

Now includes RF sign registration stream monitoring with:
- Real-time RF sign event display
- Operation mode and status messages
- Module MAC addresses
- Event counter

### Access Test Screen

1. Run the example app
2. Navigate to any device details screen
3. Tap the **"Test WiFi Registration Stream"** button
4. Both WiFi and RF sign events will be displayed

---

## 🔍 Technical Details

### Android

- **Callback Pattern**: Uses `MyBleClient.RfSignRegistrationCallback`
- **Event Source**: `RfSignRegResult` from `rfModuleReg()` callback
- **Thread**: Events emitted on main thread via `Handler`
- **Channel**: Single shared EventChannel (`wise_apartment/ble_events`)

### iOS

- **Notification**: `KSHNotificationWiFiNetworkConfig` (shared with WiFi registration)
- **Event Source**: `SHWiFiNetworkConfigReportParam` object
- **Field Mapping**: 
  - `wifiStatus` → `operMode`
  - `rfModuleMac` → `moduleMac`
  - `originalRfModuleMac` → `originalModuleMac`
- **Channel**: Single shared EventChannel

### Flutter

- **Stream Type**: Broadcast stream filtered by event type
- **Type Safety**: `RfSignResult` model for easy parsing
- **Filtering**: Method channel filters for `type === 'rfSignRegistration'`

---

## 💡 Usage Tips

1. **Subscribe Early**: Set up the stream listener before calling `registerWifi()`
2. **Handle All States**: Listen for progress, success, and error states
3. **Terminal States**: Stop loading/waiting when `isTerminal` is true
4. **Error Recovery**: On error states (0x06, 0x07), allow user to retry
5. **Concurrent Streams**: Both WiFi and RF sign streams can be active simultaneously

---

## 📚 Related Features

- **WiFi Registration Stream** - Real-time WiFi configuration monitoring
- **Sync Lock Keys Stream** - Real-time key synchronization
- **Sync Lock Records Stream** - Real-time record synchronization

All streams follow the same pattern for consistency!

---

## 🎯 Example Flow

```
Your App                          Smart Lock Device
   │                                     │
   ├─ Subscribe to regwithRfSignStream   │
   │                                     │
   ├─ Call registerWifi() ──────────────►│
   │                                     │
   │◄──── Event: 0x02 (Binding...)      │
   │                                     │
   │◄──── Event: 0x04 (Router OK)       │
   │                                     │
   │◄──── Event: 0x05 (Success!)        │
   │                                     │
   └─ Update UI ✅                       │
```

---

**Implementation Date:** February 25, 2026  
**Plugin Version:** Compatible with wise_apartment v2.5.0+  
**Platforms:** Android, iOS
