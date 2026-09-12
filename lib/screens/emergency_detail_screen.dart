import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config.dart';

class EmergencyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> emergency;
  const EmergencyDetailScreen({super.key, required this.emergency});

  @override
  State<EmergencyDetailScreen> createState() => _EmergencyDetailScreenState();
}

class _EmergencyDetailScreenState extends State<EmergencyDetailScreen> {
  final ApiService api = ApiService(baseUrl: Config.backendBaseUrl);
  bool _processing = false;

  Future<void> _ack() async {
    setState(() => _processing = true);
    await api.acknowledgeEmergency(widget.emergency['id'].toString());
    if (mounted) setState(() => _processing = false);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _resolve() async {
    setState(() => _processing = true);
    await api.resolveEmergency(widget.emergency['id'].toString());
    if (mounted) setState(() => _processing = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.emergency;
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Detail')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Flat: ${e['flat'] ?? ''}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Resident: ${e['resident'] ?? ''}'),
          const SizedBox(height: 8),
          Text('Time: ${e['time'] ?? ''}'),
          const SizedBox(height: 16),
          if (_processing) const Center(child: CircularProgressIndicator()),
          if (!(_processing)) Row(children: [
            ElevatedButton(onPressed: _ack, child: const Text('ACKNOWLEDGE')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: () => _callResident(e), child: const Text('CALL RESIDENT')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _resolve, child: const Text('RESOLVE')),
          ])
        ]),
      ),
    );
  }

  void _callResident(Map<String, dynamic> e) {
    final phone = e['phone']?.toString();
    if (phone != null && phone.isNotEmpty) {
      // On device we'd use url_launcher to call; here we just show a dialog
      showDialog(context: context, builder: (c) => AlertDialog(title: const Text('Call Resident'), content: Text('Call $phone?'), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')), TextButton(onPressed: () { Navigator.pop(c); }, child: const Text('OK'))]));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No phone number')));
    }
  }
}
