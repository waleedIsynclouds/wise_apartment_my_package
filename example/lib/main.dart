import 'package:flutter/material.dart';
import 'package:wise_apartment/wise_apartment.dart';
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'screens/add_device.dart';
import 'screens/device_details.dart';
import 'src/secure_storage.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
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
    try {
      final res = await _plugin.initBleClient();
      _addLog("BLE Init Result: $res");
    } catch (e) {
      _addLog("Init Error: $e");
    }
  }

  Future<void> _startScan() async {
    _addLog("Checking permissions and Bluetooth state before scanning...");

    // Request required permissions
    try {
      // On Android we need location and bluetooth permissions
      if (Platform.isAndroid) {
        final permissions = <Permission>[
          Permission.location,
          Permission.bluetooth,
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
        ];

        final statuses = await permissions.request();

        // If any required permission is denied, prompt the user
        bool allGranted = true;
        // for (final p in permissions) {
        //   final s = await p.status;
        //   log('Permission ${p.toString()}: ${s.toString()}');
        //   if (!s.isGranted) {
        //     allGranted = false;
        //     break;
        //   }
        // }

        if (!allGranted) {
          _addLog(
            'Permissions not granted. Request permissions in app settings.',
          );
          final open = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Permissions required'),
              content: const Text(
                'Bluetooth and Location permissions are required to scan for devices.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
          if (open == true) openAppSettings();
          return;
        }
      }

      // Check Bluetooth adapter state
      final btOn = await FlutterBluePlus.isOn;
      if (btOn == false) {
        _addLog('Bluetooth is disabled. Please enable Bluetooth to scan.');
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Bluetooth disabled'),
            content: const Text('Please enable Bluetooth to scan for devices.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

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
  }

  Future<void> _loadSavedDevices() async {
    final devices = await SecureDeviceStorage.loadDevices();
    setState(() => _savedDevices = devices);
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
                        final d = _savedDevices[index];
                        final name = d['name'] ?? 'Unknown';
                        final mac = d['mac'] ?? '';
                        final rssi = d['rssi']?.toString() ?? '';
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.lock),
                            title: Text(name),
                            subtitle: Text(mac),
                            trailing: Text('$rssi dBm'),
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
