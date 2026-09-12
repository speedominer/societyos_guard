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
    _events = telemetryService.recent();
    _sub = telemetryService.stream.listen((list) {
      setState(() => _events = list);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostics')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Telemetry Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () => setState(() => _events = []), child: const Text('Clear'))
          ]),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _events.length,
              itemBuilder: (c, i) {
                final e = _events[_events.length - 1 - i]; // reverse order
                final name = e['name'] ?? '';
                final ts = e['ts'] ?? '';
                final details = e['details'] ?? {};
                return Card(
                  child: ListTile(
                    title: Text('$name'),
                    subtitle: Text('$ts\n$details'),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          )
        ]),
      ),
    );
  }
}
