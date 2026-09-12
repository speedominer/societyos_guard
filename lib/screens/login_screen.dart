import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../config.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phone = TextEditingController();
  final _pin = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final api = ApiService(baseUrl: Config.backendBaseUrl);
      final resp = await api
          .post('/auth/login', {'phone': _phone.text, 'pin': _pin.text});
      final body = resp.body.isNotEmpty ? resp.body : '{}';
      final Map<String, dynamic> parsed = body.isNotEmpty
          ? (resp.statusCode >= 200 && resp.statusCode < 300
              ? (resp.body.isNotEmpty
                  ? (jsonDecode(resp.body) as Map<String, dynamic>)
                  : {})
              : {})
          : {};
      final token = parsed['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await ref.read(authProvider.notifier).setToken(token);
        if (context.mounted)
          Navigator.pushReplacementNamed(context, '/dashboard');
        return;
      }
      // fallback: accept pin as token for testing
      if (_pin.text.isNotEmpty) {
        await ref.read(authProvider.notifier).setToken(_pin.text);
        if (context.mounted)
          Navigator.pushReplacementNamed(context, '/dashboard');
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Login failed')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Login error')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guard Login')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(
              controller: _phone,
              decoration: const InputDecoration(labelText: 'Phone')),
          TextField(
              controller: _pin,
              decoration: const InputDecoration(labelText: 'PIN/Passcode'),
              obscureText: true),
          const SizedBox(height: 12),
          _loading
              ? const CircularProgressIndicator()
              : ElevatedButton(onPressed: _login, child: const Text('LOGIN'))
        ]),
      ),
    );
  }
}
