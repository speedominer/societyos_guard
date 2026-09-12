import 'package:flutter/material.dart';
import '../models/gate_event.dart';

class GateEventCard extends StatelessWidget {
  final GateEvent event;
  const GateEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final color = event.type == 'entry' ? Colors.green : Colors.grey;
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, child: Icon(event.type == 'entry' ? Icons.login : Icons.logout)),
        title: Text(event.visitorName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${event.gate} • ${event.guard}'),
        trailing: Text('${event.time.hour.toString().padLeft(2,'0')}:${event.time.minute.toString().padLeft(2,'0')}'),
      ),
    );
  }
}
