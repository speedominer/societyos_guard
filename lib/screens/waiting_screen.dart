import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/websocket_provider.dart';
import '../services/api_service.dart';
import '../config.dart';
import 'approval_result_screen.dart';
import '../providers/websocket_status_provider.dart';
import '../providers/websocket_reconnect_provider.dart';

class WaitingScreen extends ConsumerStatefulWidget {
  final String visitorId;
  const WaitingScreen({super.key, required this.visitorId});

  @override
  ConsumerState<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends ConsumerState<WaitingScreen> {
  StreamSubscription<Map<String, dynamic>>? _sub;
  String _statusText = 'WAITING FOR RESIDENT';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startListening());
  }

  void _startListening() async {
    final ws = ref.read(websocketServiceProvider);
    try {
      await ws.connect();
    } catch (_) {
      setState(() => _statusText = 'Connection error');
    }
    _sub = ws.messages.listen((event) {
      // Expecting event map with keys: 'type' and 'visitorId' and maybe 'payload'
      final type = event['type']?.toString() ?? '';
      final vid = event['visitorId']?.toString() ?? event['payload']?['visitorId']?.toString();
      if (vid == widget.visitorId) {
        if (type == 'visitor:approved') {
          _goResult(true, event);
        } else if (type == 'visitor:denied') {
          _goResult(false, event);
        }
      }
    }, onError: (err) {
      setState(() => _statusText = 'Connection error');
    });
  }

  void _goResult(bool approved, Map<String, dynamic> event) {
    _sub?.cancel();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => ApprovalResultScreen(approved: approved, visitorId: widget.visitorId, event: event)));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conn = ref.watch(websocketStatusProvider);
    final reconnectInfo = ref.watch(websocketReconnectProvider).asData?.value ?? {'remaining': 0, 'total': 0};
    final countdown = reconnectInfo['remaining'] ?? 0;
    final total = reconnectInfo['total'] ?? 0;
    Color badgeColor;
    String badgeText;
    if (conn == 'online') {
      badgeColor = Colors.green;
      badgeText = 'Online';
    } else if (conn == 'connecting') {
      badgeColor = Colors.orange;
      badgeText = 'Connecting';
    } else if (conn == 'reconnecting') {
      badgeColor = Colors.orange;
      badgeText = countdown > 0 ? 'Reconnecting in ${countdown}s' : 'Reconnecting';
    } else if (conn == 'auth_error') {
      badgeColor = Colors.purple;
      badgeText = 'Auth Error';
    } else {
      badgeColor = Colors.red;
      badgeText = 'Offline';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Waiting')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(badgeText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ]),
            if (conn == 'reconnecting' && (total ?? 0) > 0) ...[
              const SizedBox(height: 8),
              SizedBox(width: 160, height: 8, child: LinearProgressIndicator(value: ((total ?? 1) - (countdown ?? 0)) / (total ?? 1), backgroundColor: Colors.black12, color: Colors.orange)),
            ]
          ]),
          const SizedBox(height: 12),
          const Icon(Icons.hourglass_top, size: 72),
          const SizedBox(height: 12),
          Text(_statusText, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Row(mainAxisSize: MainAxisSize.min, children: [
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: (conn == 'online' || conn == 'connecting') ? null : () {
                try {
                  final ws = ref.read(websocketServiceProvider);
                  ws.retryNow();
                } catch (_) {}
              },
              child: const Text('RETRY NOW'),
            )
          ])
        ]),
      ),
    );
  }
}
