import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config.dart';

class StaffPinAttendanceScreen extends StatefulWidget {
  const StaffPinAttendanceScreen({super.key});

  @override
  State<StaffPinAttendanceScreen> createState() => _StaffPinAttendanceScreenState();
}

class _StaffPinAttendanceScreenState extends State<StaffPinAttendanceScreen> {
  final _pin = TextEditingController();
  final ApiService api = ApiService(baseUrl: Config.backendBaseUrl);
  String? _status;

  Future<void> _record() async {
    if (_pin.text.isEmpty) return;
    setState(() => _status = 'Recording...');
    try {
      final res = await api.recordAttendance({'pin': _pin.text, 'gateId': 'GATE_1', 'type': 'pin'});
      setState(() => _status = res['status']?.toString() ?? 'done');
    } catch (e) {
      setState(() => _status = 'Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff PIN')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(controller: _pin, decoration: const InputDecoration(labelText: 'PIN')), 
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _record, child: const Text('RECORD ATTENDANCE')),
          const SizedBox(height: 12),
          if (_status != null) Text(_status!),
        ]),
      ),
    );
  }
}
