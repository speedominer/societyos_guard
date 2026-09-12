import 'dart:async';

class TelemetryEvent {
  final DateTime ts;
  final String name;
  final Map<String, dynamic> details;

  TelemetryEvent(this.name, this.details) : ts = DateTime.now();

  Map<String, dynamic> toJson() => {'ts': ts.toIso8601String(), 'name': name, 'details': details};
}

/// Lightweight in-memory telemetry collector for development/support.
/// Does NOT store secrets (we avoid logging raw tokens).
class TelemetryService {
  final List<TelemetryEvent> _events = [];
  final StreamController<List<Map<String, dynamic>>> _streamController = StreamController.broadcast();

  void log(String name, Map<String, dynamic> details) {
    // Filter out potential token fields
    final filtered = Map.of(details);
    filtered.removeWhere((k, v) => k.toLowerCase().contains('token') || k.toLowerCase().contains('auth'));
    final e = TelemetryEvent(name, filtered);
    _events.add(e);
    try {
      _streamController.add(_events.map((e) => e.toJson()).toList());
    } catch (_) {}
    // Also print to console for quick debugging
    // ignore: avoid_print
    print('[Telemetry] ${e.ts.toIso8601String()} $name ${filtered}');
  }

  List<Map<String, dynamic>> recent() => _events.map((e) => e.toJson()).toList();

  Stream<List<Map<String, dynamic>>> get stream => _streamController.stream;

  void dispose() {
    try {
      _streamController.close();
    } catch (_) {}
  }
}

final telemetryService = TelemetryService();
