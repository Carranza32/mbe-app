/// Estado/departamento Boxful con sus ciudades. Respuesta de GET /boxful/states
class BoxfulState {
  final String id;
  final String name;
  final List<BoxfulCity> cities;

  BoxfulState({required this.id, required this.name, this.cities = const []});

  factory BoxfulState.fromJson(Map<String, dynamic> json) {
    final citiesJson = json['cities'] as List<dynamic>? ?? json['Cities'] as List<dynamic>? ?? [];
    return BoxfulState(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] as String? ?? json['label'] as String? ?? '',
      cities: citiesJson
          .map((c) => BoxfulCity.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Ciudad Boxful dentro de un estado
class BoxfulCity {
  final String id;
  final String name;

  BoxfulCity({required this.id, required this.name});

  factory BoxfulCity.fromJson(Map<String, dynamic> json) {
    return BoxfulCity(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] as String? ?? json['label'] as String? ?? '',
    );
  }
}
