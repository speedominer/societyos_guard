import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 800), () async {
      final token = await AuthService().token();
      if (token != null && token.isNotEmpty) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.security, size: 72),
          SizedBox(height: 12),
          Text('SocietyOS Guard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
        ]),
      ),
    );
  }
}
