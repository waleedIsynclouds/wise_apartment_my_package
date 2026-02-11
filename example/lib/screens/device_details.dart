import 'package:flutter/material.dart';
import 'package:wise_apartment/wise_apartment.dart';
import 'sys_param_screen.dart';
import 'package:flutter/services.dart';
import 'package:wise_apartment/src/wise_status_store.dart';
import 'package:permission_handler/permission_handler.dart';
import 'sync_loc_records.dart';
import 'sync_keys_screen.dart';
import 'dna_info_screen.dart';
import 'add_lock_key_screen.dart';
import '../src/secure_storage.dart';
import '../src/wifi_config.dart';
import '../src/config.dart';
import '../src/api_service.dart';
// wifi info removed; default SSID/password used instead

class DeviceDetailsScreen extends StatefulWidget {
  final DnaInfoModel device;
  const DeviceDetailsScreen({super.key, required this.device});

  @override
  State<DeviceDetailsScreen> createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  final _plugin = WiseApartment();

  bool _busy = false;
  // Centralized form state for WiFi inputs and UI flags.
  // Grouping controllers makes lifecycle management and usage clearer.
  final _form = _FormState();

  Future<void> _openLock() async {
    setState(() => _busy = true);
    final auth = widget.device.toMap();
    try {
      final Map<String, dynamic> resp = await _plugin.openLock(auth);
      // Persist/store status info from native if present
      try {
        WiseStatusStore.setFromMap(resp);
      } catch (_) {}
      if (!mounted) return;
      final ack = resp['ackMessage'] ?? resp['message'] ?? 'unknown';
      final power = resp['body'] is Map
          ? (resp['body']['power'] ?? resp['power'])
          : resp['power'];
      final unlockingDuration = resp['body'] is Map
          ? (resp['body']['unlockingDuration'] ?? resp['unlockingDuration'])
          : resp['unlockingDuration'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Open: $ack (power: $power, duration: $unlockingDuration)',
          ),
        ),
      );
    } catch (e) {
      WiseStatusHandler? status;
      String? codeStr;
      String? msg;
      if (e is WiseApartmentException) {
        codeStr = e.code;
        msg = e.message;
        try {
          status = WiseStatusStore.setFromWiseException(e);
        } catch (_) {}
      } else if (e is PlatformException) {
        try {
          status = WiseStatusStore.setFromMap(
            e.details as Map<String, dynamic>?,
          );
        } catch (_) {}
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Open error: ${msg ?? e} (code: ${codeStr ?? status?.code})',
          ),
        ),
      );
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _closeLock() async {
    setState(() => _busy = true);
    final auth = widget.device.toMap();
    try {
      final ok = await _plugin.closeLock(auth);
      WiseStatusStore.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Close: $ok')));
    } catch (e) {
      WiseStatusHandler? status;
      String? codeStr;
      String? msg;
      if (e is WiseApartmentException) {
        codeStr = e.code;
        msg = e.message;
        try {
          status = WiseStatusStore.setFromWiseException(e);
        } catch (_) {}
      } else if (e is PlatformException) {
        try {
          status = WiseStatusStore.setFromMap(
            e.details as Map<String, dynamic>?,
          );
        } catch (_) {}
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Close error: ${msg ?? e} (code: ${codeStr ?? status?.code})',
          ),
        ),
      );
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _deleteLock() async {
    setState(() => _busy = true);
    final auth = widget.device.toMap();
    try {
      final ok = await _plugin.deleteLock(auth);
      if (ok == true) {
        // remove from secure storage
        try {
          await SecureDeviceStorage.removeDevice(widget.device.mac ?? '');
        } catch (_) {}

        // show confirmation and pop back with info
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Device deleted'),
            content: const Text(
              'The device was deleted and removed from storage.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        if (!mounted) return;
        // Ensure BLE disconnect before leaving this screen. Only attempt
        // if runtime permissions are still granted (Android 12+ needs
        // BLUETOOTH_CONNECT / BLUETOOTH_SCAN).
        try {
          await _plugin.disconnectBle();
        } catch (_) {}
        Navigator.pop(context, {'removed': true, 'mac': widget.device.mac});
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $ok')));
      }
    } catch (e) {
      WiseStatusHandler? status;
      String? codeStr;
      String? msg;
      if (e is WiseApartmentException) {
        codeStr = e.code;
        msg = e.message;
        try {
          status = WiseStatusStore.setFromWiseException(e);
        } catch (_) {}
      } else if (e is PlatformException) {
        try {
          status = WiseStatusStore.setFromMap(
            e.details as Map<String, dynamic>?,
          );
        } catch (_) {}
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Delete error: ${msg ?? e} (code: ${codeStr ?? status?.code})',
          ),
        ),
      );
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // Attempt to connect when the screen is shown. Use a post-frame callback
    // so we have a valid BuildContext for SnackBars.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => _busy = true);
      final auth = widget.device.toMap();
      try {
        final ok = await _plugin.connectBle(auth);
        WiseStatusStore.clear();
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('BLE connect: $ok')));
      } catch (e) {
        WiseStatusHandler? status;
        String? codeStr;
        String? msg;
        if (e is WiseApartmentException) {
          codeStr = e.code;
          msg = e.message;
          try {
            status = WiseStatusStore.setFromWiseException(e);
          } catch (_) {}
        } else if (e is PlatformException) {
          try {
            status = WiseStatusStore.setFromMap(
              e.details as Map<String, dynamic>?,
            );
          } catch (_) {}
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'BLE connect error: ${msg ?? e} (code: ${codeStr ?? status?.code})',
            ),
          ),
        );
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    });
  }

  /// (removed) BLE permission helper was unused and created analyzer noise.

  Future<void> _registerWifi() async {
    setState(() => _busy = true);

    // Default host/port are centralized in `ExampleConfig` so they
    // can be changed in one place for the whole example app.
    final defaultHost = ExampleConfig.defaultHost;
    final defaultPort = ExampleConfig.defaultPort;
    // Build WifiConfig from centralized form state
    String tokenIdVal = '';
    if (_form.configurationType == WifiConfigurationType.wifiOnly) {
      tokenIdVal = '';
    } else {
      // Obtain a lock-specific token via platform APIs (hidden from user).
      final lockToken = await ApiService.instance.getLockTokenForDevice(
        widget.device,
      );
      if (lockToken == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to get lock token; cannot register WiFi'),
          ),
        );
        setState(() => _busy = false);
        return;
      }
      tokenIdVal = lockToken;
    }
    final serverAddrVal = _form.serverAddressController.text.trim().isEmpty
        ? defaultHost
        : _form.serverAddressController.text.trim();
    final serverPortVal = _form.serverPortController.text.trim().isEmpty
        ? defaultPort
        : _form.serverPortController.text.trim();

    final wifiModel = WifiConfig(
      ssid: _form.ssidController.text.trim(),
      password: _form.passwordController.text,
      serverAddress: serverAddrVal,
      serverPort: serverPortVal,
      configurationType: _form.configurationType,
      tokenId: tokenIdVal,
      updateToken: _form.updateTokenSelection,
    );

    // Pass the full DnaInfoModel map to native side to avoid losing fields.
    final dna = widget.device.toMap(); // pass full dna map to native side

    try {
      final res = await _plugin.registerWifi(wifiModel.toRfCodeString(), dna);
      // capture numeric status from response map (returns a status object)
      final status = WiseStatusStore.setFromMap(res);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('regWifi: ${res.toString()} (code: ${status?.code})'),
        ),
      );
    } catch (e) {
      WiseStatusHandler? status;
      String? codeStr;
      String? msg;
      if (e is WiseApartmentException) {
        codeStr = e.code;
        msg = e.message;
        try {
          status = WiseStatusStore.setFromWiseException(e);
        } catch (_) {}
      } else if (e is PlatformException) {
        try {
          status = WiseStatusStore.setFromMap(
            e.details as Map<String, dynamic>?,
          );
        } catch (_) {}
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'regWifi error: ${msg ?? e} (code: ${codeStr ?? status?.code})',
          ),
        ),
      );
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _openSyncLocRecords() async {
    final auth = widget.device.toMap();
    if (!mounted) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => SyncLocRecordsScreen(auth: auth)));
  }

  // Removed _removeFromStorage helper — deletion now removes from storage

  @override
  Widget build(BuildContext context) {
    final name = widget.device.mac ?? 'Device';
    final mac = widget.device.mac ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text("Device Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Sys Params',
            onPressed: () async {
              final auth = widget.device.toMap();
              if (!mounted) return;
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SysParamScreen(auth: auth)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Show DNA info',
            onPressed: () async {
              final auth = widget.device.toMap();
              if (!mounted) return;
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => DnaInfoScreen(dna: auth)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.access_time),
            tooltip: 'Sync lock time',
            onPressed: () async {
              setState(() => _busy = true);
              final auth = widget.device.toMap();
              try {
                final ok = await _plugin.syncLockTime(auth);
                WiseStatusStore.clear();
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Sync time: $ok')));
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Sync time error: $e')));
              } finally {
                if (mounted) setState(() => _busy = false);
              }
            },
          ),
        ],
      ),
      body: PopScope(
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) {
            await _plugin.disconnectBle();
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(child: Icon(Icons.lock, size: 120, color: Colors.green)),
              const SizedBox(height: 8),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(mac, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              if (_busy) const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _openLock,
                    child: const Text('Open'),
                  ),
                  ElevatedButton(
                    onPressed: _closeLock,
                    child: const Text('Close'),
                  ),
                  ElevatedButton(
                    onPressed: _deleteLock,
                    child: const Text('Delete'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  onPressed: _openSyncLocRecords,
                  child: const Text('Sync Loc records'),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final auth = widget.device.toMap();
                    if (!mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SyncKeysScreen(auth: auth),
                      ),
                    );
                  },
                  child: const Text('Sync Keys'),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final auth = widget.device.toMap();
                    if (!mounted) return;
                    // Pass a typed AddLockKeyActionModel as defaults instead of a raw Map
                    final defaults = AddLockKeyActionModel();
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            AddLockKeyScreen(auth: auth, defaults: defaults),
                      ),
                    );
                  },
                  child: const Text('Add Key'),
                ),
              ),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  children: [
                    // WiFi SSID input
                    TextField(
                      controller: _form.ssidController,
                      decoration: const InputDecoration(labelText: 'WiFi SSID'),
                    ),
                    const SizedBox(height: 8),
                    // WiFi password input with show/hide toggle
                    TextField(
                      controller: _form.passwordController,
                      decoration: InputDecoration(
                        labelText: 'WiFi Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _form.showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _form.showPassword = !_form.showPassword,
                          ),
                        ),
                      ),
                      obscureText: !_form.showPassword,
                    ),
                    const SizedBox(height: 8),
                    // Configuration type dropdown (placed above Token ID)
                    DropdownButtonFormField<WifiConfigurationType>(
                      initialValue: _form.configurationType,
                      items: const [
                        DropdownMenuItem(
                          value: WifiConfigurationType.serverOnly,
                          child: Text('Server only'),
                        ),
                        DropdownMenuItem(
                          value: WifiConfigurationType.wifiOnly,
                          child: Text('WiFi only'),
                        ),
                        DropdownMenuItem(
                          value: WifiConfigurationType.wifiAndServer,
                          child: Text('WiFi and Server'),
                        ),
                      ],
                      onChanged: (v) => setState(
                        () => _form.configurationType =
                            v ?? WifiConfigurationType.wifiOnly,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Configuration Type',
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Only show Token ID and Server fields when not WiFi-only
                    if (_form.configurationType !=
                        WifiConfigurationType.wifiOnly) ...[
                      // Token acquisition is handled automatically on Register.
                      // Server address and port inputs
                      TextField(
                        controller: _form.serverAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Server Address',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _form.serverPortController,
                        decoration: const InputDecoration(
                          labelText: 'Server Port',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Update token dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _form.updateTokenSelection,
                      items: const [
                        DropdownMenuItem(
                          value: '01',
                          child: Text('Update token'),
                        ),
                        DropdownMenuItem(
                          value: '02',
                          child: Text('Do not update'),
                        ),
                      ],
                      onChanged: (v) => setState(
                        () => _form.updateTokenSelection = v ?? '02',
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Update Token',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 8),
                    const Text(
                      'Server and port default to http://34.166.141.220:8090',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _registerWifi,
                      child: const Text('Register WiFi'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  // Helper to build the auth map for native calls from the current device
}

// Centralized container for form state (controllers and flags).
// Keeps this state isolated and makes lifecycle management straightforward.
class _FormState {
  final TextEditingController ssidController = TextEditingController(
    text: ExampleConfig.defaultSsid,
  );
  final TextEditingController passwordController = TextEditingController(
    text: ExampleConfig.defaultPassword,
  );
  final TextEditingController tokenIdController = TextEditingController(
    text: 'EemUAotGmkeAelOLKqBHBA==',
  );
  final TextEditingController serverAddressController = TextEditingController(
    text: ExampleConfig.defaultHost,
  );
  final TextEditingController serverPortController = TextEditingController(
    text: ExampleConfig.defaultPort,
  );
  bool showPassword = false;
  // '01' => update, '02' => do not update
  String updateTokenSelection = '01';
  WifiConfigurationType configurationType = WifiConfigurationType.wifiAndServer;

  void dispose() {
    ssidController.dispose();
    passwordController.dispose();
    tokenIdController.dispose();
    serverAddressController.dispose();
    serverPortController.dispose();
  }
}
