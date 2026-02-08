// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wise_apartment/wise_apartment.dart';

class AddLockKeyScreen extends StatefulWidget {
  final Map<String, dynamic> auth;
  final AddLockKeyActionModel defaults;
  const AddLockKeyScreen({
    super.key,
    required this.auth,
    required this.defaults,
  });

  @override
  State<AddLockKeyScreen> createState() => _AddLockKeyScreenState();
}

class _AddLockKeyScreenState extends State<AddLockKeyScreen> {
  final _plugin = WiseApartment();

  // Controllers for fields that exist on AddLockKeyActionModel
  final _addedKeyGroupIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _keyDataTypeController = TextEditingController();
  final _validModeController = TextEditingController();
  final _localRemoteModeController = TextEditingController();
  final _statusController = TextEditingController();
  final _keyIdController = TextEditingController();

  final _modifyTimestampController = TextEditingController();
  final _validStartController = TextEditingController();
  final _validEndController = TextEditingController();
  final _vaildNumberController = TextEditingController();
  final _weekController = TextEditingController();
  final _dayStartController = TextEditingController();
  final _dayEndController = TextEditingController();

  // map of controller -> listener so we can remove listeners cleanly
  final Map<TextEditingController, VoidCallback> _controllerListeners = {};

  // Validity segmented control: 0=Limit,1=Permanent,2=Cycle
  int _validitySegment = 2;
  int _currentUserType = 0; // 0=regular,1=admin
  bool _grantLocalMenuAccess = false;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _dailyStart;
  TimeOfDay? _dailyEnd;

  final Set<int> _selectedWeekDays = {}; // 1..7 (Mon..Sun)
  // Cycle validNumber choice: 0=disabled, 1=one-time, 255=unlimited, -1 means unset/custom
  int _vaildNumberChoice = -1;

  final List<MapEntry<int, String>> _keyTypeOptions = [
    MapEntry(2, 'Add password'),
    MapEntry(1, 'Add fingerprint'),
    MapEntry(4, 'Add card'),
    MapEntry(8, 'Add remote control'),
  ];
  int _selectedKeyOptionIndex = 0;
  late int authorMode;
  bool _adding = false;
  late AddLockKeyActionModel _actionModel;

  @override
  void initState() {
    super.initState();
    authorMode = widget.defaults.authorMode ?? 0;
    // create a working model instance for the whole screen
    _actionModel = AddLockKeyActionModel.fromMap(widget.defaults.toMap());
    _addedKeyGroupIdController.text = widget.defaults.addedKeyGroupId
        .toString();
    _passwordController.text = widget.defaults.password?.toString() ?? '';
    _validModeController.text = widget.defaults.vaildMode.toString();
    _localRemoteModeController.text = widget.defaults.localRemoteMode
        .toString();
    _statusController.text = widget.defaults.status.toString();
    _keyIdController.text = widget.defaults.addedKeyID.toString();
    _modifyTimestampController.text = widget.defaults.modifyTimestamp
        .toString();
    _validStartController.text = widget.defaults.validStartTime.toString();
    _validEndController.text = widget.defaults.validEndTime.toString();
    _vaildNumberController.text = widget.defaults.vaildNumber.toString();
    _weekController.text = widget.defaults.week.toString();
    _dayStartController.text = widget.defaults.dayStartTimes.toString();
    _dayEndController.text = widget.defaults.dayEndTimes.toString();

    // initialize vaildNumber choice from controller
    final vnInt = int.tryParse(_vaildNumberController.text) ?? 0;
    if (vnInt == 0) {
      _vaildNumberChoice = 0;
    } else if (vnInt == 1)
      _vaildNumberChoice = 1;
    else if (vnInt == 0xFF)
      _vaildNumberChoice = 0xFF;
    else
      _vaildNumberChoice = -1;

    final at = widget.defaults.addedKeyType;
    final idx = _keyTypeOptions.indexWhere((e) => e.key == at);
    if (idx != -1) _selectedKeyOptionIndex = idx;

    // attach simple listeners to controllers so changes trigger UI updates
    void _attach(TextEditingController c) {
      void _l() {
        if (mounted) setState(() {});
      }

      c.addListener(_l);
      _controllerListeners[c] = _l;
    }

    _attach(_addedKeyGroupIdController);
    _attach(_passwordController);
    _attach(_validModeController);
    _attach(_localRemoteModeController);
    _attach(_statusController);
    _attach(_modifyTimestampController);
    _attach(_validStartController);
    _attach(_validEndController);
    _attach(_vaildNumberController);
    _attach(_weekController);
    _attach(_dayStartController);
    _attach(_dayEndController);
    _attach(_keyIdController);
  }

