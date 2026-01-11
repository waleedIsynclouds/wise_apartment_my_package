import 'package:flutter/material.dart';
import 'package:wise_apartment/wise_apartment.dart';
// ignore_for_file: dead_code, unnecessary_null_aware_operator, unused_import, unused_field, unused_element
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'screens/add_device.dart';
import 'screens/device_details.dart';
import 'src/secure_storage.dart';

void main() {
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _plugin = WiseApartment();

  String _log = "";
  List<Map<String, dynamic>> _scanResults = [];
  // Each saved device entry contains the original map ('raw') and parsed DNA model ('dna')
  List<Map<String, dynamic>> _savedDevices = [];
  Map<String, dynamic>? _buildConfig;

  // Form Controllers
  final _macController = TextEditingController(text: "AA:BB:CC:DD:EE:FF");
  final _authCodeController = TextEditingController(text: "123456");
  final _dnaKeyController = TextEditingController(text: "abcdef");

  void _addLog(String msg) {
    setState(() {
      _log = "$msg\n$_log";
    });
    debugPrint(msg);
  }

  Future<void> _initBle() async {
    // Minimal BLE init helper: check permissions and bluetooth adapter state
    try {
      final perms = <Permission>[];
      // Add common permissions; on older Android some are ignored
      perms.addAll([
        Permission.location,
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ]);

      bool allGranted = true;
      for (final p in perms) {
        final status = await p.status;
        if (!status.isGranted) {
          final req = await p.request();
          if (!req.isGranted) {
            allGranted = false;
            break;
          }
        }
      }

      if (!allGranted) {
        _addLog('Permissions not granted. Please allow Bluetooth permissions.');
        return;
      }

      final btOn = await FlutterBluePlus.isOn;
      if (btOn == false) {
        _addLog('Bluetooth is disabled. Please enable Bluetooth.');
        return;
      }

      _addLog('BLE initialized and ready.');
    } catch (e) {
      _addLog('BLE init failed: $e');
    }
  }

  Future<void> _startScan() async {
    try {
      // Ensure permissions and adapter state via _initBle
      await _initBle();

      _addLog('Starting Scan...');
      final results = await _plugin.startScan(timeoutMs: 5000);
      setState(() {
        _scanResults = results;
      });
      _addLog('Scan Complete. Found: ${results.length} devices.');
    } catch (e) {
      _addLog('Scan Failed: $e');
    }
  }

  Future<void> _openLock() async {
    if (_macController.text.isEmpty) {
      _addLog("MAC Address required!");
      return;
    }
    _addLog("Opening Lock ${_macController.text}...");
    try {
      final auth = {
        "mac": _macController.text,
        "authCode": _authCodeController.text,
        "dnaKey": _dnaKeyController.text,
        "keyGroupId": 1,
        "bleProtocolVer": 2,
      };
      final success = await _plugin.openLock(auth);
      _addLog("Open Lock Success: $success");
    } catch (e) {
      _addLog("Open Lock Error: $e");
    }
  }

  Future<void> _getBuildConfig() async {
    try {
      final conf = await _plugin.getAndroidBuildConfig();
      setState(() => _buildConfig = conf);
      _addLog("Fetched Build Config");
    } catch (e) {
      _addLog("Config Error: $e");
    }
  }

  Future<void> _clearS() async {
    await _plugin.clearSdkState();
    _addLog("SDK State Cleared.");
  }

  @override
  void initState() {
    super.initState();
    _loadSavedDevices();
    // Run after first frame so dialogs can use context safely.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _ensurePermissionsAndServices(),
    );
  }

  /// Ensure required permissions and services (Bluetooth, Location) are enabled on app start.
  Future<void> _ensurePermissionsAndServices() async {
    try {
      // Request runtime permissions.
      final perms = <Permission>[
        Permission.location,
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ];

      bool allGranted = true;
      for (final p in perms) {
        final status = await p.status;
        if (!status.isGranted) {
          final req = await p.request();
          if (!req.isGranted) {
            allGranted = false;
            break;
          }
        }
      }

      if (!allGranted) {
        if (!mounted) return;
        final retry = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Permissions required'),
            content: const Text(
              'This app requires Bluetooth and Location permissions to function. Open app settings to enable them, or retry.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Open Settings'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
        if (retry == true) {
          await _ensurePermissionsAndServices();
        } else {
          openAppSettings();
        }
        return;
      }
      final state = await FlutterBluePlus.adapterState.first;
      // Check Bluetooth adapter state
      if (state == BluetoothAdapterState.off) {
        // Try to enable Bluetooth programmatically (may not be supported on all platforms)
        try {
          await FlutterBluePlus.turnOn();
        } catch (_) {}

        // Re-check status after attempting to turn on
        final newState = await FlutterBluePlus.adapterState.first;
        if (newState == BluetoothAdapterState.off) {
          if (!mounted) return;
          final retry = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('Enable Bluetooth'),
              content: const Text(
                'Bluetooth is disabled. Please enable Bluetooth in system settings and retry.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Open Settings'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
          if (retry == true) {
            await _ensurePermissionsAndServices();
          } else {
            openAppSettings();
          }
          return;
        }
      }

      // Check location service (GPS) status where available.
      final serviceStatus = await Permission.location.serviceStatus;
      if (serviceStatus != ServiceStatus.enabled) {
        if (!mounted) return;
        final retry = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Enable Location Services'),
            content: const Text(
              'Location services are disabled. Please enable location services and retry.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Open Settings'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
        if (retry == true) {
          await _ensurePermissionsAndServices();
        } else {
          openAppSettings();
        }
        return;
      }

      _addLog(
        'Startup checks passed: permissions, Bluetooth, and Location OK.',
      );
    } catch (e) {
      _addLog('Startup checks failed: $e');
    }
  }

  Future<void> _loadSavedDevices() async {
    final devices = await SecureDeviceStorage.loadDevices();
    final list = devices
        .map((m) => {'raw': m, 'dna': DnaInfoModel.fromMap(m)})
        .toList();
    setState(() => _savedDevices = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiseApartment V2 — Devices'),
        actions: [
          IconButton(
            tooltip: 'Scan',
            onPressed: _startScan,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Init BLE',
            onPressed: _initBle,
            icon: const Icon(Icons.bluetooth),
          ),
          IconButton(
            tooltip: 'Build Config',
            onPressed: _getBuildConfig,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _startScan(),
              child: _savedDevices.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _savedDevices.length,
                      itemBuilder: (context, index) {
                        final entry = _savedDevices[index];
                        final Map<String, dynamic> raw =
                            Map<String, dynamic>.from(entry['raw'] ?? {});
                        final DnaInfoModel d = entry['dna'] as DnaInfoModel;
                        final displayName = raw['name'] as String?;
                        final mac = d.mac ?? '';
                        final rssi =
                            raw['rssi']?.toString() ??
                            raw['RSSI']?.toString() ??
                            '';
                        final protocol = d.protocolVer?.toString() ?? 'N/A';
                        final deviceType = d.deviceType?.toString() ?? 'N/A';
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.lock),
                            title: Text(displayName ?? mac),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (displayName != null) Text(mac),
                                if (rssi.isNotEmpty) Text('$rssi dBm'),
                                const SizedBox(height: 4),
                                Text(
                                  'Protocol: $protocol • Type: $deviceType',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            onTap: () async {
                              final res =
                                  await Navigator.push<Map<String, dynamic>>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DeviceDetailsScreen(device: d),
                                    ),
                                  );
                              if (res != null && res['removed'] == true) {
                                await _loadSavedDevices();
                              }
                            },
                          ),
                        );
                      },
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('No saved devices.'),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: _startScan,
                                  child: const Text('Scan for devices'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          Container(
            height: 120,
            color: Colors.black12,
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            child: SingleChildScrollView(child: Text(_log)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await Navigator.of(context).push<Map<String, dynamic>>(
            MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
          );
          if (res != null) {
            await _loadSavedDevices();
          }
        },
        tooltip: 'Add device',
        child: const Icon(Icons.add),
      ),
    );
  }
}
