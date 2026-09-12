import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'auth_service.dart';
import 'telemetry_service.dart';

// WebSocketService: robust connection with reconnection/backoff and auth header support.

class WebSocketService {
  final Uri uri;
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _controller;
  StreamController<String>? _statusController;
  StreamController<int>? _reconnectCountdownController;
  Timer? _reconnectTimer;

  WebSocketService(this.uri);

  // Internal state
  bool _connected = false;
  bool _connecting = false;
  bool _shouldReconnect = true;
  StreamSubscription? _channelSubscription;
  final int _baseDelayMs = 500;
  final int _maxDelayMs = 30000;
  int _reconnectAttempts = 0;
  int _reconnectTotalSeconds = 0;

  /// Connect to the WebSocket. If [useAuth] is true, the service will attempt to
  /// read the token from `AuthService` and include an `Authorization` header.
  Future<void> connect({bool useAuth = true}) async {
    if (_connected || _connecting) return;
    _connecting = true;
    _shouldReconnect = true;
    _statusController ??= StreamController<String>.broadcast();
    _statusController?.add('connecting');
    _reconnectCountdownController ??= StreamController<int>.broadcast();

    Map<String, dynamic>? headersMap;
    if (useAuth) {
      try {
        final token = await AuthService().token();
        if (token != null && token.isNotEmpty) {
          headersMap = {'Authorization': 'Bearer $token'};
        }
      } catch (_) {}
    }

    Future<void> _attemptConnect() async {
      try {
        // Clean up previous channel subscription if any
        await _channelSubscription?.cancel();
        await _channel?.sink.close();
      } catch (_) {}

      // keep controller alive so listeners remain subscribed across reconnects
      _controller ??= StreamController<Map<String, dynamic>>.broadcast();

      try {
        // Use IOWebSocketChannel to pass headers on io platforms
        _channel = IOWebSocketChannel.connect(uri,
            headers: headersMap?.map((k, v) => MapEntry(k, v.toString())));
        _channelSubscription = _channel!.stream.listen((message) {
          try {
            if (message is String) {
              final parsed = jsonDecode(message);
              // Detect auth-related messages from server
              if (parsed is Map<String, dynamic>) {
                final t = parsed['type']?.toString();
                if (t == 'auth:invalid' ||
                    t == 'auth:expired' ||
                    t == 'auth:failed') {
                  // clear stored token and stop reconnect attempts
                  try {
                    AuthService().clear();
                  } catch (_) {}
                  telemetryService.log('auth_error_received', {'type': t});
                  _shouldReconnect = false;
                  _statusController?.add('auth_error');
                  // notify listeners
                  _controller?.add(parsed);
                  return;
                }
              }
              if (parsed is Map<String, dynamic>) {
                _controller?.add(parsed);
              } else {
                _controller?.add({'raw': parsed});
              }
            } else if (message is List<int>) {
              final text = utf8.decode(message);
              final parsed = jsonDecode(text);
              if (parsed is Map<String, dynamic>) _controller?.add(parsed);
            }
          } catch (e) {
            // ignore parse errors
          }
        }, onDone: () {
          _connected = false;
          _channelSubscription = null;
          if (_shouldReconnect) {
            telemetryService.log('connection_closed', {});
            _scheduleReconnect();
          }
        }, onError: (err) {
          _controller?.addError(err);
          _connected = false;
          _channelSubscription = null;
          // If error contains a HTTP 401 or auth hint, clear token
          try {
            final s = err.toString();
            if (s.contains('401') || s.toLowerCase().contains('unauthorized')) {
              try {
                AuthService().clear();
              } catch (_) {}
              telemetryService.log('auth_error_on_err', {'error': s});
              _shouldReconnect = false;
              _statusController?.add('auth_error');
              return;
            }
          } catch (_) {}
          if (_shouldReconnect) {
            telemetryService.log('connection_error', {'error': err.toString()});
            _scheduleReconnect();
          }
        });

        _connected = true;
        _connecting = false;
        final hadAttempts = _reconnectAttempts > 0;
        _reconnectAttempts = 0;
        _statusController?.add('online');
        // Telemetry: successful connect
        telemetryService.log(
            hadAttempts ? 'reconnect_success' : 'connect_success', {
          'uri': uri.toString(),
          'attempts': hadAttempts ? _reconnectAttempts : 0
        });
      } catch (e) {
        _connected = false;
        _connecting = false;
        _statusController?.add('offline');
        telemetryService.log('connect_failed', {'error': e.toString()});
        if (_shouldReconnect) _scheduleReconnect();
      }
    }

    await _attemptConnect();
  }

