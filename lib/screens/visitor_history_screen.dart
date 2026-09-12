import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gate_event.dart';
import '../widgets/gate_event_card.dart';
import '../providers/history_provider.dart';

class VisitorHistoryScreen extends ConsumerWidget {
  const VisitorHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(historyProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Visitor History')),
      body: items.isEmpty ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(
        onRefresh: () async { ref.refresh(historyProvider); },
        child: ListView.builder(itemCount: items.length, itemBuilder: (c,i) => GateEventCard(event: GateEvent.fromJson(items[i]))),
      ),
    );
  }
}
