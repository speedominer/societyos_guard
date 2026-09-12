import 'package:flutter/material.dart';

class QRValidationResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  const QRValidationResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final valid = result['status'] == 'valid';
    return Scaffold(
      appBar: AppBar(title: const Text('QR Validation')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(valid ? Icons.check_circle : Icons.cancel,
              size: 96, color: valid ? Colors.green : Colors.red),
          const SizedBox(height: 12),
          Text(valid ? 'VALID PASS' : 'INVALID / EXPIRED',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (result.containsKey('details')) Text(result['details'].toString()),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('BACK'))
        ]),
      ),
    );
  }
}
