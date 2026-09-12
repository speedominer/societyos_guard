import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'websocket_provider.dart';

class WSStatusNotifier extends StateNotifier<String> {
  StreamSubscription<String>? _sub;

  WSStatusNotifier({required Ref ref}) : super('offline') {
    final ws = ref.read(websocketServiceProvider);
    // subscribe to the service status stream
    _sub = ws.statusStream.listen((s) {
      state = s;
    }, onError: (_) {
      state = 'offline';
    });
    // initialize state from current status
    try {
      state = ws.currentStatus;
    } catch (_) {}
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final websocketStatusProvider = StateNotifierProvider<WSStatusNotifier, String>((ref) {
  return WSStatusNotifier(ref: ref);
});
