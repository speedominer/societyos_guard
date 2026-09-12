import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:societyos_guard/providers/auth_provider.dart';
import 'package:societyos_guard/providers/websocket_provider.dart';
import 'package:societyos_guard/services/websocket_service.dart';

class FakeWebSocketService extends WebSocketService {
  bool connectCalled = false;
  bool disposeCalled = false;

  final StreamController<String> _statusController =
      StreamController<String>.broadcast();

  FakeWebSocketService() : super(Uri.parse('ws://localhost:8080'));

  @override
  Stream<String> get statusStream => _statusController.stream;

  @override
  Future<void> connect({bool useAuth = true}) async {
    connectCalled = true;
    _statusController.add('online');
  }

  @override
  void retryNow() {
    connect();
  }

  @override
  void dispose() {
    disposeCalled = true;

    if (!_statusController.isClosed) {
      _statusController.close();
    }
  }

  @override
  String get currentStatus => 'offline';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  final Map<String, String> storage = {};

  setUp(() {
    storage.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      secureStorageChannel,
      (MethodCall call) async {
        switch (call.method) {
          case 'read':
            final key = (call.arguments as Map?)?['key']?.toString();
            return key == null ? null : storage[key];

          case 'write':
            final args = Map<String, dynamic>.from(
              call.arguments as Map,
            );

            final key = args['key']?.toString();
            final value = args['value']?.toString();

            if (key != null && value != null) {
              storage[key] = value;
            }

            return null;

          case 'delete':
            final key = (call.arguments as Map?)?['key']?.toString();

            if (key != null) {
              storage.remove(key);
            }

            return null;

          case 'containsKey':
            final key = (call.arguments as Map?)?['key']?.toString();
            return key != null && storage.containsKey(key);

          case 'readAll':
            return storage;

          case 'deleteAll':
            storage.clear();
            return null;

          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      secureStorageChannel,
      null,
    );
  });

  test(
    'auth provider setToken calls websocket connect',
    () async {
      final fake = FakeWebSocketService();

      final container = ProviderContainer(
        overrides: [
          websocketServiceProvider.overrideWithValue(fake),
        ],
      );

      addTearDown(() {
        fake.dispose();
        container.dispose();
      });

      final authNotifier = container.read(authProvider.notifier);

      await authNotifier.setToken('TEST_TOKEN');

      expect(
        container.read(authProvider),
        'TEST_TOKEN',
      );

      expect(
        fake.connectCalled,
        true,
      );
    },
  );

  test(
    'auth provider clear disposes websocket',
    () async {
      final fake = FakeWebSocketService();

      final container = ProviderContainer(
        overrides: [
          websocketServiceProvider.overrideWithValue(fake),
        ],
      );

      addTearDown(() {
        fake.dispose();
        container.dispose();
      });

      final authNotifier = container.read(authProvider.notifier);

      await authNotifier.setToken('T');

      await authNotifier.clear();

      expect(
        container.read(authProvider),
        null,
      );

      expect(
        fake.disposeCalled,
        true,
      );
    },
  );
}
