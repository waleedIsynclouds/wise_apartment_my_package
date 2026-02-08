import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wise_apartment/wise_apartment.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddKeyScreen extends StatefulWidget {
  final Map<String, dynamic> auth;
  const AddKeyScreen({super.key, required this.auth});

  @override
  State<AddKeyScreen> createState() => _AddKeyScreenState();
}

class _AddKeyScreenState extends State<AddKeyScreen> {
  final _plugin = WiseApartment();
  final _paramsController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Populate default JSON example; prefer last saved addedKeyGroupId from local storage
    _populateDefaultParams();
  }

  Future<void> _populateDefaultParams() async {
    final Map<String, dynamic> defaults = {
      // Typical AddLockKey params; adapt to your lock model as needed
      "keyType": 1,
      "keyLen": 6,
      "key": "123456",
    };

    try {
      final mac = widget.auth['mac'] as String? ?? 'unknown_mac';
      final key = 'wise_saved_keys_$mac';
      final raw = await _storage.read(key: key);
      if (raw != null && raw.isNotEmpty) {
        final list = json.decode(raw) as List<dynamic>;
        if (list.isNotEmpty) {
          final last = list.last;
          int? lastGroupId;
          if (last is Map && last.containsKey('addedKeyGroupId')) {
            final v = last['addedKeyGroupId'];
            if (v is int) {
              lastGroupId = v;
            } else if (v is String) {
              lastGroupId = int.tryParse(v);
            }
          }
          if (lastGroupId != null) defaults['addedKeyGroupId'] = lastGroupId;
        }
      }
    } catch (_) {}

    _paramsController.text = json.encode(
      defaults,
      toEncodable: (v) => v.toString(),
    );
  }

  @override
  void dispose() {
    _paramsController.dispose();
    super.dispose();
  }

  Future<void> _addKey() async {
    setState(() => _busy = true);
    Map<String, dynamic> params;
    try {
      params = json.decode(_paramsController.text) as Map<String, dynamic>;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid JSON')));
      setState(() => _busy = false);
      return;
    }

    try {
      final res = await _plugin.addLockKey(widget.auth, params);
      if (!mounted) return;
      // Show result and persist under device-specific key
      await _persistKeyResult(res);
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Add Key Result'),
          content: SingleChildScrollView(
            child: Text(const JsonEncoder.withIndent('  ').convert(res)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      String msg = 'Error: $e';
      if (e is WiseApartmentException) {
        msg = '${e.code}: ${e.message}';
      } else if (e is WiseApartmentException) {
        msg = '${e.code}: ${e.message}';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _persistKeyResult(Map<String, dynamic> res) async {
    try {
      final mac = widget.auth['mac'] as String? ?? 'unknown_mac';
      final key = 'wise_saved_keys_$mac';
      final raw = await _storage.read(key: key);
      List<dynamic> list = [];
      if (raw != null && raw.isNotEmpty) {
        try {
          list = json.decode(raw) as List<dynamic>;
        } catch (_) {
          list = [];
        }
      }
      list.add(res);
      await _storage.write(key: key, value: json.encode(list));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Lock Key')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Edit the parameters JSON for `addLockKey` then press Add Key.',
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _paramsController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(height: 8),
            if (_busy) const Center(child: CircularProgressIndicator()),
            ElevatedButton(
              onPressed: _busy ? null : _addKey,
              child: const Text('Add Key'),
            ),
          ],
        ),
      ),
    );
  }
}
