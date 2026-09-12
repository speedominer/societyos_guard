import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/websocket_service.dart';
import '../config.dart';

final websocketServiceProvider = Provider<WebSocketService>((ref) {
  final uri = Uri.parse(Config.websocketUrl);
  return WebSocketService(uri);
});
