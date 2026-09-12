import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config.dart';
import 'waiting_screen.dart';

class NewVisitorScreen extends StatefulWidget {
  const NewVisitorScreen({super.key});

  @override
  State<NewVisitorScreen> createState() => _NewVisitorScreenState();
}

class _NewVisitorScreenState extends State<NewVisitorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _company = TextEditingController();
  final _purpose = TextEditingController();
  String? _flat;
  bool _waiting = false;

  final ApiService api = ApiService(baseUrl: Config.backendBaseUrl);

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _waiting = true);
    final payload = {
      'name': _name.text,
      'phone': _phone.text,
      'company': _company.text,
      'purpose': _purpose.text,
      'flatId': _flat,
    };
    try {
      final resp = await api.registerVisitor(payload);
      if (!mounted) return;
      // Expecting response to contain visitor id. Try common keys.
      final vid = resp['id']?.toString() ??
          resp['visitorId']?.toString() ??
          resp['data']?['id']?.toString();
      if (vid != null && vid.isNotEmpty) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (c) => WaitingScreen(visitorId: vid)));
      } else {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to register')));
    } finally {
      if (mounted) setState(() => _waiting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Visitor')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Visitor name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null),
            TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null),
            TextFormField(
                controller: _company,
                decoration:
                    const InputDecoration(labelText: 'Company (optional)')),
            TextFormField(
                controller: _purpose,
                decoration: const InputDecoration(labelText: 'Purpose')),
            DropdownButtonFormField<String>(
                value: _flat,
                items: const [
                  DropdownMenuItem(value: 'flat_101', child: Text('Flat 101'))
                ],
                onChanged: (v) => setState(() => _flat = v),
                decoration: const InputDecoration(labelText: 'Flat')),
            const SizedBox(height: 12),
            _waiting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submit, child: const Text('REGISTER AND WAIT'))
          ]),
        ),
      ),
    );
  }
}