  @override
  void dispose() {
    // remove listeners
    _controllerListeners.forEach((ctrl, l) {
      try {
        ctrl.removeListener(l);
      } catch (_) {}
    });
    _controllerListeners.clear();

    _addedKeyGroupIdController.dispose();
    _passwordController.dispose();
    _keyDataTypeController.dispose();
    _validModeController.dispose();
    _modifyTimestampController.dispose();
    _validStartController.dispose();
    _validEndController.dispose();
    _vaildNumberController.dispose();
    _weekController.dispose();
    _dayStartController.dispose();
    _dayEndController.dispose();
    _keyIdController.dispose();
    _localRemoteModeController.dispose();
    _statusController.dispose();

    super.dispose();
  }

  int? parseI(String? s) {
    if (s == null) return null;
    final t = s.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Lock Key'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top switches
              // SwitchListTile(
              //   title: const Text('App Auth'),
              //   value: _appAuth,
              //   onChanged: (v) => setState(() => _appAuth = v),
              // ),
              // SwitchListTile(
              //   title: Row(
              //     children: [
              //       const Text('Allow remote unlock'),
              //       const SizedBox(width: 6),
              //       Icon(Icons.help_outline, size: 16, color: Colors.grey[600]),
              //     ],
              //   ),
              //   value: _allowRemoteUnlock,
              //   onChanged: (v) => setState(() => _allowRemoteUnlock = v),
              // ),
              Text('Key Type '),
              DropdownButton<int>(
                items: _keyTypeOptions
                    .map(
                      (e) => DropdownMenuItem<int>(
                        value: e.key,
                        child: Text(e.value),
                      ),
                    )
                    .toList(),
                value: _keyTypeOptions[_selectedKeyOptionIndex].key,
                isExpanded: true,
                onChanged: (v) {
                  final idx = _keyTypeOptions.indexWhere((e) => e.key == v);
                  if (idx != -1) setState(() => _selectedKeyOptionIndex = idx);
                },
              ),
              const SizedBox(height: 8),

              // User and Cell No.
              SizedBox(
                height: 72,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _addedKeyGroupIdController,
                        decoration: InputDecoration(
                          labelText:
                              'User * ${_currentUserType == 0 ? 'Regular (2001-4095)' : '(Admin) (901-2000)'}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'User Type',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: _currentUserType,
                            items: const [
                              DropdownMenuItem(
                                value: 0,
                                child: Text('Regular'),
                              ),
                              DropdownMenuItem(value: 1, child: Text('Admin')),
                            ],
                            onChanged: (intv) {
                              setState(() {
                                _currentUserType = intv ?? 0;
                                _currentUserType == 0
                                    ? null
                                    : _addedKeyGroupIdController.text = '';
                                // reset local-menu grant when switching to regular
                                if (_currentUserType == 0)
                                  _grantLocalMenuAccess = false;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Key ID and local-menu access (admin only)
              if (_currentUserType == 1) ...[
                TextFormField(
                  controller: _keyIdController,
                  decoration: const InputDecoration(
                    labelText: 'Key ID (1-10 for local menu access)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Grant Local Menu Access'),
                  subtitle: const Text('Only key IDs 1..10 enable local menu'),
                  value: _grantLocalMenuAccess,
                  onChanged: (v) => setState(() => _grantLocalMenuAccess = v),
                ),
              ],
              const SizedBox(height: 8),
              // TextFormField(
              //   controller: _cellController,
              //   decoration: InputDecoration(
              //     labelText: 'Cell No. *',
              //     prefix: const Text('+1\u00A0'),
              //     suffixIcon: Icon(Icons.contact_phone_outlined),
              //   ),
              //   keyboardType: TextInputType.phone,
              // ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password (6-12 digits)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password is required";
                  }
                  if (value.length < 6 || value.length > 12) {
                    return "Password must be 6-12 digits";
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // Validity segmented control
              Text(
                'Validity period',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              CupertinoSegmentedControl<int>(
                groupValue: _validitySegment,
                children: const {
                  0: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Text('Limit'),
                  ),
                  1: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Text('one Time'),
                  ),
                  2: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Text('Permanent'),
                  ),
                  3: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Text('Cycle'),
                  ),
                },
                onValueChanged: (v) => setState(() {
                  _validitySegment = v;
                  // Note: segment 1 (one Time) requires start/end dates, so don't clear them
                  // Only segment 2 (Permanent) doesn't use dates
                }),
              ),

              const SizedBox(height: 12),

              if (_validitySegment != 2) ...[
                ListTile(
                  title: const Text('Start Time *'),
                  trailing: Text(
                    _startDate == null
                        ? 'Not set'
                        : _startDate!
                              .toLocal()
                              .toIso8601String()
                              .split('T')
                              .first,
                  ),
                  onTap: () async {
                    final now = DateTime.now();
                    final dt = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? now,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (dt != null)
                      setState(() {
                        _startDate = dt;
                        _actionModel.validStartTime =
                            AddLockKeyActionModel.dateTimeToEpochSeconds(dt);
                        _validStartController.text = _actionModel.validStartTime
                            .toString();
                      });
                  },
                ),
                ListTile(
                  title: const Text('End Time *'),
                  trailing: Text(
                    _endDate == null
                        ? 'Not set'
                        : _endDate!
                              .toLocal()
                              .toIso8601String()
                              .split('T')
                              .first,
                  ),
                  onTap: () async {
                    final now = DateTime.now();
                    final dt = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? now,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (dt != null)
                      setState(() {
                        _endDate = dt;
                        _actionModel.validEndTime =
                            AddLockKeyActionModel.dateTimeToEpochSeconds(dt);
                        _validEndController.text = _actionModel.validEndTime
                            .toString();
                      });
                  },
                ),

                // Limit-only: allow setting number of authorizations
                if (_validitySegment == 0) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Number of authorizations',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Disable'),
                        selected: _vaildNumberChoice == 0,
                        onSelected: (s) {
                          setState(() {
                            _vaildNumberChoice = s ? 0 : -1;
                            _vaildNumberController.text =
                                _vaildNumberChoice == -1
                                ? ''
                                : _vaildNumberChoice.toString();
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('1 time'),
                        selected: _vaildNumberChoice == 1,
                        onSelected: (s) {
                          setState(() {
                            _vaildNumberChoice = s ? 1 : -1;
                            _vaildNumberController.text =
                                _vaildNumberChoice == -1
                                ? ''
                                : _vaildNumberChoice.toString();
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Unlimited'),
                        selected: _vaildNumberChoice == 0xFF,
                        onSelected: (s) {
                          setState(() {
                            _vaildNumberChoice = s ? 0xFF : -1;
                            _vaildNumberController.text =
                                _vaildNumberChoice == -1
                                ? ''
                                : _vaildNumberChoice.toString();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ],

              const SizedBox(height: 8),
              if (_validitySegment == 3) ...[
                ListTile(
                  title: const Text('Daily start *'),
                  trailing: Text(
                    _dailyStart == null
                        ? 'All day'
                        : _dailyStart!.format(context),
                  ),
                  onTap: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime:
                          _dailyStart ?? const TimeOfDay(hour: 0, minute: 0),
                    );
                    if (t != null)
                      setState(() {
                        _dailyStart = t;
                        _actionModel.dayStartTimes = t.hour * 60 + t.minute;
                        _dayStartController.text = _actionModel.dayStartTimes
                            .toString();
                      });
                  },
                ),
                ListTile(
                  title: const Text('Daily end *'),
                  trailing: Text(
                    _dailyEnd == null ? 'All day' : _dailyEnd!.format(context),
                  ),
                  onTap: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime:
                          _dailyEnd ?? const TimeOfDay(hour: 23, minute: 59),
                    );
                    if (t != null)
                      setState(() {
                        _dailyEnd = t;
                        _actionModel.dayEndTimes = t.hour * 60 + t.minute;
                        _dayEndController.text = _actionModel.dayEndTimes
                            .toString();
                      });
                  },
                ),

                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Repeat *'),
                  trailing: Text(
                    _selectedWeekDays.isEmpty
                        ? 'Not set'
                        : '${_selectedWeekDays.length} days',
                  ),
                ),

                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(7, (i) {
                    final label = [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ][i];
                    final day = i + 1; // 1..7
                    final selected = _selectedWeekDays.contains(day);
                    return ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (s) => setState(() {
                        if (s) {
                          _selectedWeekDays.add(day);
                        } else {
                          _selectedWeekDays.remove(day);
                        }
                        _actionModel.week =
                            AddLockKeyActionModel.computeWeekMaskFromDays(
                              _selectedWeekDays,
                            );
                        _weekController.text = _actionModel.week.toString();
                      }),
                    );
                  }),
                ),
              ],

              const SizedBox(height: 20),

              if (_adding) const Center(child: CircularProgressIndicator()),

              // Add button styled to match image
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: _adding
                      ? null
                      : () async {
                          // Sync UI-specific fields into model-related controllers before submission
                          if (_startDate != null) {
                            _validStartController.text =
                                (_startDate!.millisecondsSinceEpoch ~/ 1000)
                                    .toString();
                          }
                          if (_endDate != null) {
                            _validEndController.text =
                                (_endDate!.millisecondsSinceEpoch ~/ 1000)
                                    .toString();
                          }
                          if (_dailyStart != null) {
                            _dayStartController.text =
                                (_dailyStart!.hour * 60 + _dailyStart!.minute)
                                    .toString();
                          }
                          if (_dailyEnd != null) {
                            _dayEndController.text =
                                (_dailyEnd!.hour * 60 + _dailyEnd!.minute)
                                    .toString();
                          }
                          if (_selectedWeekDays.isNotEmpty) {
                            int mask = 0;
                            // Map Mon..Sun to bits 0..6
                            for (final d in _selectedWeekDays) {
                              mask |= (1 << (d - 1));
                            }
                            _weekController.text = mask.toString();
                          }

                          // keep the rest of the existing submission/validation logic
                          if (_selectedKeyOptionIndex < 0 ||
                              _selectedKeyOptionIndex >=
                                  _keyTypeOptions.length) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please select a valid key type',
                                  ),
                                ),
                              );
                            }
                            return;
                          }

