import 'package:flutter/material.dart';
import 'package:wise_apartment/wise_apartment.dart';
import '../src/secure_storage.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _plugin = WiseApartment();
  List<HxjBluetoothDeviceModel> _scanned = [];
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    if (mounted) setState(() => _scanning = true);
    try {
      final results = await _plugin.startScan(timeoutMs: 5000);
      final list = (results)
          .map((e) => HxjBluetoothDeviceModel.fromMap(e))
          .toList();
      if (mounted) setState(() => _scanned = list);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Scan failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _addDeviceNative(HxjBluetoothDeviceModel device) async {
    final mac = device.getMac();
    if (mac == null || mac.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid device MAC')));
      }
      return;
    }

    try {
      final cipType = device.chipType ?? 0;
      final res = await _plugin.addDevice(mac, cipType);

      Map<String, dynamic>? toSave;
      if (res is Map) {
        toSave = Map<String, dynamic>.from(res);
      } else if (res == true || res == 'ok' || res == 'true') {
        toSave = device.toMap();
      }

      if (toSave != null) {
        await SecureDeviceStorage.addDevice(toSave);
        if (mounted) Navigator.pop(context, toSave);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Add device failed: $res')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Add error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Device')),
      body: RefreshIndicator(
        onRefresh: _startScan,
        child: _scanning && _scanned.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : ListView.builder(
                itemCount: _scanned.length,
                itemBuilder: (ctx, i) {
                  final d = _scanned[i];
                  return ListTile(
                    leading: const Icon(Icons.devices),
                    title: Text(d.name ?? 'Unknown'),
                    subtitle: Text(d.getMac() ?? ''),
                    trailing: ElevatedButton(
                      child: const Text('Add'),
                      onPressed: () => _addDeviceNative(d),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
