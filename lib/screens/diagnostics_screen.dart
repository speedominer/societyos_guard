import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/telemetry_service.dart';

class DiagnosticsScreen extends ConsumerStatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen> {
  List<Map<String, dynamic>> _events = [];
  StreamSubscription<List<Map<String, dynamic>>>? _sub;

  @override
  void initState() {
    super.initState();
    // initialize persistence and load existing telemetry (best-effort)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await telemetryService.init();
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _events = telemetryService.recent();
      });
    });

    _sub = telemetryService.stream.listen((list) {
      if (!mounted) return;

      setState(() {
        _events = List<Map<String, dynamic>>.from(list);
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  int _count(String name) {
    return _events.where((event) => event['name'] == name).length;
  }

  void _clearEvents() {
    setState(() {
      _events = [];
    });
    // also clear persisted events
    try {
      telemetryService.clearPersistent();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final retryCount = _count('auto_retry_attempt');
    final manualRetryCount = _count('manual_retry');
    final failureCount = _count('connect_failed') +
        _count('connection_error') +
        _count('connection_closed');
    final successCount =
        _count('connect_success') + _count('reconnect_success');
    final authErrorCount =
        _count('auth_error_received') + _count('auth_error_on_err');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: 'Export telemetry',
            onPressed: _events.isEmpty
                ? null
                : () async {
                    final path = await telemetryService.export();
                    if (!mounted) return;
                    if (path != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Telemetry exported to: $path')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to export telemetry')));
                    }
                  },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear telemetry',
            onPressed: _events.isEmpty ? null : _clearEvents,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildSummary(
              retryCount: retryCount,
              manualRetryCount: manualRetryCount,
              failureCount: failureCount,
              successCount: successCount,
              authErrorCount: authErrorCount,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Telemetry Events',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('${_events.length} events'),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _events.isEmpty
                  ? const Center(
                      child: Text('No telemetry events recorded.'),
                    )
                  : ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final event = _events[_events.length - 1 - index];

                        final name = event['name']?.toString() ?? '';
                        final timestamp = event['ts']?.toString() ?? '';
                        final details = event['details']?.toString() ?? '{}';

                        return Card(
                          child: ListTile(
                            leading: Icon(
                              _iconForEvent(name),
                              color: _colorForEvent(name),
                            ),
                            title: Text(name),
                            subtitle: Text(
                              '$timestamp\n$details',
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
    );
  }

  Widget _buildSummary({
    required int retryCount,
    required int manualRetryCount,
    required int failureCount,
    required int successCount,
    required int authErrorCount,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _statChip(
              'Success',
              successCount,
              Colors.green,
            ),
            _statChip(
              'Retries',
              retryCount,
              Colors.orange,
            ),
            _statChip(
              'Manual',
              manualRetryCount,
              Colors.blue,
            ),
            _statChip(
              'Failures',
              failureCount,
              Colors.red,
            ),
            _statChip(
              'Auth',
              authErrorCount,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(
    String label,
    int value,
    Color color,
  ) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color,
        child: Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
          ),
        ),
      ),
      label: Text(label),
    );
  }

  IconData _iconForEvent(String name) {
    if (name.contains('auth')) {
      return Icons.lock_outline;
    }

    if (name.contains('retry')) {
      return Icons.refresh;
    }

    if (name.contains('failed') ||
        name.contains('error') ||
        name.contains('closed')) {
      return Icons.error_outline;
    }

    if (name.contains('success')) {
      return Icons.check_circle_outline;
    }

    return Icons.info_outline;
  }

  Color _colorForEvent(String name) {
    if (name.contains('auth')) {
      return Colors.purple;
    }

    if (name.contains('retry')) {
      return Colors.orange;
    }

    if (name.contains('failed') ||
        name.contains('error') ||
        name.contains('closed')) {
      return Colors.red;
    }

    if (name.contains('success')) {
      return Colors.green;
    }

    return Colors.blueGrey;
  }
}