  void _scheduleReconnect() {
    _reconnectAttempts++;
    final jitter = (100 + (_reconnectAttempts * 37)) % 1000; // small jitter
    int delayMs = _baseDelayMs * (1 << (_reconnectAttempts - 1));
    if (delayMs > _maxDelayMs) delayMs = _maxDelayMs;
    delayMs += jitter;
    // cancel existing timer if any
    try {
      _reconnectTimer?.cancel();
    } catch (_) {}
    int seconds = (delayMs / 1000).ceil();
    _reconnectTotalSeconds = seconds;
    telemetryService.log('auto_retry_scheduled', {
      'attempts': _reconnectAttempts,
      'delayMs': delayMs,
      'seconds': seconds
    });
    // emit initial countdown value
    try {
      _reconnectCountdownController?.add(seconds);
    } catch (_) {}
    _statusController?.add('reconnecting');
    _reconnectTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      seconds--;
      if (seconds <= 0) {
        try {
          _reconnectCountdownController?.add(0);
        } catch (_) {}
        t.cancel();
      } else {
        try {
          _reconnectCountdownController?.add(seconds);
        } catch (_) {}
      }
    });
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (!_shouldReconnect) return;
      _statusController?.add('connecting');
      try {
        _reconnectTimer?.cancel();
      } catch (_) {}
      telemetryService
          .log('auto_retry_attempt', {'attempts': _reconnectAttempts});
      connect();
    });
  }

  /// Attempt an immediate reconnect, cancelling any existing backoff timer.
  /// This will not start a new connect if already connected or currently connecting.
  void retryNow() {
    if (_connected) return;
    if (_connecting) return;
    _shouldReconnect = true;
    try {
      _reconnectTimer?.cancel();
    } catch (_) {}
    try {
      _reconnectCountdownController?.add(0);
    } catch (_) {}
    telemetryService.log('manual_retry', {'attempts': _reconnectAttempts});
    _statusController?.add('connecting');
    connect();
  }

  /// Cancel any scheduled backoff countdown without attempting immediate reconnect.
  void cancelBackoff() {
    try {
      _reconnectTimer?.cancel();
    } catch (_) {}
    try {
      _reconnectCountdownController?.add(0);
    } catch (_) {}
  }

  void send(Map<String, dynamic> message) {
    try {
      if (_connected) _channel?.sink.add(jsonEncode(message));
    } catch (_) {}
  }

  /// Total seconds for the current reconnect countdown (set when a backoff is scheduled)
  int get reconnectTotalSeconds => _reconnectTotalSeconds;

  Stream<String> get statusStream =>
      _statusController?.stream ?? const Stream.empty();

  String get currentStatus {
    if (_connected) return 'online';
    if (_connecting) return 'connecting';
    return 'offline';
  }

  void dispose() {
    _shouldReconnect = false;
    try {
      _channelSubscription?.cancel();
    } catch (_) {}
    try {
      _channel?.sink.close();
    } catch (_) {}
    try {
      _controller?.close();
    } catch (_) {}
    try {
      _statusController?.close();
    } catch (_) {}
    try {
      _reconnectTimer?.cancel();
    } catch (_) {}
    try {
      _reconnectCountdownController?.close();
    } catch (_) {}
  }

  Stream<int> get reconnectCountdownStream =>
      _reconnectCountdownController?.stream ?? const Stream.empty();

  Stream<Map<String, dynamic>> get messages =>
      _controller?.stream ?? const Stream.empty();
}
