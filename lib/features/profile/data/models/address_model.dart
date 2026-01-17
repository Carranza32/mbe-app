/// Modelo de dirección basado en la estructura de la API
class AddressModel {
  final int id;
  final String name;
  final String countryCode;
  final String country;
  final String regionCode;
  final String region;
  final String cityCode;
  final String city;
  final String address;
  final String phone;
  final bool isDefault;
  
  // Campos opcionales
  final String? localityCode;
  final String? locality;
  final String? references;
  final double? latitude;
  final double? longitude;

  AddressModel({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.country,
    required this.regionCode,
    required this.region,
    required this.cityCode,
    required this.city,
    required this.address,
    required this.phone,
    required this.isDefault,
    this.localityCode,
    this.locality,
    this.references,
    this.latitude,
    this.longitude,
  });

  /// Helper para parsear double desde string o num
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  /// Crear desde JSON (respuesta de la API)
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int,
      name: json['name'] as String,
      countryCode: json['country_code']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      regionCode: json['region_code']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
      cityCode: json['city_code']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      address: json['address'] as String,
      phone: json['phone'] as String,
      isDefault: json['is_default'] as bool? ?? false,
      localityCode: json['locality_code']?.toString(),
      locality: json['locality']?.toString(),
      references: json['references'] as String?,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
    );
  }

  /// Convertir a JSON para enviar a la API
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'country_code': countryCode,
      'country': country,
      'region_code': regionCode,
      'region': region,
      'city_code': cityCode,
      'city': city,
      'address': address,
      'phone': phone,
      'is_default': isDefault,
    };

    if (localityCode != null) json['locality_code'] = localityCode;
    if (locality != null) json['locality'] = locality;
    if (references != null) json['references'] = references;
    if (latitude != null) json['latitude'] = latitude;
    if (longitude != null) json['longitude'] = longitude;

    return json;
  }

  /// Crear una copia con algunos campos modificados
  AddressModel copyWith({
    int? id,
    String? name,
    String? countryCode,
    String? country,
    String? regionCode,
    String? region,
    String? cityCode,
    String? city,
    String? address,
    String? phone,
    bool? isDefault,
    String? localityCode,
    String? locality,
    String? references,
    double? latitude,
    double? longitude,
  }) {
    return AddressModel(
      id: id ?? this.id,
      name: name ?? this.name,
      countryCode: countryCode ?? this.countryCode,
      country: country ?? this.country,
      regionCode: regionCode ?? this.regionCode,
      region: region ?? this.region,
      cityCode: cityCode ?? this.cityCode,
      city: city ?? this.city,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
      localityCode: localityCode ?? this.localityCode,
      locality: locality ?? this.locality,
      references: references ?? this.references,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  /// Obtener una representación legible de la ubicación
  String get fullLocation {
    final parts = <String>[];
    if (locality != null) parts.add(locality!);
    parts.add(city);
    parts.add(region);
    return parts.join(', ');
  }

  /// Obtener coordenadas como string (si existen)
  String? get coordinatesString {
    if (latitude != null && longitude != null) {
      return '$latitude, $longitude';
    }
    return null;
  }
}

