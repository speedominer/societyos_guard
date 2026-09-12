import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:societyos_guard/services/telemetry_service.dart';

void main() {
  test('TelemetryService persists and restores events from disk', () async {
    final tmp = await Directory.systemTemp.createTemp('telemetry_test_');
    try {
      final provider = () async => tmp;
      final svc1 = TelemetryService(documentsDirProvider: provider);
      await svc1.init();
      svc1.log('persistent_event', {'x': 42});
      // ensure file written via export (export calls _persist when file missing)
      final path = await svc1.export();
      expect(path, isNotNull);
      // create a new service instance pointing to same dir to simulate restart
      final svc2 = TelemetryService(documentsDirProvider: provider);
      await svc2.init();
      final recent = svc2.recent();
      expect(recent.length, equals(1));
      expect(recent.first['name'], equals('persistent_event'));
    } finally {
      try {
        await tmp.delete(recursive: true);
      } catch (_) {}
    }
  });
}
