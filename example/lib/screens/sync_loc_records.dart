// ignore_for_file: unused_local_variable, unused_field, unnecessary_cast, unused_import, dead_code
import 'package:flutter/material.dart';
import 'package:wise_apartment/wise_apartment.dart';
import 'package:flutter/services.dart';
import 'package:wise_apartment/src/wise_status_store.dart';
import 'dart:async';

class SyncLocRecordsScreen extends StatefulWidget {
  final Map<String, dynamic> auth;

  const SyncLocRecordsScreen({Key? key, required this.auth}) : super(key: key);

  @override
  State<SyncLocRecordsScreen> createState() => _SyncLocRecordsScreenState();
}

class _SyncLocRecordsScreenState extends State<SyncLocRecordsScreen> {
  final _plugin = WiseApartment();
  final List<HXRecordBaseModel> _records = [];
  bool _loading = false;
  bool _syncing = false;
  int _total = 0;
  String? _errorMessage;
  StreamSubscription<Map<String, dynamic>>? _streamSubscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startSync() async {
    if (_syncing) return;

    setState(() {
      _syncing = true;
      _loading = true;
      _records.clear();
      _errorMessage = null;
      _total = 0;
    });

    try {
      // Cancel any existing subscription
      await _streamSubscription?.cancel();

      // Start listening to the stream
      _streamSubscription = _plugin.syncLockRecordsStream.listen(
        (event) {
          if (!mounted) return;

          final String type = event['type'] ?? '';
          debugPrint('Received event: $type');

          switch (type) {
            case 'syncLockRecordsChunk':
              _handleChunk(event);
              break;
            case 'syncLockRecordsDone':
              _handleDone(event);
              break;
            case 'syncLockRecordsError':
              _handleError(event);
              break;
            default:
              debugPrint('Unknown event type: $type');
          }
        },
        onError: (error) {
          if (!mounted) return;
          debugPrint('Stream error: $error');
          setState(() {
            _errorMessage = 'Stream error: $error';
            _loading = false;
            _syncing = false;
          });
        },
        onDone: () {
          if (!mounted) return;
          debugPrint('Stream completed');
          setState(() {
            _loading = false;
            _syncing = false;
          });
        },
      );

      // Trigger the sync by calling the method (which returns immediately)
      await _plugin.syncLockRecords(widget.auth, 1);
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error starting sync: $e');

      String? codeStr;
      String? msg;
      if (e is WiseApartmentException) {
        codeStr = e.code;
        msg = e.message;
      } else if (e is PlatformException) {
        codeStr = e.code;
        msg = e.message;
      }

      setState(() {
        _errorMessage = 'Sync error: ${msg ?? e} (code: $codeStr)';
        _loading = false;
        _syncing = false;
      });
    }
  }

  void _handleChunk(Map<String, dynamic> event) {
    final List<dynamic> items = event['items'] ?? [];
    final int totalSoFar = event['totalSoFar'] ?? 0;
    final bool isMore = event['isMore'] ?? false;

    debugPrint(
      'Chunk received: ${items.length} records, totalSoFar: $totalSoFar, isMore: $isMore',
    );

    // Convert platform Maps -> LockRecord -> HXRecordBaseModel
    final locks = LockRecord.listFromDynamic(items);
    final typed = locks.map((l) => hxRecordFromLockRecord(l)).toList();

    setState(() {
      _records.addAll(typed);
      // Keep loading indicator if more data is coming
      _loading = isMore;
    });
  }

  void _handleDone(Map<String, dynamic> event) {
    final List<dynamic> items = event['items'] ?? [];
    final int total = event['total'] ?? 0;

    debugPrint('Sync complete: $total records');

    setState(() {
      _total = total;
      _loading = false;
      _syncing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync complete! Received $total records'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _handleError(Map<String, dynamic> event) {
    final String message = event['message'] ?? 'Unknown error';
    final int code = event['code'] ?? -1;

    debugPrint('Sync error: $message (code: $code)');

    setState(() {
      _errorMessage = '$message (code: $code)';
      _loading = false;
      _syncing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync failed: $message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildRecordTile(HXRecordBaseModel r) {
    final map = r.toMap();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r.modelType.isNotEmpty ? r.modelType : r.typeName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...map.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text('${e.key}: ${e.value}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Loc Records (Stream)'),
        actions: [
          IconButton(
            onPressed: _syncing ? null : _startSync,
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              color: Colors.red.shade100,
              padding: const EdgeInsets.all(12),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade900),
              ),
            ),
          if (_total > 0 || _records.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Records: ${_records.length}${_total > 0 ? ' / $_total' : ''}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          if (_records.isEmpty && !_loading && !_syncing)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.list, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No records yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _startSync,
                      icon: const Icon(Icons.sync),
                      label: const Text('Start Sync'),
                    ),
                  ],
                ),
              ),
            ),
          if (_records.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _records.length,
                itemBuilder: (context, index) =>
                    _buildRecordTile(_records[index]),
              ),
            ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Syncing records...'),
                ],
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
