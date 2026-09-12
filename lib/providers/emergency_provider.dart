import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../providers/websocket_provider.dart';
import '../config.dart';

class EmergencyNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final Ref ref;
  StreamSubscription? _sub;

  EmergencyNotifier(this.ref) : super([]) {
    _init();
  }

  Future<void> _init() async {
    final api = ApiService(baseUrl: Config.backendBaseUrl);
    final data = await api.fetchEmergencies();
    state = data;
    final ws = ref.read(websocketServiceProvider);
    try {
      await ws.connect();
    } catch (_) {}
    _sub = ws.messages.listen((event) {
      final type = event['type']?.toString() ?? '';
      if (type == 'emergency:created') {
        final payload = event['payload'] as Map<String, dynamic>? ?? {};
        state = [payload, ...state];
      } else if (type == 'emergency:updated') {
        final payload = event['payload'] as Map<String, dynamic>? ?? {};
        state =
            state.map((e) => e['id'] == payload['id'] ? payload : e).toList();
      } else if (type == 'emergency:resolved') {
        final id = event['payload']?['id']?.toString();
        if (id != null)
          state = state.where((e) => e['id']?.toString() != id).toList();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final emergencyProvider =
    StateNotifierProvider<EmergencyNotifier, List<Map<String, dynamic>>>((ref) {
  return EmergencyNotifier(ref);
});
