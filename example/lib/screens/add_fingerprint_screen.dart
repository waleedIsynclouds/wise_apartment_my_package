import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wise_apartment/wise_apartment.dart';

class AddFingerprintScreen extends StatefulWidget {
  final Map<String, dynamic> auth;
  final int defaultKeyGroupId;

  const AddFingerprintScreen({
    super.key,
    required this.auth,
    this.defaultKeyGroupId = 901,

    required DnaInfoModel device,
  });

  @override
  State<AddFingerprintScreen> createState() => _AddFingerprintScreenState();
}

class _AddFingerprintScreenState extends State<AddFingerprintScreen> {
  final _plugin = WiseApartment();
  final _keyGroupIdController = TextEditingController();

  // Use AddLockKeyActionModel for validation and parameter management
  late AddLockKeyActionModel _actionModel;

  // Validity type: 0=Permanent, 1=Custom period, 2=Recurring cycle
  int _validityType = 0;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _dailyStart;
  TimeOfDay? _dailyEnd;
  final Set<int> _selectedWeekDays = {1, 2, 3, 4, 5, 6, 7}; // Mon-Sun

  bool _isAdding = false;
  String _statusMessage = '';
  double _progress = 0.0;

  // Sample Base64 fingerprint data (replace with actual scanner data)
  final String _sampleFingerprintData =
      "EgYAAFAgiVBCTVQAA/8BAQAVBQwDAAAH+AAAAgEA/wAAAAAAAAAAAAAAAQBDAAACFH8uggIPoVKBSCYzjBhCjyZLTzFHjDEjhA89cEA2uUsxeTMRZz4RgQ4NqUYNvQoijAgwTwgYTkBIb0NPbkFCrz0NZB4diDoQpUQInTgQhDkOfZIGAUBCAD29ooIBt4IcmOwV4fTk5eXT08bEs6Ojk4SEc2ZFRTMjJCMTE8GCAY0MAA4ADgAAAAA+iDlvRXJGdFJiY2JqhQAAAACHipaHlHsAAClcMW81bDx1RHpVeF2KY5MAAAAAAACVipmLAAAAAC6fLH42eD2DRoxWh1pHYkd8gZGCmo+figAAAAAllymMMYU1lD+MS4xWgWdmfXWRgZuBpYUAAAAAIJIihCeKMZ04jEGGU4JnfX10knWoealyAAAAABqHGX0ZeC2BM4Q0elWDZm1/bZNyqnGvewAAFHkWghuCHXwjhSl5MWxIYF5kfV+SXqt5sHgAABSCFoIWfhWCFX8lhTBmO15NYHtbmF27Ub2LAAAPdw6ABncOgxBrImIrYixlPl1kRqlxwoHDgwAAC34RdgF1B4YOahRlG1wibDZYW0m1c8140XsAAAAA9oj5ZQRnBXQPaRVlG3gxaVlNynDUgdh6AAAAAAGB92b+Zv91Em0UZyZLLWxFV+Nk3oDjggAAAXT/ef1g+WT5dC5nI2AvZiFm5j/jW+x77H0AAAAA/Xb2Xfhi+nQ6WzJoKkseXSFc8mL9dfp3wwYBqACoAFEAAAACAEMAAAHofy6CAeOhMYEnDiyEDk6LKTa4HT65FQSiOSW5AjuLIxR+JBGhCwOmRh9bQwd9BwWEkgYBQB4ASL2iggGsghGY7BXh4+XDxcTDxbOzRCMTFMGCAY0MAA4ADkxuVUVqnn45sEiDnXhBj4CXfp1/pYIAAAAAAABQbWCCZnxsem9shXuPf5SDmn6cgaKCAAAAAAAAUXRcfGGIb4leQAAAj4mUiJ+Bon6mgppnAAAAABQ5VZNdjGuWdpl1gpaVmYWgiaSHqoKqgwAAAABCk06QWY5dUXFlh4SWiZ2RopCkkamKp4YAAAAAPJREjU+AYXVvdYd2mn6mdq13nWyungAAAAAAADeLO4NEhmN/cnSIcp9wq3q1dL2CuY27jQAAAAAtezB0SVxdaXJpg2Smd7B4un+/eMN7wXjAfAAAI4Qzcj1jT2NrYIdeoVy5h8B7y3/HcstrwVMAACJILWYwYz9gX0+LWb51vonEisyGzG/KcNRcAAAZXyBfJmY1YVpKrnHBe8180YjTitZ522mXOgAAEmcWYRxvMGlHWadd0H/UdNNt2orch9xx2HIAABNtF2cfhy5vQlmUW9h323rhbOZ/3YPffOFeAAAqaxxlKVcrcDti4FnleeV46nvpdeh84n4AAAAAwwYBqACoAFIAAAADAEMAAAHYfy6CAdOhI4EhE0+LBz2LEy6EDgaCPyV5KU6iLji4JEC4HwRdKROkKBSCooIBqoIPmOwV4fXk49TDxMTFEhITwYIBjQwADgAOSXNPbllQbZ9zo3qbhJaGiZCFlYOghgAAAAAAAEpyTmlmaWWAb3ttb4mBkIeUg5t8oYGniQAAAABJdlB1YG1lg2+EcnaGgpKElYCdgqGBpoIAAAAAQX9Ri1uTYZVumXiZipuVlJmHoYyjgaqDn3EAAEGNRplUjVyNX1F3TI6Jl42ekqGNqIyrh6iEAAAzlD2QSY5UiWNweHWOfZuCpH+ng6KHp5UAAAAANaI3kz+FSYhlgnl1j3Gld6l4tXa8h7WUuZUAACqHL4Ezdk1YYWx6a41uqHaxeb16vnnAgL6BAAAghSaBM3BDYlhkemCHXapvuYO/gMZ8x3PIbMpyFH4kiS9nNmFHYWlbmFu/YL6PxX7OfsxszGzRWRFrHWElYCpoOmFjRq12wYDIgM6Q0YnRcrA9AAAKahFlF2EfcTVfWk22a9F503TUitmI3H/fcdVoBHcRbRdnGYAxa0dXnF7Ygdl44mrfhtuG3W7aaP96FHsYZSVTLG5BXJlg3X/keup86Hbnfud563fDBgGoAKgAVo1fUXdMjomXjZ6SoY2ojKuHqIQAADOUPZBJjlSJY3B4dY59m4Kkf6eDooenlQAAAAA1ojeTP4VJiGWCeXWPcaV3qXi1dryHtZS5lQAAKocvgTN2TVhhbHprjW6odrF5vXq+ecCAvoEAACCFJoEzcENiWGR6YIddqm+5g7+AxnzHc8hsynIUfiSJL2c2YUdhaVuYW79gvo/Ffs5+zGzMbNFZEWsdYSVgKmg6YWNGrXbBgMiAzpDRidFysD0AAApqEWUXYR9xNV9aTbZr0XnTdNSK2Yjcf99x1WgEdxFtF2cZgDFrR1ecXtiB2Xjiat+G24bdbtpo/3oUexhlJVMsbkFcmWDdf+R66nzodud+53nrd8MGAagAqABWU4owAAAAAAAAAHhuACASBgAAUAAAAAAAAAABAAAAAAAAAD1jAAB4bgAguUsAAB2CIX30gQEAAAAAAP////8A4QAAAAAAADJNgAABAAAAZAAAZAAKFAAABQHwMk0AAAAAAAAAAAAAAAAAAAAAWqVapfnwMk358DJN+fAyTfnwMk358DJN+fAyTfnwMk358DJN+fAyTfnwMk358DJN+fAyTfnwMk358DJN+fAyTfnwMk358DJN+fAyTfnwMk358DJN+fAyTfnwMk358DJN+fA=";

