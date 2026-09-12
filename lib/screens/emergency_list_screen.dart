import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/emergency_card.dart';
import 'emergency_detail_screen.dart';
import '../providers/emergency_provider.dart';

class EmergencyListScreen extends ConsumerWidget {
  const EmergencyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(emergencyProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Emergencies')),
      body: list.isEmpty ? const Center(child: Text('No alerts')) : RefreshIndicator(
        onRefresh: () async { ref.refresh(emergencyProvider); },
        child: ListView.builder(itemCount: list.length, itemBuilder: (c,i) => EmergencyCard(emergency: list[i], onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c)=> EmergencyDetailScreen(emergency: list[i]))))),
      ),
    );
  }
}
