import 'package:flutter_test/flutter_test.dart';
import 'package:societyos_guard/services/telemetry_event.dart';

void main() {
  test('TelemetryEvent toJson/fromJson preserves timestamp and details', () {
    final e = TelemetryEvent('test_event', {'k': 'v', 'num': 1});
    final json = e.toJson();
    final restored = TelemetryEvent.fromJson(json);

    expect(restored.name, equals(e.name));
    expect(restored.details, equals(e.details));
    expect(restored.ts.toIso8601String(), equals(e.ts.toIso8601String()));
  });
}
