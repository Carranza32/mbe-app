/// Elemento de la lista GET /boxful/lockers?city_id=XXX
class BoxfulLocker {
  final String id;
  final String name;

  BoxfulLocker({required this.id, required this.name});

  factory BoxfulLocker.fromJson(Map<String, dynamic> json) {
    return BoxfulLocker(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] as String? ??
          json['label'] as String? ??
          json['address'] as String? ??
          json['id']?.toString() ??
          '',
    );
  }
}
