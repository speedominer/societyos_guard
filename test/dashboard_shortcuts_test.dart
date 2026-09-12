import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:societyos_guard/screens/dashboard_screen.dart';
import 'package:societyos_guard/screens/new_visitor_screen.dart';
import 'package:societyos_guard/screens/visitor_history_screen.dart';
import 'package:societyos_guard/screens/exit_screen.dart';
import 'package:societyos_guard/screens/staff_attendance_screen.dart';
import 'package:societyos_guard/screens/emergency_list_screen.dart';
import 'package:societyos_guard/providers/websocket_provider.dart';
import 'package:societyos_guard/services/websocket_service.dart';

void main() {
  testWidgets(
    'Dashboard shortcuts navigate to appropriate screens',
    (WidgetTester tester) async {
      final fakeWebSocket = WebSocketService(
        Uri.parse('ws://localhost:8080'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            websocketServiceProvider.overrideWithValue(fakeWebSocket),
          ],
          child: MaterialApp(
            home: const DashboardScreen(),
            routes: {
              '/new-visitor': (context) => const NewVisitorScreen(),
              '/history': (context) => const VisitorHistoryScreen(),
              '/exit': (context) => const ExitScreen(),
              '/staff': (context) => const StaffAttendanceScreen(),
              '/emergencies': (context) => const EmergencyListScreen(),
            },
          ),
        ),
      );

      addTearDown(fakeWebSocket.dispose);

      await tester.pump();

      // ------------------------------------------------------------
      // NEW VISITOR
      // ------------------------------------------------------------

      expect(find.text('NEW VISITOR'), findsOneWidget);

      await tester.tap(find.text('NEW VISITOR'));

      // Let the navigation route animation complete.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(NewVisitorScreen), findsOneWidget);
      expect(find.text('New Visitor'), findsOneWidget);

      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // ------------------------------------------------------------
      // EXIT
      // ------------------------------------------------------------

      expect(find.text('EXIT'), findsOneWidget);

      await tester.tap(find.text('EXIT'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ExitScreen), findsOneWidget);
      expect(find.text('Record Exit'), findsOneWidget);

      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // ------------------------------------------------------------
      // STAFF
      // ------------------------------------------------------------

      expect(find.text('STAFF'), findsOneWidget);

      await tester.tap(find.text('STAFF'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(StaffAttendanceScreen), findsOneWidget);
      expect(find.text('Daily Help / Staff'), findsOneWidget);

      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // ------------------------------------------------------------
      // HISTORY
      // ------------------------------------------------------------

      expect(find.text('HISTORY'), findsOneWidget);

      await tester.tap(find.text('HISTORY'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(VisitorHistoryScreen), findsOneWidget);
      expect(find.text('Visitor History'), findsOneWidget);

      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // ------------------------------------------------------------
      // EMERGENCIES
      // ------------------------------------------------------------

      expect(find.text('EMERGENCIES'), findsOneWidget);

      await tester.tap(find.text('EMERGENCIES'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(EmergencyListScreen), findsOneWidget);
      expect(find.text('Emergencies'), findsOneWidget);
    },
  );
}
