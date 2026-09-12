import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config.dart';
import 'photo_capture_screen.dart';
import 'dart:io';

class ApprovalResultScreen extends StatelessWidget {
  final bool approved;
  final String visitorId;
  final Map<String, dynamic>? event;

  const ApprovalResultScreen({super.key, required this.approved, required this.visitorId, this.event});

  Future<void> _recordEntry(BuildContext context) async {
    // Capture photo first
    final photo = await Navigator.push<File?>(context, MaterialPageRoute(builder: (c) => const PhotoCaptureScreen()));
    final api = ApiService(baseUrl: Config.backendBaseUrl);
    final payload = {
      'visitorId': visitorId,
      'gateId': 'GATE_1',
      'guardId': 'GUARD_1',
      'timestamp': DateTime.now().toIso8601String(),
      'approvalEvent': event ?? {},
    };
    try {
      if (photo != null) {
        final res = await api.recordEntryWithPhoto(payload, photo);
        if (res.statusCode >= 200 && res.statusCode < 300) {
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ENTRY RECORDED')));
          if (context.mounted) Navigator.popUntil(context, (r) => r.isFirst);
          return;
        }
      } else {
        // fallback to regular record
        await api.recordEntry(payload);
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ENTRY RECORDED')));
        if (context.mounted) Navigator.popUntil(context, (r) => r.isFirst);
        return;
      }
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to record entry')));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to record entry')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = approved ? 'ENTRY APPROVED' : 'ENTRY DENIED';
    final color = approved ? Colors.green : Colors.red;
    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(approved ? Icons.check_circle : Icons.cancel, size: 92, color: color),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 24),
          if (approved)
            ElevatedButton(onPressed: () => _recordEntry(context), child: const Text('RECORD ENTRY')),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), child: const Text('BACK TO DASHBOARD'))
        ]),
      ),
    );
  }
}
