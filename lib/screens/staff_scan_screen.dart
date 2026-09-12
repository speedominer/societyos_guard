import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../services/api_service.dart';
import '../config.dart';

class StaffScanScreen extends StatefulWidget {
  const StaffScanScreen({super.key});

  @override
  State<StaffScanScreen> createState() => _StaffScanScreenState();
}

class _StaffScanScreenState extends State<StaffScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'StaffQR');
  QRViewController? controller;
  String? _status;
  final ApiService api = ApiService(baseUrl: Config.backendBaseUrl);

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController c) {
    controller = c;
    c.scannedDataStream.listen((scanData) async {
      controller?.pauseCamera();
      setState(() => _status = 'Recording attendance...');
      try {
        final token = scanData.code ?? '';
        final res = await api.recordAttendance(
            {'token': token, 'gateId': 'GATE_1', 'type': 'scan'});
        setState(() => _status = res['status'] ?? 'done');
      } catch (e) {
        setState(() => _status = 'Failed');
      }
      await Future.delayed(const Duration(seconds: 2));
      controller?.resumeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff QR Scan')),
      body: Column(children: [
        Expanded(child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated)),
        Container(
            height: 64,
            alignment: Alignment.center,
            child: Text(_status ?? 'Scan staff QR'))
      ]),
    );
  }
}
