import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../config.dart';
import 'staff_pin_attendance_screen.dart';
import 'staff_scan_screen.dart';

class StaffAttendanceScreen extends StatelessWidget {
  const StaffAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Help / Staff')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          ElevatedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (c) => const StaffScanScreen())),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR')),
          const SizedBox(height: 12),
          ElevatedButton.icon(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => const StaffPinAttendanceScreen())),
              icon: const Icon(Icons.lock),
              label: const Text('Enter PIN')),
        ]),
      ),
    );
  }
}
