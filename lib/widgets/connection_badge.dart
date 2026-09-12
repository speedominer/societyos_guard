import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/websocket_status_provider.dart';
import '../providers/websocket_reconnect_provider.dart';
import '../providers/websocket_provider.dart';

class ConnectionBadge extends ConsumerWidget {
  const ConnectionBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(websocketStatusProvider);

    final reconnectInfo =
        ref.watch(websocketReconnectProvider).asData?.value ??
            {'remaining': 0, 'total': 0};

    final countdown = reconnectInfo['remaining'] ?? 0;
    final total = reconnectInfo['total'] ?? 0;

    Color color;
    String text;

    switch (status) {
      case 'online':
        color = Colors.green;
        text = 'Online';
        break;

      case 'reconnecting':
        color = Colors.orange;
        text = countdown > 0
            ? 'Reconnecting in ${countdown}s'
            : 'Reconnecting';
        break;

      case 'connecting':
        color = Colors.orange;
        text = 'Connecting';
        break;

      case 'auth_error':
        color = Colors.purple;
        text = 'Auth';
        break;

      default:
        color = Colors.red;
        text = 'Offline';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 6),

        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(width: 8),

        if (status == 'reconnecting' && total > 0)
          SizedBox(
            width: 80,
            height: 8,
            child: LinearProgressIndicator(
              value: ((total - countdown) / total).clamp(0.0, 1.0),
              backgroundColor: Colors.black12,
              color: Colors.orange,
            ),
          ),

        const SizedBox(width: 8),

        if (status != 'online' && status != 'auth_error')
          IconButton(
            icon: const Icon(Icons.refresh, size: 16),
            tooltip: 'Retry Now',
            onPressed: () {
              try {
                final ws = ref.read(websocketServiceProvider);
                ws.retryNow();
              } catch (_) {
                // Connection state is handled by the WebSocket providers.
              }
            },
          ),

        IconButton(
          icon: const Icon(Icons.bug_report, size: 16),
          tooltip: 'Diagnostics',
          onPressed: () {
            Navigator.pushNamed(context, '/diagnostics');
          },
        ),
      ],
    );
  }
}
