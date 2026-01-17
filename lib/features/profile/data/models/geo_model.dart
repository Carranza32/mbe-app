/// Modelo para respuestas de geo (ADM1, ADM2, ADM3)
class GeoOption {
  final String code;
  final String label;

  GeoOption({
    required this.code,
    required this.label,
  });

  factory GeoOption.fromJson(Map<String, dynamic> json) {
    // La API puede devolver 'code' como número o string, o usar 'id' como fallback
    String code;
    if (json['code'] != null) {
      code = json['code'].toString();
    } else if (json['id'] != null) {
      code = json['id'].toString();
    } else {
      code = '';
    }
    
    // La API devuelve 'name' para el nombre
    final label = json['name'] as String? ?? 
                  json['label'] as String? ?? 
                  '';
    
    return GeoOption(
      code: code,
      label: label,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'label': label,
    };
  }
}

/// Respuesta de la API para geo
class GeoResponse {
  final List<GeoOption> results;

  GeoResponse({required this.results});

  factory GeoResponse.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as List<dynamic>? ?? [];
    return GeoResponse(
      results: results
          .map((item) => GeoOption.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

