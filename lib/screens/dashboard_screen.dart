import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/visitor_card.dart';
import '../widgets/connection_badge.dart';
import '../services/api_service.dart';
import '../config.dart';
import '../providers/active_visitors_provider.dart';
import '../providers/history_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _quickExitInProgress = false;

  Future<void> _quickExit() async {
    if (_quickExitInProgress) return;
    setState(() => _quickExitInProgress = true);
    try {
      final visitors = await ref.read(activeVisitorsProvider.future);
      if (visitors.isEmpty) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No visitors currently inside')));
        return;
      }
      // pick most recent visitor (assume server returns most recent first)
      final v = visitors.first;
      final name = v['name']?.toString() ?? 'Visitor';
      final confirmed = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
                title: const Text('Confirm Exit'),
                content: Text('Record exit for $name?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Confirm'))
                ],
              ));
      if (confirmed != true) return;

      final api = ApiService(baseUrl: Config.backendBaseUrl);
      final payload = {
        'visitorId': v['id']?.toString(),
        'gateId': 'GATE_1',
        'guardId': 'GUARD_1',
        'timestamp': DateTime.now().toIso8601String(),
      };
      await api.recordExit(payload);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Exit recorded')));
        // refresh active visitors and history
        ref.refresh(activeVisitorsProvider);
        ref.refresh(historyProvider);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to record exit')));
    } finally {
      if (mounted) setState(() => _quickExitInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), actions: const [
        Padding(padding: EdgeInsets.only(right: 12.0), child: ConnectionBadge())
      ]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(spacing: 8, runSpacing: 8, children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('NEW VISITOR'),
                  onPressed: () => Navigator.pushNamed(context, '/new-visitor'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 56)),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('SCAN QR'),
                  onPressed: () => Navigator.pushNamed(context, '/scan'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 56)),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.group),
                  label: const Text('HELP ATTENDANCE'),
                  onPressed: () => Navigator.pushNamed(context, '/staff'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 56)),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.warning),
                  label: const Text('EMERGENCY'),
                  onPressed: () => Navigator.pushNamed(context, '/emergencies'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 56),
                      backgroundColor: Colors.redAccent),
                ),
              ]),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('EXIT'),
                  onPressed: () => Navigator.pushNamed(context, '/exit'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 56)),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person),
                  label: const Text('STAFF'),
                  onPressed: () => Navigator.pushNamed(context, '/staff'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 56)),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.history),
                  label: const Text('HISTORY'),
                  onPressed: () => Navigator.pushNamed(context, '/history'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 56)),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.warning_amber),
                  label: const Text('EMERGENCIES'),
                  onPressed: () => Navigator.pushNamed(context, '/emergencies'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 56),
                      backgroundColor: Colors.redAccent),
                ),
              ]),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: _quickExitInProgress
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.flash_on),
                label: const Text('QUICK EXIT'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: Colors.orangeAccent),
                onPressed: _quickExitInProgress ? null : _quickExit,
              ),
              const SizedBox(height: 12),
              const Text('Waiting approvals',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                  child: ListView.builder(
                      itemCount: 0,
                      itemBuilder: (c, i) => const SizedBox.shrink())),
            ],
          ),
        ),
      ),
    );
  }
}
