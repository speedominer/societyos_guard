import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../providers/websocket_provider.dart';

class AuthNotifier extends StateNotifier<String?> {
  final Ref ref;
  AuthNotifier(this.ref) : super(null) {
    _load();
  }

  Future<void> _load() async {
    final token = await AuthService().token();
    state = token;
    if (token != null) {
      // Attempt to connect WS when token exists
      try {
        ref.read(websocketServiceProvider).connect();
      } catch (_) {}
    }
  }

  Future<void> setToken(String token) async {
    await AuthService().saveToken(token);
    state = token;
    try {
      await ref.read(websocketServiceProvider).connect();
    } catch (_) {}
  }

  Future<void> clear() async {
    await AuthService().clear();
    state = null;
    try {
      ref.read(websocketServiceProvider).dispose();
    } catch (_) {}
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, String?>((ref) {
  return AuthNotifier(ref);
});
