import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wise_apartment/wise_apartment.dart';

class KeyTypeEnableScreen extends StatefulWidget {
  final Map<String, dynamic> auth;
  const KeyTypeEnableScreen({Key? key, required this.auth}) : super(key: key);

  @override
  State<KeyTypeEnableScreen> createState() => _KeyTypeEnableScreenState();
}

class _KeyTypeEnableScreenState extends State<KeyTypeEnableScreen> {
  final _plugin = WiseApartment();
  final _keyTypeController = TextEditingController();
  final _validNumberController = TextEditingController(text: '255');
  bool _isEnabled = true;
  bool _processing = false;

  @override
  void dispose() {
    _keyTypeController.dispose();
    _validNumberController.dispose();
    super.dispose();
  }

  void _toggleEnabled(bool value) {
    setState(() {
      _isEnabled = value;
      if (value) {
        // Enabled: set to unlimited by default if not already >0
        final current = int.tryParse(_validNumberController.text.trim()) ?? 0;
        if (current == 0) {
          _validNumberController.text = '255';
        }
      } else {
        // Disabled: set to 0
        _validNumberController.text = '0';
      }
    });
  }

  void _validNumberChanged(String value) {
    final num = int.tryParse(value.trim()) ?? 0;
    setState(() {
      _isEnabled = num != 0;
    });
  }

  Future<void> _apply() async {
    if (_processing) return;

    // Validation
    final keyTypeBitmask = int.tryParse(_keyTypeController.text.trim());
    if (keyTypeBitmask == null || keyTypeBitmask <= 0) {
      _showError('Key Type must be a positive number');
      return;
    }

    final validNumber = int.tryParse(_validNumberController.text.trim());
    if (validNumber == null || validNumber < 0 || validNumber > 255) {
      _showError('Valid Number must be 0-255');
      return;
    }

    setState(() => _processing = true);

    try {
      final response = await _plugin.setKeyTypeEnabled(
        auth: widget.auth,
        keyTypeBitmask: keyTypeBitmask,
        validNumber: validNumber,
      );

      if (!mounted) return;

      final success =
          response['success'] == true ||
          response['isSuccessful'] == true ||
          response['code'] == 0;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              validNumber == 0
                  ? 'Key types disabled successfully'
                  : 'Key types enabled successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        _showError(
          'Operation failed: ${response['message'] ?? response['ackMessage'] ?? response['code']}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Key Type Enable/Disable')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enable or disable key types using operation mode 02 (by key type).',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _keyTypeController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Key Type Bitmask',
                border: OutlineInputBorder(),
                helperText:
                    '01 Fingerprint, 02 Password, 04 Card, 08 Remote,\n64 App temp password, 128 App key, 255 All',
                helperMaxLines: 3,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _validNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: _validNumberChanged,
              decoration: const InputDecoration(
                labelText: 'Valid Number',
                border: OutlineInputBorder(),
                helperText:
                    '0 = DISABLE, 1 = enable for 1 time, 255 = unlimited',
                helperMaxLines: 2,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Enabled',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Switch(value: _isEnabled, onChanged: _toggleEnabled),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _processing ? null : _apply,
              icon: _processing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: const Text('Apply'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
