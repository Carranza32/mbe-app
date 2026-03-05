/// Dirección del cliente (customer.addresses en respuestas de pre-alert).
class CustomerAddress {
  final int id;
  final String address;
  final String? city;
  final String? region;
  final bool isDefault;
  /// MongoDB ObjectId (ej. "64a302eae2212e31584a819f")
  final String? boxfulStateId;
  /// MongoDB ObjectId (ej. "64a30323e16d1dbcc073b5da")
  final String? boxfulCityId;
  final String? boxfulLockerId;
  /// Nombre/alias de la dirección (ej. "Principal", "prueba")
  final String? name;
  /// Teléfono de la dirección
  final String? phone;
  /// Código Geo del departamento (ej. "11")
  final String? regionCode;
  /// Código Geo del municipio (ej. "12954164")
  final String? cityCode;
  /// Código Geo del distrito/subzona nivel 3 (ej. "3583331")
  final String? localityCode;
  /// Nombre del distrito/subzona (ej. "Santa Ana")
  final String? locality;
  final String? countryCode;
  final String? country;
  final String? references;

  CustomerAddress({
    required this.id,
    required this.address,
    this.city,
    this.region,
    this.isDefault = false,
    this.boxfulStateId,
    this.boxfulCityId,
    this.boxfulLockerId,
    this.name,
    this.phone,
    this.regionCode,
    this.cityCode,
    this.localityCode,
    this.locality,
    this.countryCode,
    this.country,
    this.references,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      id: (json['id'] as num?)?.toInt() ?? 0,
      address: json['address'] as String? ?? '',
      city: json['city'] as String?,
      region: json['region'] as String?,
      isDefault: json['is_default'] == true || json['is_default'] == 1,
      boxfulStateId: _stringFromJson(json['boxful_state_id']),
      boxfulCityId: _stringFromJson(json['boxful_city_id']),
      boxfulLockerId: json['boxful_locker_id'] as String?,
      name: json['name'] as String?,
      phone: json['phone']?.toString(),
      regionCode: _stringFromJson(json['region_code']),
      cityCode: _stringFromJson(json['city_code']),
      localityCode: _stringFromJson(json['locality_code']),
      locality: json['locality'] as String?,
      countryCode: json['country_code'] as String?,
      country: json['country'] as String?,
      references: json['references'] as String?,
    );
  }

  static String? _stringFromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    if (value is num) return value.toString();
    return value.toString();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'address': address,
        'city': city,
        'region': region,
        'is_default': isDefault,
        'boxful_state_id': boxfulStateId,
        'boxful_city_id': boxfulCityId,
        'boxful_locker_id': boxfulLockerId,
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (regionCode != null) 'region_code': regionCode,
        if (cityCode != null) 'city_code': cityCode,
        if (localityCode != null) 'locality_code': localityCode,
        if (locality != null) 'locality': locality,
        if (references != null) 'references': references,
      };

  /// Texto corto para mostrar en listas (ej. "Principal: Calle X, Ciudad").
  String get displayShort {
    final parts = <String>[];
    if (name != null && name!.isNotEmpty) parts.add(name!);
    parts.add(address);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    return parts.join(' · ');
  }
}
