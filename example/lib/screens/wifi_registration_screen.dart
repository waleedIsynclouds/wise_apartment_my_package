import 'dart:async';
import 'dart:developer';

// ignore_for_file: unused_local_variable, unused_field, unnecessary_cast, unused_import, dead_code, unnecessary_null_comparison
import 'package:flutter/material.dart';
import 'package:wise_apartment/wise_apartment.dart';
import 'package:wise_apartment/src/models/wifi_registration_event.dart';
import 'package:wise_apartment_example/src/config.dart';
import '../src/wifi_config.dart';
import '../src/api_service.dart';
import 'package:wise_apartment/src/models/dna_info_model.dart';

class WifiRegistrationScreen extends StatefulWidget {
  final DnaInfoModel device;
  const WifiRegistrationScreen({Key? key, required this.device})
    : super(key: key);

  @override
  State<WifiRegistrationScreen> createState() => _WifiRegistrationScreenState();
}

class _WifiRegistrationScreenState extends State<WifiRegistrationScreen> {
  final _plugin = WiseApartment();
  bool _loading = false;
  StreamSubscription<Map<String, dynamic>>? _streamSubscription;
  StreamSubscription<Map<String, dynamic>>? _rfSignStreamSubscription;
  List<WifiRegistrationEvent> _events = [];
  WifiRegistrationEvent? _latestEvent;
  List<Map<String, dynamic>> _rfSignEvents = [];
  Map<String, dynamic>? _latestRfSignEvent;

  // WiFi config parametersd
  final _ssidController = TextEditingController(text: 'LAVUI_4G');
  final _passwordController = TextEditingController(text: 'Lavui@112');
  final _hostController = TextEditingController(
    text: ExampleConfig.defaultHost,
  );
  final _portController = TextEditingController(
    text: ExampleConfig.defaultPort,
  );

  // Configuration type and token update flag
  WifiConfigurationType _configurationType =
      WifiConfigurationType.wifiAndServer;
  bool _updateToken = true;

