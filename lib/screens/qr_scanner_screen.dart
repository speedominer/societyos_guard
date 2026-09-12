import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../services/api_service.dart';
import 'qr_validation_result_screen.dart';
import '../config.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? _result;
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
      setState(() => _result = 'Validating...');
      final validated = await api.validateQr(scanData.code ?? '');
      // Navigate to validation result screen showing server response
      if (!mounted) return;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (c) => QRValidationResultScreen(result: validated)));
      // resume camera when returning
      controller?.resumeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner')),
      body: Column(children: [
        Expanded(child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated)),
        Container(
            height: 88,
            color: Colors.black12,
            alignment: Alignment.center,
            child: Text(_result ?? 'Scan a pass',
                style: const TextStyle(fontSize: 18)))
      ]),
    );
  }
}