                          final int chosenKeyType =
                              _keyTypeOptions[_selectedKeyOptionIndex].key;
                          final String selectedLabel =
                              _keyTypeOptions[_selectedKeyOptionIndex].value;

                          final password = _passwordController.text.trim();
                          if (password.isNotEmpty &&
                              (password.length < 6 || password.length > 12)) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Password must be 6-12 digits'),
                                ),
                              );
                            }
                            return;
                          }

                          // determine vaildNumber according to selection rules:
                          // 0x01 -> one time, 0xFF -> unlimited, 0x00 -> disable
                          int computedVn;
                          if (_validitySegment == 1) {
                            // one time
                            computedVn = 0x01;
                          } else if (_validitySegment == 2 ||
                              _validitySegment == 3) {
                            // permanent or cycle -> unlimited
                            computedVn = 0xFF;
                          } else {
                            // Limit: honor choice chips or fallback to typed value
                            if (_vaildNumberChoice == 0)
                              computedVn = 0x00;
                            else if (_vaildNumberChoice == 1)
                              computedVn = 0x01;
                            else if (_vaildNumberChoice == 0xFF)
                              computedVn = 0xFF;
                            else
                              computedVn =
                                  parseI(_vaildNumberController.text) ?? 0;
                          }

                          // Sync final model fields from UI into the persistent screen model
                          _actionModel.password = password.isNotEmpty
                              ? password
                              : null;
                          _actionModel.addedKeyType = chosenKeyType;
                          _actionModel.addedKeyID = 0;
                          _actionModel.addedKeyGroupId =
                              parseI(_addedKeyGroupIdController.text) ??
                              _actionModel.addedKeyGroupId;
                          _actionModel.modifyTimestamp =
                              parseI(_modifyTimestampController.text) ??
                              _actionModel.modifyTimestamp;
                          _actionModel.localRemoteMode =
                              parseI(_localRemoteModeController.text) ??
                              _actionModel.localRemoteMode;
                          _actionModel.status =
                              parseI(_statusController.text) ??
                              _actionModel.status;
                          _actionModel.authorMode =
                              ((selectedLabel.toLowerCase().contains(
                                    'password',
                                  ) ||
                                  selectedLabel.toLowerCase().contains(
                                    'card number',
                                  ))
                              ? 1
                              : 0);

                          // If admin requested local-menu access, validate and set addedKeyID
                          if (_currentUserType == 1 && _grantLocalMenuAccess) {
                            final kid = parseI(_keyIdController.text);
                            if (kid == null || kid < 1 || kid > 10) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Key ID for local menu must be 1..10',
                                    ),
                                  ),
                                );
                              }
                              return;
                            }
                            try {
                              _actionModel.setKeyIdForLocalMenu(kid);
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Invalid key id: $e')),
                                );
                              }
                              return;
                            }
                          } else {
                            // if not granting local menu, clear addedKeyID unless user typed a value
                            final kid = parseI(_keyIdController.text) ?? 0;
                            _actionModel.addedKeyID = kid;
                          }

                          // apply validity helpers according to selected segment
                          if (_validitySegment == 2) {
                            _actionModel.applyPermanent(
                              groupId: _actionModel.addedKeyGroupId > 0
                                  ? _actionModel.addedKeyGroupId
                                  : null,
                            );
                          } else if (_validitySegment == 1) {
                            _actionModel.applyOneTime(
                              start: _startDate,
                              end: _endDate,
                              groupId: _actionModel.addedKeyGroupId > 0
                                  ? _actionModel.addedKeyGroupId
                                  : null,
                            );
                          } else if (_validitySegment == 3) {
                            final ds = _dailyStart == null
                                ? 0
                                : (_dailyStart!.hour * 60 +
                                      _dailyStart!.minute);
                            final de = _dailyEnd == null
                                ? 1439
                                : (_dailyEnd!.hour * 60 + _dailyEnd!.minute);
                            _actionModel.applyCycle(
                              days: _selectedWeekDays,
                              dailyStartMinutes: ds,
                              dailyEndMinutes: de,
                              start: _startDate,
                              end: _endDate,
                            );
                          } else {
                            final vn = (_vaildNumberChoice == -1)
                                ? (parseI(_vaildNumberController.text) ??
                                      _actionModel.vaildNumber)
                                : _vaildNumberChoice;
                            _actionModel.applyLimit(
                              vaildNumberVal: vn,
                              start: _startDate,
                              end: _endDate,
                            );
                          }

                          final actionModel = _actionModel;

                          // Validate user ID range
                          final userIdInt = parseI(
                            _addedKeyGroupIdController.text,
                          );
                          if (userIdInt != null) {
                            final userIdError = validateUserID(userIdInt);
                            if (userIdError != null) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(userIdError)),
                                );
                              }
                              return;
                            }
                          }

                          // Use model's validation instead of duplicating logic
                          try {
                            actionModel.validateOrThrow(
                              authMode: actionModel.authorMode,
                            );
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Validation error: $e')),
                              );
                            }
                            return;
                          }

                          setState(() => _adding = true);
                          final map = actionModel.toMap();
                          try {
                            log('Adding lock key with action model: $map');
                            final res = await _plugin.addLockKey(
                              widget.auth,
                              map,
                            );
                            if (!mounted) return;
                            Navigator.of(
                              context,
                            ).pop(Map<String, dynamic>.from(res));
                          } catch (e) {
                            String? codeStr;
                            String? msg;
                            if (e is WiseApartmentException) {
                              codeStr = e.code;
                              msg = e.message;
                            }
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Add key error: ${msg ?? e} (code: ${codeStr ?? ''})',
                                  ),
                                ),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _adding = false);
                          }
                        },
                  child: const Text(
                    'Add',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Advanced: show raw model fields for debugging / advanced users (collapsible)
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  String? validateUserID(int value) {
    if (_currentUserType == 0) {
      //user 2001~4095 Regular User
      if (value < 2001 || value > 4095) {
        return 'User ID for Regular User must be between 2001 and 4095';
      }
    } else {
      //Admin 901~2000 Regular Administrator
      if (value < 901 || value > 2000) {
        return 'User ID for Regular Administrator must be between 901 and 2000';
      }
    }
    return null;
  }
}