  @override
  void initState() {
    super.initState();
    // Listen to RF sign registration events
    // _setupRfSignRegistrationListener();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _rfSignStreamSubscription?.cancel();
    _ssidController.dispose();
    _passwordController.dispose();
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  // Note: WiFi/RF registration stream subscription is started when the
  // user initiates registration via `wifiRegistrationStreamWithArgs`.

  Color _getStatusColor(WifiRegistrationEvent? event) {
    if (event == null) return Colors.grey;
    if (event.isSuccess) return Colors.green;
    if (event.isError) return Colors.red;
    if (event.isProgress)
      return event.status == 0x04 ? Colors.lightBlue : Colors.blue;
    return Colors.orange;
  }

  IconData _getStatusIcon(WifiRegistrationEvent? event) {
    if (event == null) return Icons.help_outline;
    if (event.isSuccess) return Icons.check_circle;
    if (event.isError) return Icons.error;
    if (event.status == 0x04) return Icons.wifi;
    if (event.status == 0x02) return Icons.sync;
    return Icons.info;
  }

  Future<void> _startWifiRegistration() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _latestEvent = null;
      _events.clear();
    });

    try {
      // Build WifiConfig RF-code and pass device DNA map
      final defaultHost = ExampleConfig.defaultHost;
      final defaultPort = ExampleConfig.defaultPort;

      String tokenIdVal = '';
      if (_configurationType == null ||
          _configurationType != WifiConfigurationType.wifiOnly) {
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
          setState(() => _loading = false);
          return;
        }
        tokenIdVal = lockToken;
      }

      final serverAddrVal = _hostController.text.trim().isEmpty
          ? defaultHost
          : _hostController.text.trim();
      final serverPortVal = _portController.text.trim().isEmpty
          ? defaultPort
          : _portController.text.trim();

      final wifiModel = WifiConfig(
        ssid: _ssidController.text.trim(),
        password: _passwordController.text,
        serverAddress: serverAddrVal,
        serverPort: serverPortVal,
        configurationType: _configurationType,
        tokenId: tokenIdVal,
        updateToken: "02",
      );

      final rfCode = wifiModel.toRfCodeString();

      final dna = widget.device.toMap();
      log(
        'Subscribing to wifiRegistrationStreamWithArgs with RF code: $rfCode and DNA: $dna',
      );

      // Cancel any existing subscription and start a new stream subscription
      _streamSubscription?.cancel();
      _streamSubscription = _plugin
          .wifiRegistrationStreamWithArgs(rfCode, dna)
          .listen(
            (eventMap) {
              if (!mounted) return;

              final type = eventMap['type'] as String?;
              debugPrint('📩 EVENT RECEIVED: $type');
              debugPrint('   Event data: $eventMap');

              if (type == 'wifiRegistration') {
                // Parse event into typed model
                final event = WifiRegistrationEvent.fromMap(eventMap);

                debugPrint(
                  '   ${event.statusEmoji} Status: ${event.statusHex} - ${event.statusMessage}',
                );
                debugPrint('   Module MAC: ${event.moduleMac}');
                debugPrint('   Lock MAC: ${event.lockMac}');

                setState(() {
                  _latestEvent = event;
                  _events.insert(0, event);

                  // Auto-stop loading when we reach a terminal state
                  if (event.isTerminal) {
                    _loading = false;
                  }
                });

                if (mounted) {
                  final color = _getStatusColor(event);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${event.statusEmoji} ${event.statusMessage}',
                      ),
                      backgroundColor: color,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            onError: (error) {
              debugPrint('✗ WiFi registration stream error: $error');
              if (mounted) {
                setState(() {
                  _latestEvent = null;
                  _loading = false;
                });
              }
            },
          );
    } catch (e) {
      debugPrint('✗ WiFi registration failed: $e');

      if (mounted) {
        setState(() {
          _loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('WiFi registration error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearHistory() {
    setState(() {
      _events.clear();
      _latestEvent = null;
      _rfSignEvents.clear();
      _latestRfSignEvent = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi Registration Test'),
        actions: [
          if (_events.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearHistory,
              tooltip: 'Clear history',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          child: Column(
            children: [
              // Current Status Card
              Card(
                margin: const EdgeInsets.all(16),
                color: _getStatusColor(_latestEvent).withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getStatusIcon(_latestEvent),
                            size: 48,
                            color: _getStatusColor(_latestEvent),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Status',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _latestEvent?.statusMessage ?? 'Not started',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(_latestEvent),
                                      ),
                                ),
                                if (_latestEvent != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_latestEvent!.statusHex} • ${_latestEvent!.statusName}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (_loading) const CircularProgressIndicator(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // WiFi Configuration Form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WiFi Configuration',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _ssidController,
                      decoration: const InputDecoration(
                        labelText: 'WiFi SSID',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.wifi),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'WiFi Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _hostController,
                      decoration: const InputDecoration(
                        labelText: 'MQTT Host',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cloud),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _portController,
                      decoration: const InputDecoration(
                        labelText: 'MQTT Port',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _startWifiRegistration,
                        icon: Icon(
                          _loading
                              ? Icons.hourglass_empty
                              : Icons.wifi_tethering,
                        ),
                        label: Text(
                          _loading
                              ? 'Registering...'
                              : 'Start WiFi Registration',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // RF Sign Events Section (for debugging/testing)
              if (_rfSignEvents.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.settings_input_antenna,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'RF Sign Events (${_rfSignEvents.length})',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          if (_latestRfSignEvent != null) ...[
                            const Divider(),
                            Text(
                              'Latest: ${_latestRfSignEvent!['statusMessage']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'OperMode: 0x${(_latestRfSignEvent!['operMode'] as num).toInt().toRadixString(16).padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Module MAC: ${_latestRfSignEvent!['moduleMac']}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // Status History
              Expanded(
                child: _events.isEmpty
                    ? Center(
                        child: Text(
                          'No status updates yet.\nStart WiFi registration to see updates.',
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Status History (${_events.length})',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                TextButton.icon(
                                  onPressed: _clearHistory,
                                  icon: const Icon(Icons.clear_all, size: 16),
                                  label: const Text('Clear'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _events.length,
                              itemBuilder: (context, index) {
                                final event = _events[index];

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _getStatusColor(
                                        event,
                                      ).withOpacity(0.2),
                                      child: Icon(
                                        _getStatusIcon(event),
                                        color: _getStatusColor(event),
                                        size: 24,
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Text(event.statusEmoji),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(event.statusMessage),
                                        ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          '${event.statusHex} • ${event.statusName} • ${event.statusType}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'Time: ${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}:${event.timestamp.second.toString().padLeft(2, '0')}',
                                        ),
                                        if (event.moduleMac.isNotEmpty)
                                          Text('Module: ${event.moduleMac}'),
                                        if (event.lockMac.isNotEmpty)
                                          Text('Lock: ${event.lockMac}'),
                                      ],
                                    ),
                                    isThreeLine: true,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