  @override
  void initState() {
    super.initState();
    _keyGroupIdController.text = widget.defaultKeyGroupId.toString();

    // Initialize action model for fingerprint (authorMode=0, addedKeyType=fingerprint)
    _actionModel = AddLockKeyActionModel(
      authorMode: 0, // Enter fingerprint reading mode
      addedKeyType: AddLockKeyActionModel.addedFingerprint, // Fingerprint = 1
      addedKeyGroupId: widget.defaultKeyGroupId,
      localRemoteMode: 1,
      status: 0,
    );

    // Apply permanent validity by default
    _actionModel.applyPermanent(groupId: widget.defaultKeyGroupId);
  }

  @override
  void dispose() {
    _keyGroupIdController.dispose();
    super.dispose();
  }

  int _parseGroupId() {
    final val =
        int.tryParse(_keyGroupIdController.text) ?? widget.defaultKeyGroupId;
    if (val < 900 || val > 4095) return widget.defaultKeyGroupId;
    return val;
  }

  Future<void> _startAddFingerprint() async {
    if (_isAdding) return;

    setState(() {
      _isAdding = true;
      _statusMessage = 'Initializing...';
      _progress = 0.0;
    });

    try {
      // Update group ID from text field
      final keyGroupId = _parseGroupId();
      _actionModel.addedKeyGroupId = keyGroupId;

      // Apply validity settings based on selected type
      if (_validityType == 0) {
        // Permanent
        _actionModel.applyPermanent(groupId: keyGroupId);
      } else if (_validityType == 1) {
        // Custom period (one-time or limited period with unlimited uses)
        final start = _startDate ?? DateTime.now();
        final end = _endDate ?? DateTime.now().add(const Duration(days: 30));
        // Use unlimited uses (0xFF) for custom period
        _actionModel.validStartTime = (start.millisecondsSinceEpoch ~/ 1000);
        _actionModel.validEndTime = (end.millisecondsSinceEpoch ~/ 1000);
        _actionModel.vaildNumber = 0xFF;
        _actionModel.vaildMode = 0; // Single validity window
        _actionModel.week = 0;
        _actionModel.dayStartTimes = 0;
        _actionModel.dayEndTimes = 0;
      } else {
        // Recurring cycle
        final dailyStartMinutes =
            (_dailyStart?.hour ?? 9) * 60 + (_dailyStart?.minute ?? 0);
        final dailyEndMinutes =
            (_dailyEnd?.hour ?? 21) * 60 + (_dailyEnd?.minute ?? 0);

        _actionModel.applyCycle(
          days: _selectedWeekDays,
          dailyStartMinutes: dailyStartMinutes,
          dailyEndMinutes: dailyEndMinutes,
          start: DateTime.now(),
          end: DateTime.now().add(const Duration(days: 365)),
        );
      }

      // Validate the action model before sending
      try {
        _actionModel.validateOrThrow(authMode: _actionModel.authorMode);
      } catch (e) {
        setState(() {
          _isAdding = false;
          _statusMessage = 'Validation error: $e';
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Validation failed: $e')));
        }
        return;
      }

      // Build request with validated params
      final request = {
        ...widget.auth,
        'fingerprintData': _sampleFingerprintData,
        'keyGroupId': _actionModel.addedKeyGroupId,
        'keyType': _actionModel.addedKeyType,
        // Include all validated time params from action model
        'authMode': _actionModel.authorMode ?? 0,
        'validStartTime': _actionModel.validStartTime,
        'validEndTime': _actionModel.validEndTime,
        'validNumber': _actionModel.vaildNumber,
        'weeks': _actionModel.week,
        'dayStartTimes': _actionModel.dayStartTimes,
        'dayEndTimes': _actionModel.dayEndTimes,
        'vaildMode': _actionModel.vaildMode,
      };

      log('[AddFingerprintScreen] Starting fingerprint addition: $request');

      // Start listening to the stream
      final stream = _plugin.addFingerprintKeyStream;
      final streamSubscription = stream.listen(
        (event) {
          log('[AddFingerprintScreen] Stream event: $event');

          final type = event['type'] as String?;
          final message = event['message'] as String? ?? '';
          final progress = (event['progress'] as num?)?.toDouble() ?? 0.0;

          setState(() {
            _statusMessage = message;
            _progress = progress;
          });

          if (type == 'addLockKeyDone') {
            // Success!
            setState(() {
              _isAdding = false;
              _statusMessage = 'Fingerprint added successfully!';
              _progress = 1.0;
            });

            // Navigate back after delay
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.of(context).pop(true); // Return success
              }
            });
          } else if (type == 'addLockKeyError') {
            // Error
            setState(() {
              _isAdding = false;
              _statusMessage = 'Error: $message';
            });
          }
        },
        onError: (error) {
          log('[AddFingerprintScreen] Stream error: $error');
          setState(() {
            _isAdding = false;
            _statusMessage = 'Error: $error';
          });
        },
      );

