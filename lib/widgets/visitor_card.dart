import 'package:flutter/material.dart';
import '../models/visitor.dart';

class VisitorCard extends StatelessWidget {
  final Visitor visitor;
  final VoidCallback? onTap;

  const VisitorCard({super.key, required this.visitor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(visitor.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        subtitle: Text('${visitor.purpose} • ${visitor.company ?? ''}'),
        trailing: Text(visitor.phone),
      ),
    );
  }
}
