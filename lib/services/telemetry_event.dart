class TelemetryEvent {
  final DateTime ts;
  final String name;
  final Map<String, dynamic> details;

  TelemetryEvent(this.name, this.details) : ts = DateTime.now();

  TelemetryEvent.withTs(this.name, this.details, DateTime ts) : ts = ts;

  factory TelemetryEvent.fromJson(Map<String, dynamic> m) {
    DateTime parsed;
    try {
      final s = m['ts']?.toString();
      parsed = s != null ? DateTime.parse(s) : DateTime.now();
    } catch (_) {
      parsed = DateTime.now();
    }

    return TelemetryEvent.withTs(
      m['name']?.toString() ?? 'unknown',
      Map<String, dynamic>.from(m['details'] ?? {}),
      parsed,
    );
  }

  Map<String, dynamic> toJson() => {
        'ts': ts.toIso8601String(),
        'name': name,
        'details': details,
      };
}
