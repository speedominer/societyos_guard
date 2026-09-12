import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../providers/websocket_provider.dart';
import '../config.dart';

class HistoryNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final Ref ref;
  StreamSubscription? _sub;

  HistoryNotifier(this.ref) : super([]) {
    _init();
  }

  Future<void> _init() async {
    final api = ApiService(baseUrl: Config.backendBaseUrl);
    final data = await api.fetchHistory();
    state = data;
    final ws = ref.read(websocketServiceProvider);
    try {
      await ws.connect();
    } catch (_) {}
    _sub = ws.messages.listen((event) {
      final type = event['type']?.toString() ?? '';
      if (type == 'visitor:entry' || type == 'visitor:exit') {
        final payload = event['payload'] as Map<String, dynamic>? ?? {};
        state = [payload, ...state];
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<Map<String, dynamic>>>((ref) {
  return HistoryNotifier(ref);
});
