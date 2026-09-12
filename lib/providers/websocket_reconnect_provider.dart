import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'websocket_provider.dart';

/// Provides reconnect countdown info as a map: {'remaining': int, 'total': int}
final websocketReconnectProvider = StreamProvider<Map<String, int?>>((ref) {
  final ws = ref.read(websocketServiceProvider);
  return ws.reconnectCountdownStream
      .map((s) => {'remaining': s, 'total': ws.reconnectTotalSeconds});
});
