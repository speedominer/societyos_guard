class GateEvent {
  final String id;
  final String visitorName;
  final String type; // entry/exit
  final String gate;
  final String guard;
  final DateTime time;

  GateEvent({required this.id, required this.visitorName, required this.type, required this.gate, required this.guard, required this.time});

  factory GateEvent.fromJson(Map<String, dynamic> j) => GateEvent(
    id: j['id']?.toString() ?? '',
    visitorName: j['visitor']?['name'] ?? j['name'] ?? '',
    type: j['type'] ?? 'entry',
    gate: j['gate'] ?? '',
    guard: j['guard'] ?? '',
    time: DateTime.tryParse(j['timestamp'] ?? j['time'] ?? '') ?? DateTime.now(),
  );
}
