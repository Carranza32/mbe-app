// lib/features/auth/data/models/document_config_model.dart
class DocumentTypeConfig {
  final String code;
  final String name;
  final String format;
  final String regex;
  final int? length;
  final String description;

  DocumentTypeConfig({
    required this.code,
    required this.name,
    required this.format,
    required this.regex,
    this.length,
    required this.description,
  });

  factory DocumentTypeConfig.fromJson(Map<String, dynamic> json) {
    return DocumentTypeConfig(
      code: json['code'] as String,
      name: json['name'] as String,
      format: json['format'] as String,
      regex: json['regex'] as String,
      length: json['length'] as int?,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'format': format,
      'regex': regex,
      'length': length,
      'description': description,
    };
  }
}

class DocumentConfigs {
  final Map<String, List<DocumentTypeConfig>> configsByCountry;

  DocumentConfigs({required this.configsByCountry});

  factory DocumentConfigs.fromJson(Map<String, dynamic> json) {
    final configsByCountry = <String, List<DocumentTypeConfig>>{};
    
    json.forEach((countryCode, countryData) {
      // El backend envía: { "SV": { "types": [...] } }
      if (countryData is Map<String, dynamic>) {
        final typesData = countryData['types'];
        if (typesData is List) {
          configsByCountry[countryCode] = typesData
              .map((type) => DocumentTypeConfig.fromJson(type as Map<String, dynamic>))
              .toList();
        }
      } 
      // También soportar formato directo: { "SV": [...] } (por si acaso)
      else if (countryData is List) {
        configsByCountry[countryCode] = countryData
            .map((type) => DocumentTypeConfig.fromJson(type as Map<String, dynamic>))
            .toList();
      }
    });

    return DocumentConfigs(configsByCountry: configsByCountry);
  }

  /// Obtener tipos de documento para un país específico
  List<DocumentTypeConfig> getTypesForCountry(String countryCode) {
    return configsByCountry[countryCode] ?? configsByCountry['UNIVERSAL'] ?? [];
  }

  /// Obtener configuración de un tipo de documento específico para un país
  DocumentTypeConfig? getTypeConfig(String countryCode, String documentTypeCode) {
    final types = getTypesForCountry(countryCode);
    try {
      return types.firstWhere((type) => type.code == documentTypeCode);
    } catch (e) {
      return null;
    }
  }
}
