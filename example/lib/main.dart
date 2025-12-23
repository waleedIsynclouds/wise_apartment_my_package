import 'package:flutter/material.dart';
import 'package:wise_apartment/wise_apartment.dart';

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
    _addLog("Starting Scan...");
    try {
      final results = await _plugin.startScan(timeoutMs: 5000);
      setState(() {
        _scanResults = results;
      });
      _addLog("Scan Complete. Found: ${results.length} devices.");
    } catch (e) {
      _addLog("Scan Failed: $e");
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WiseApartment V2 (HXJ BLE)')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton(
                      onPressed: _initBle,
                      child: const Text("Init BLE"),
                    ),
                    ElevatedButton(
                      onPressed: _startScan,
                      child: const Text("Scan (5s)"),
                    ),
                    ElevatedButton(
                      onPressed: _getBuildConfig,
                      child: const Text("Build Config"),
                    ),
                    OutlinedButton(
                      onPressed: _clearS,
                      child: const Text("Clear State"),
                    ),
                  ],
                ),
                const Divider(),
                const Text(
                  "Operation: Open Lock",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _macController,
                  decoration: const InputDecoration(labelText: "MAC Address"),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _authCodeController,
                        decoration: const InputDecoration(
                          labelText: "Auth Code",
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _dnaKeyController,
                        decoration: const InputDecoration(labelText: "DNA Key"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _openLock,
                  child: const Text("Open Lock"),
                ),
                const Divider(),
                if (_buildConfig != null)
                  Text(
                    "Build Config: $_buildConfig",
                    style: const TextStyle(fontSize: 10),
                  ),
                const Divider(),
                const Text(
                  "Scan Results:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ..._scanResults.map(
                  (d) => ListTile(
                    title: Text(d['name'] ?? 'Unknown'),
                    subtitle: Text(d['mac'] ?? ''),
                    trailing: Text("${d['rssi']} dBm"),
                    onTap: () {
                      _macController.text = d['mac'];
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 150,
            color: Colors.black12,
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            child: SingleChildScrollView(child: Text(_log)),
          ),
        ],
      ),
    );
  }
}