      // Start the stream operation
      await _plugin.startAddFingerprintKeyStream(request);
    } catch (e) {
      log('[AddFingerprintScreen] Exception: $e');
      setState(() {
        _isAdding = false;
        _statusMessage = 'Exception: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Fingerprint'), centerTitle: true),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding:  const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fingerprint icon
              const Icon(Icons.fingerprint, size: 80, color: Colors.blue),
              const SizedBox(height: 24),

              // User ID input
              TextField(
                controller: _keyGroupIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID (900-4095)',
                  border: OutlineInputBorder(),
                  helperText: 'Enter a unique user ID for this fingerprint',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Validity type selector
              const Text(
                'Validity Type:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Permanent'),
                    selected: _validityType == 0,
                    onSelected: (selected) {
                      if (selected) setState(() => _validityType = 0);
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Custom Period'),
                    selected: _validityType == 1,
                    onSelected: (selected) {
                      if (selected) setState(() => _validityType = 1);
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Recurring'),
                    selected: _validityType == 2,
                    onSelected: (selected) {
                      if (selected) setState(() => _validityType = 2);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Validity configuration based on type
              if (_validityType == 1) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _startDate != null
                              ? '${_startDate!.year}-${_startDate!.month}-${_startDate!.day}'
                              : 'Start Date',
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) setState(() => _startDate = date);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _endDate != null
                              ? '${_endDate!.year}-${_endDate!.month}-${_endDate!.day}'
                              : 'End Date',
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate:
                                _startDate?.add(const Duration(days: 30)) ??
                                DateTime.now().add(const Duration(days: 30)),
                            firstDate: _startDate ?? DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 730),
                            ),
                          );
                          if (date != null) setState(() => _endDate = date);
                        },
                      ),
                    ),
                  ],
                ),
              ] else if (_validityType == 2) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          _dailyStart != null
                              ? '${_dailyStart!.hour}:${_dailyStart!.minute.toString().padLeft(2, '0')}'
                              : 'Daily Start',
                        ),
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: const TimeOfDay(hour: 9, minute: 0),
                          );
                          if (time != null) setState(() => _dailyStart = time);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          _dailyEnd != null
                              ? '${_dailyEnd!.hour}:${_dailyEnd!.minute.toString().padLeft(2, '0')}'
                              : 'Daily End',
                        ),
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: const TimeOfDay(hour: 21, minute: 0),
                          );
                          if (time != null) setState(() => _dailyEnd = time);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: [
                    for (int day = 1; day <= 7; day++)
                      FilterChip(
                        label: Text(
                          [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun',
                          ][day - 1],
                        ),
                        selected: _selectedWeekDays.contains(day),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedWeekDays.add(day);
                            } else {
                              _selectedWeekDays.remove(day);
                            }
                          });
                        },
                      ),
                  ],
                ),
              ],

              const Spacer(),

              // Progress indicator
              if (_isAdding) ...[
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 8),
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  '${(_progress * 100).toStringAsFixed(0)}%',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ] else ...[
                if (_statusMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: _statusMessage.contains('success')
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
              ],

              const SizedBox(height: 16),

              // Add button
              ElevatedButton.icon(
                icon: _isAdding
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.fingerprint),
                label: Text(
                  _isAdding ? 'Adding Fingerprint...' : 'Add Fingerprint',
                ),
                onPressed: _isAdding ? null : _startAddFingerprint,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
