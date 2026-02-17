import 'dart:convert';
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wise_apartment/wise_apartment.dart';
import 'package:wise_apartment/src/wise_status_store.dart';
import 'package:wise_apartment/src/models/keys/add_lock_key_action_model.dart';
import 'package:wise_apartment/src/models/keys/delete_lock_key_action_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'add_lock_key_screen.dart';
import 'edit_key_screen.dart';

class SyncKeysScreen extends StatefulWidget {
  final Map<String, dynamic> auth;
  const SyncKeysScreen({Key? key, required this.auth}) : super(key: key);

  @override
  State<SyncKeysScreen> createState() => _SyncKeysScreenState();
}

class _SyncKeysScreenState extends State<SyncKeysScreen> {
  final _plugin = WiseApartment();
  bool _loading = false;
  List<Map<String, dynamic>>? _syncedKeys;
  StreamSubscription<Map<String, dynamic>>? _streamSubscription;
  List<Map<String, dynamic>> _partialKeys = [];
  int _chunksReceived = 0;
  String _statusMessage = '';
  bool _togglingKey = false;
  int? _togglingKeyIndex;

  // Controllers and storage for Add Key bottom sheet
  final _keyTypeController = TextEditingController();
  final _keyLenController = TextEditingController();
  final _keyController = TextEditingController();
  final _addedKeyGroupIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _keyDataTypeController = TextEditingController();
  final _validModeController = TextEditingController();
  final _addedKeyTypeController = TextEditingController();
  final _addedKeyIDController = TextEditingController();
  final _modifyTimestampController = TextEditingController();
  final _validStartController = TextEditingController();
  final _validEndController = TextEditingController();
  final _vaildNumberController = TextEditingController();
  final _weekController = TextEditingController();
  final _dayStartController = TextEditingController();
  final _dayEndController = TextEditingController();
  // KeyType options are not used in this screen; removed to avoid analyzer warnings.
  final _storage = const FlutterSecureStorage();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncKeys();
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _keyTypeController.dispose();
    _keyLenController.dispose();
    _keyController.dispose();
    _addedKeyGroupIdController.dispose();
    _passwordController.dispose();
    // authorMode controller removed; nothing to dispose here
    _keyDataTypeController.dispose();
    _validModeController.dispose();
    _addedKeyTypeController.dispose();
    _addedKeyIDController.dispose();
    _modifyTimestampController.dispose();
    _validStartController.dispose();
    _validEndController.dispose();
    _vaildNumberController.dispose();
    _weekController.dispose();
    _dayStartController.dispose();
    _dayEndController.dispose();
    super.dispose();
  }

  Future<void> _syncKeys() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _partialKeys = [];
      _chunksReceived = 0;
      _statusMessage = 'Starting sync...';
      _syncedKeys = null;
    });

    // Cancel any existing subscription
    await _streamSubscription?.cancel();

    try {
      // Listen to the stream for incremental updates
      _streamSubscription = _plugin.syncLockKeyStream.listen(
        (event) {
          if (!mounted) return;

          final type = event['type'] as String?;

          if (type == 'syncLockKeyChunk') {
            // Received a chunk (single key)
            final item = event['item'] as Map<dynamic, dynamic>?;
            final keyNum = event['keyNum'] as int? ?? 0;
            final totalSoFar = event['totalSoFar'] as int? ?? 0;

            if (item != null) {
              final keyMap = Map<String, dynamic>.from(item);
              setState(() {
                _partialKeys.add(keyMap);
                _chunksReceived++;
                _statusMessage =
                    'Received key #$keyNum ($totalSoFar keys so far)';
              });
            }
          } else if (type == 'syncLockKeyDone') {
            // Sync completed successfully
            final items = event['items'] as List<dynamic>?;
            final total = event['total'] as int? ?? 0;

            if (items != null) {
              final allKeys = items
                  .map((e) => Map<String, dynamic>.from(e as Map))
                  .toList();

              setState(() {
                _syncedKeys = allKeys;
                _loading = false;
                _statusMessage =
                    'Sync completed: $total keys (BLE disconnected)';
              });

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '✓ Sync completed: $total keys | BLE disconnected',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          } else if (type == 'syncLockKeyError') {
            // Error occurred
            final message = event['message'] as String? ?? 'Unknown error';
            final code = event['code'];

            setState(() {
              _loading = false;
              _statusMessage = 'Error: $message (Connection closed)';
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '✗ Sync error: $message (code: $code) | Connection closed',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _loading = false;
            _statusMessage = 'Stream error: $error';
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Stream error: $error')));
        },
        onDone: () {
          if (!mounted) return;
          setState(() {
            if (_loading) {
              _loading = false;
              _statusMessage = 'Stream closed';
            }
          });
        },
      );

      // Trigger the sync operation (results come via stream)
      await _plugin.syncLockKey(widget.auth);
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
      setState(() {
        _loading = false;
        _statusMessage = 'Error: ${msg ?? e}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sync keys error: ${msg ?? e} (code: ${codeStr ?? status?.code})',
          ),
        ),
      );
    }
  }

  Future<void> _deleteKey(Map<String, dynamic> keyData) async {
    // Confirm deletion
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Key'),
        content: Text(
          'Are you sure you want to delete this key?\n\n'
          'Type: ${keyData['keyType']}\n'
          'ID: ${keyData['lockKeyId']}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _loading = true);

    try {
      // Extract key information from synced data
      final keyType = keyData['keyType'] as int? ?? 0;
      final lockKeyId = keyData['lockKeyId'] as int? ?? 0;

      // Create delete action using mode 0 (delete by key number)
      final deleteAction = DeleteLockKeyActionModel.byKeyNumber(
        keyType: keyType,
        keyId: lockKeyId,
      );

      // Validate before sending
      final errors = deleteAction.validate();
      if (errors.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Validation error: ${errors.first}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _loading = false);
        return;
      }

      // Call the delete method
      final response = await _plugin.deleteLockKey(widget.auth, deleteAction);

      if (!mounted) return;

      final success = response['success'] == true;
      final message = response['message'] ?? 'Unknown result';
      final code = response['code'];

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Key deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // Refresh the keys list
        await _syncKeys();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Delete failed: $message (code: $code)'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting key: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editKey(Map<String, dynamic> keyData) async {
    // Open the EditKeyScreen which allows changing password and validity.
    final res = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => EditKeyScreen(auth: widget.auth, keyData: keyData),
      ),
    );

    // If changes were made, refresh keys
    if (res != null && res.isNotEmpty) {
      await _syncKeys();
    }
  }

  Future<void> _toggleKeyEnabled(
    Map<String, dynamic> keyData,
    int index,
  ) async {
    final keyType = keyData['keyType'] as int? ?? 0;
    final currentValidNum =
        keyData['validNumber'] as int? ?? keyData['vaildNumber'] as int? ?? 255;

    // Determine new state: if currently enabled (>0), disable (0); if disabled, enable (255)
    final newValidNum = currentValidNum > 0 ? 0 : 255;
    final enabling = newValidNum > 0;

    setState(() {
      _togglingKey = true;
      _togglingKeyIndex = index;
    });

    try {
      final response = await _plugin.setKeyTypeEnabled(
        auth: widget.auth,
        keyTypeBitmask: keyType,
        validNumber: newValidNum,
      );

      if (!mounted) return;

      final success =
          response['success'] == true ||
          response['isSuccessful'] == true ||
          response['code'] == 0;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enabling ? 'Key type enabled' : 'Key type disabled'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        // Refresh keys to get updated state
        await _syncKeys();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to toggle key: ${response['message'] ?? response['ackMessage'] ?? response['code']}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error toggling key: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _togglingKey = false;
          _togglingKeyIndex = null;
        });
      }
    }
  }

  Future<void> _showAddKeySheet() async {
    // populate defaults similar to AddKeyScreen
    final AddLockKeyActionModel defaults = AddLockKeyActionModel();
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
          if (lastGroupId != null) defaults.addedKeyGroupId = lastGroupId;
        }
      }
    } catch (_) {}

    final res = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => AddLockKeyScreen(auth: widget.auth, defaults: defaults),
      ),
    );

    if (res != null) {
      await _persistKeyResult(res);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Add key ok')));
      }
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
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Sync Lock Keys'),
            actions: [
              InkWell(onTap: _syncKeys, child: Icon(Icons.sync)),
              SizedBox(width: 12),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Press Sync to retrieve keys from the lock using the plugin.',
                ),
                if (_loading || _statusMessage.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Card(
                    color: _loading
                        ? Colors.blue.shade50
                        : Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (_loading)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _statusMessage,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_chunksReceived > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Chunks received: $_chunksReceived | Keys so far: ${_partialKeys.length}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                Expanded(
                  child: _syncedKeys == null
                      ? const Center(child: Text('No keys yet'))
                      : _syncedKeys!.isEmpty
                      ? const Center(child: Text('No keys found'))
                      : ListView.builder(
                          itemCount: _syncedKeys!.length,
                          itemBuilder: (context, index) {
                            final keyData = _syncedKeys![index];
                            final pretty = const JsonEncoder.withIndent(
                              '  ',
                            ).convert(keyData);
                            final validNum =
                                keyData['validNumber'] as int? ??
                                keyData['vaildNumber'] as int? ??
                                255;
                            final isEnabled = validNum > 0;

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text('Key ${index + 1}'),
                                subtitle: Text(
                                  'Type: ${keyData['keyType'] ?? 'unknown'}, '
                                  'ID: ${keyData['lockKeyId'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Transform.scale(
                                      scale: 0.8,
                                      child: Switch(
                                        value: isEnabled,
                                        onChanged: _togglingKey
                                            ? null
                                            : (value) {
                                                _toggleKeyEnabled(
                                                  keyData,
                                                  index,
                                                );
                                              },
                                        activeColor: Colors.green,
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        if (value == 'edit') {
                                          await _editKey(keyData);
                                        } else if (value == 'delete') {
                                          await _deleteKey(keyData);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',

                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, size: 20),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                size: 20,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () async {
                                  await showDialog<void>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text('Key ${index + 1} Details'),
                                      content: SingleChildScrollView(
                                        child: SelectableText(pretty),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            await Clipboard.setData(
                                              ClipboardData(text: pretty),
                                            );
                                            if (ctx.mounted) {
                                              Navigator.of(ctx).pop();
                                            }
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Copied to clipboard',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text('Copy'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddKeySheet,
            child: const Icon(Icons.add),
          ),
        ),
        // Blur overlay when toggling key
        if (_togglingKey)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          _togglingKeyIndex != null
                              ? 'Toggling Key ${_togglingKeyIndex! + 1}...'
                              : 'Toggling Key...',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
