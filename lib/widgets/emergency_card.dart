import 'package:flutter/material.dart';

class EmergencyCard extends StatelessWidget {
  final Map<String, dynamic> emergency;
  final VoidCallback? onTap;
  const EmergencyCard({super.key, required this.emergency, this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = emergency['status']?.toString() ?? 'unknown';
    final color = status == 'active' ? Colors.red : Colors.grey;
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
            backgroundColor: color, child: const Icon(Icons.warning)),
        title: Text(emergency['flat']?.toString() ?? 'Unknown flat'),
        subtitle: Text(
            '${emergency['resident'] ?? 'Resident'} • ${emergency['time'] ?? ''}'),
        trailing: Text(status.toUpperCase()),
      ),
    );
  }
}
