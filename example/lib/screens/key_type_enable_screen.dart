// ignore_for_file: unused_local_variable, unused_field, unnecessary_cast, unused_import, dead_code
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wise_apartment/wise_apartment.dart';

class KeyTypeEnableScreen extends StatefulWidget {
  final Map<String, dynamic> auth;
  const KeyTypeEnableScreen({Key? key, required this.auth}) : super(key: key);

  @override
  State<KeyTypeEnableScreen> createState() => _KeyTypeEnableScreenState();
}

class _KeyTypeEnableScreenState extends State<KeyTypeEnableScreen>
    with SingleTickerProviderStateMixin {
  final _plugin = WiseApartment();
  late TabController _tabController;
  bool _processing = false;

  // Tab 1: By Key ID
  final _lockKeyIdController = TextEditingController();
  final _keyTypeByIdController = TextEditingController();
  bool _isEnabledById = true;

  // Tab 2: By Key Type
  final _keyTypeBitmaskController = TextEditingController();
  bool _isEnabledByType = true;

  // Tab 3: By User ID
  final _userIdController = TextEditingController();
  bool _isEnabledByUserId = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _lockKeyIdController.dispose();
    _keyTypeByIdController.dispose();
    _keyTypeBitmaskController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _applyById(bool enabling) async {
    FocusScope.of(context).unfocus();
    if (_processing) return;

    final lockKeyId = int.tryParse(_lockKeyIdController.text.trim());
    if (lockKeyId == null || lockKeyId < 0) {
      _showError('Lock Key ID must be a non-negative number');
      return;
    }
    // Parse Key Type (required for OperMode 01). User ID is optional here.
    final keyType = int.tryParse(_keyTypeByIdController.text.trim());
    if (keyType == null || keyType < 0) {
      _showError('Key Type must be a non-negative number');
      return;
    }

    final userId = 0;

    setState(() => _processing = true);

    try {
      final response = await _plugin.enableKeyById(
        auth: widget.auth,
        lockKeyId: lockKeyId,
        keyType: keyType,
        userId: userId,
        enabled: enabling,
      );

      if (!mounted) return;

      if (_isSuccess(response)) {
        _showSuccess(
          enabling
              ? 'Key ID $lockKeyId enabled successfully'
              : 'Key ID $lockKeyId disabled successfully',
        );
      } else {
        _showError(_getErrorMessage(response));
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _applyByType(bool enabling) async {
    FocusScope.of(context).unfocus();
    if (_processing) return;

    final keyTypeBitmask = int.tryParse(_keyTypeBitmaskController.text.trim());
    if (keyTypeBitmask == null || keyTypeBitmask <= 0) {
      _showError('Key Type Bitmask must be a positive number');
      return;
    }

    setState(() => _processing = true);

    try {
      final response = await _plugin.enableKeyByType(
        auth: widget.auth,
        keyTypeBitmask: keyTypeBitmask,
        enabled: enabling,
      );

      if (!mounted) return;

      if (_isSuccess(response)) {
        _showSuccess(
          enabling
              ? 'Key type(s) enabled successfully'
              : 'Key type(s) disabled successfully',
        );
      } else {
        _showError(_getErrorMessage(response));
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _applyByUserId(bool enabling) async {
    FocusScope.of(context).unfocus();
    if (_processing) return;

    final userId = int.tryParse(_userIdController.text.trim());
    if (userId == null || userId < 0) {
      _showError('User ID must be a non-negative number');
      return;
    }

    setState(() => _processing = true);

    try {
      final response = await _plugin.enableKeyByUserId(
        auth: widget.auth,
        userId: userId,
        enabled: enabling,
      );

      if (!mounted) return;

      if (_isSuccess(response)) {
        _showSuccess(
          enabling
              ? 'User ID $userId keys enabled successfully'
              : 'User ID $userId keys disabled successfully',
        );
      } else {
        _showError(_getErrorMessage(response));
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  bool _isSuccess(Map<String, dynamic> response) {
    return response['success'] == true ||
        response['isSuccessful'] == true ||
        response['code'] == 0;
  }

  String _getErrorMessage(Map<String, dynamic> response) {
    return 'Operation failed: ${response['message'] ?? response['ackMessage'] ?? response['code']}';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enable/Disable Keys'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'By Key ID'),
            Tab(text: 'By Type'),
            Tab(text: 'By User ID'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildByKeyIdTab(), _buildByTypeTab(), _buildByUserIdTab()],
      ),
    );
  }

  Widget _buildByKeyIdTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enable or disable a specific key by its Key ID (Operation Mode 1).',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _lockKeyIdController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Lock Key ID *',
              border: OutlineInputBorder(),
              helperText: 'The specific key ID to enable/disable',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _keyTypeByIdController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Key Type *',
              border: OutlineInputBorder(),
              helperText: '1=Fingerprint, 2=Password, 4=Card, 8=Remote, etc.',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _processing ? null : () => _applyById(true),
                  child: _processing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Enable'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _processing ? null : () => _applyById(false),
                  child: _processing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Disable'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildByTypeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enable or disable all keys of specific type(s) (Operation Mode 2).',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _keyTypeBitmaskController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Key Type Bitmask *',
              border: OutlineInputBorder(),
              helperText:
                  '01=Fingerprint, 02=Password, 04=Card, 08=Remote,\n64=App temp password, 128=App key, 255=All',
              helperMaxLines: 3,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Key Type Values:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('• 01 (0x01) - Fingerprint'),
                  const Text('• 02 (0x02) - Password'),
                  const Text('• 04 (0x04) - Card'),
                  const Text('• 08 (0x08) - Remote control'),
                  const Text('• 64 (0x40) - App temp password'),
                  const Text('• 128 (0x80) - App key'),
                  const Text('• 255 (0xFF) - All types'),
                  const SizedBox(height: 8),
                  const Text(
                    'Tip: You can combine types by adding them (e.g., 3 = Fingerprint + Password)',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _processing ? null : () => _applyByType(true),
                  child: _processing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Enable'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _processing ? null : () => _applyByType(false),
                  child: _processing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Disable'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildByUserIdTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enable or disable all keys for a specific user (Operation Mode 3).',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _userIdController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'User ID / Key Group ID *',
              border: OutlineInputBorder(),
              helperText: 'All keys belonging to this user will be affected',
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade900),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This will enable/disable ALL keys associated with the specified user ID.',
                      style: TextStyle(color: Colors.amber.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _processing ? null : () => _applyByUserId(true),
                  child: _processing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Enable'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _processing ? null : () => _applyByUserId(false),
                  child: _processing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Disable'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
