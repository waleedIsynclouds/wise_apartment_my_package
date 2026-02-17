import 'package:flutter/material.dart';
import 'package:wise_apartment/wise_apartment.dart';
import 'package:wise_apartment/src/models/keys/change_key_pwd_action_model.dart';
import 'package:wise_apartment/src/models/keys/modify_key_action_model.dart';

class EditKeyScreen extends StatefulWidget {
  final Map<String, dynamic> auth;
  final Map<String, dynamic> keyData;
  const EditKeyScreen({Key? key, required this.auth, required this.keyData})
    : super(key: key);

  @override
  State<EditKeyScreen> createState() => _EditKeyScreenState();
}

class _EditKeyScreenState extends State<EditKeyScreen> {
  final _plugin = WiseApartment();
  final _oldPwdController = TextEditingController();
  final _newPwdController = TextEditingController();
  DateTime? _validStart;
  DateTime? _validEnd;
  final _vaildNumberController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final ks = widget.keyData;
    try {
      final vs = ks['validStartTime'] as int? ?? 0;
      final ve = ks['validEndTime'] as int? ?? 0xFFFFFFFF;
      if (vs > 0) _validStart = DateTime.fromMillisecondsSinceEpoch(vs * 1000);
      if (ve > 0 && ve != 0xFFFFFFFF) {
        _validEnd = DateTime.fromMillisecondsSinceEpoch(ve * 1000);
      }
    } catch (_) {}
    final vn = ks['validNumber'] as int? ?? ks['vaildNumber'] as int? ?? 255;
    _vaildNumberController.text = vn.toString();
  }

  @override
  void dispose() {
    _oldPwdController.dispose();
    _newPwdController.dispose();
    _vaildNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _validStart ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() {
      _validStart = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickEnd() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _validEnd ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() {
      _validEnd = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final auth = widget.auth;
    final keyData = widget.keyData;
    final results = <String, dynamic>{};

    // 1) If new password provided -> change password
    final newPwd = _newPwdController.text.trim();
    final oldPwd = _oldPwdController.text.trim();
    if (newPwd.isNotEmpty) {
      if (oldPwd.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please provide current password to change it'),
            ),
          );
        }
        setState(() => _saving = false);
        return;
      }

      try {
        final change = ChangeKeyPwdActionModel(
          lockKeyId: keyData['lockKeyId'] as int? ?? 0,
          oldPassword: oldPwd,
          newPassword: newPwd,
          lockMac: auth['mac'] as String? ?? '',
        );

        final resp = await _plugin.changeLockKeyPwd(auth, change);
        results['changePwd'] = resp;
        final ok = resp['success'] == true || resp['isSuccessful'] == true;
        if (ok) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password changed successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Password change failed: ${resp['message'] ?? resp['ackMessage'] ?? resp}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password change error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    // 2) If validity changed -> call modifyLockKey
    try {
      final originalStart = (widget.keyData['validStartTime'] as int?) ?? 0;
      final originalEnd =
          (widget.keyData['validEndTime'] as int?) ?? 0xFFFFFFFF;
      final newStartSec = _validStart != null
          ? (_validStart!.millisecondsSinceEpoch ~/ 1000)
          : 0;
      final newEndSec = _validEnd != null
          ? (_validEnd!.millisecondsSinceEpoch ~/ 1000)
          : 0xFFFFFFFF;

      final vnum =
          int.tryParse(_vaildNumberController.text.trim()) ??
          (widget.keyData['validNumber'] as int? ?? 255);

      final changed =
          (newStartSec != originalStart) ||
          (newEndSec != originalEnd) ||
          (vnum !=
              (widget.keyData['validNumber'] as int? ??
                  widget.keyData['vaildNumber'] as int? ??
                  255));
      if (changed) {
        final modify = ModifyKeyActionModel.fromMap({
          'authorMode': widget.keyData['authMode'] as int? ?? 1,
          'changeMode': 1,
          'changeID': widget.keyData['lockKeyId'] as int? ?? 0,
          'validStartTime': newStartSec,
          'validEndTime': newEndSec,
          'vaildNumber': vnum,
        });

        // validate prior to sending
        final errors = modify.validate();
        if (errors.isNotEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Validation error: ${errors.first}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          final resp = await _plugin.modifyLockKey(auth, modify);
          results['modifyKey'] = resp;
          final ok = resp['success'] == true || resp['isSuccessful'] == true;
          if (ok) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Validity updated'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Modify failed: ${resp['message'] ?? resp['ackMessage'] ?? resp}',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Modify key error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _saving = false);
    Navigator.of(context).pop(results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Key')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Change password (optional)'),
            const SizedBox(height: 8),
            TextField(
              controller: _oldPwdController,
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _newPwdController,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
            const Divider(height: 24),
            const Text('Validity period (optional)'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _validStart == null
                        ? 'Start: (permanent or none)'
                        : 'Start: ${_validStart!.toLocal()}',
                  ),
                ),
                TextButton(onPressed: _pickStart, child: const Text('Pick')),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _validEnd == null
                        ? 'End: (permanent)'
                        : 'End: ${_validEnd!.toLocal()}',
                  ),
                ),
                TextButton(onPressed: _pickEnd, child: const Text('Pick')),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _vaildNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Valid times (0-255, 255 unlimited)',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}
