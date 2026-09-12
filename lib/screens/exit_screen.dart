import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/active_visitors_provider.dart';
import '../services/api_service.dart';
import '../config.dart';

class ExitScreen extends ConsumerWidget {
  const ExitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(activeVisitorsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Record Exit')),
      body: async.when(
        data: (list) => list.isEmpty ? const Center(child: Text('No visitors inside')) : ListView.builder(
          itemCount: list.length,
          itemBuilder: (c,i) {
            final v = list[i];
            return Card(
              child: ListTile(
                title: Text(v['name']?.toString() ?? 'Unknown'),
                subtitle: Text(v['phone']?.toString() ?? ''),
                trailing: ElevatedButton(
                  child: const Text('EXIT'),
                  onPressed: () async {
                    final api = ApiService(baseUrl: Config.backendBaseUrl);
                    final payload = {
                      'visitorId': v['id']?.toString(),
                      'gateId': 'GATE_1',
                      'guardId': 'GUARD_1',
                      'timestamp': DateTime.now().toIso8601String(),
                    };
                    try {
                      await api.recordExit(payload);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exit recorded')));
                      ref.refresh(activeVisitorsProvider);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to record exit')));
                    }
                  },
                ),
              ),
            );
          }
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Failed: $e')),
      ),
    );
  }
}
