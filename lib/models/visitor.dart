class Visitor {
  final String id;
  final String name;
  final String phone;
  final String? company;
  final String purpose;
  final String flatId;

  Visitor(
      {required this.id,
      required this.name,
      required this.phone,
      this.company,
      required this.purpose,
      required this.flatId});

  factory Visitor.fromJson(Map<String, dynamic> j) => Visitor(
        id: j['id']?.toString() ?? '',
        name: j['name'] ?? '',
        phone: j['phone'] ?? '',
        company: j['company'],
        purpose: j['purpose'] ?? '',
        flatId: j['flatId'] ?? '',
      );
}
