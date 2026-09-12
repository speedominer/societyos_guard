import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/new_visitor_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/waiting_screen.dart';
import 'screens/approval_result_screen.dart';
import 'screens/login_screen.dart';
import 'screens/visitor_history_screen.dart';
import 'screens/emergency_list_screen.dart';
import 'screens/diagnostics_screen.dart';
import 'providers/auth_provider.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Listen to auth state changes and navigate centrally
    ref.listen<String?>(authProvider, (previous, next) {
      // navigate to login when token is cleared
      if (next == null) {
        _navKey.currentState?.pushNamedAndRemoveUntil('/login', (r) => false);
      } else {
        _navKey.currentState?.pushNamedAndRemoveUntil('/dashboard', (r) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navKey,
      title: 'SocietyOS Guard',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (c) => const SplashScreen(),
        '/login': (c) => const LoginScreen(),
        '/dashboard': (c) => const DashboardScreen(),
        '/new-visitor': (c) => const NewVisitorScreen(),
        '/scan': (c) => const QRScannerScreen(),
        '/qr-result': (c) => const SplashScreen(),
        '/history': (c) => const VisitorHistoryScreen(),
        '/emergencies': (c) => const EmergencyListScreen(),
        '/exit': (c) => const ExitScreen(),
        '/staff': (c) => const StaffAttendanceScreen(),
        '/diagnostics': (c) => const DiagnosticsScreen(),
      },
    );
  }
}
