/// Modelo de tienda para el módulo admin (listado de tiendas accesibles).
/// Respuesta de GET /api/v1/admin/stores
class AdminStoreModel {
  final int id;
  final String name;
  final String? code;
  final String? email;
  final String? phone;
  final String? address;
  final AdminStoreCountry? country;
  final bool isActive;

  AdminStoreModel({
    required this.id,
    required this.name,
    this.code,
    this.email,
    this.phone,
    this.address,
    this.country,
    this.isActive = true,
  });

  factory AdminStoreModel.fromJson(Map<String, dynamic> json) {
    return AdminStoreModel(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      country: json['country'] != null
          ? AdminStoreCountry.fromJson(
              json['country'] as Map<String, dynamic>,
            )
          : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class AdminStoreCountry {
  final int id;
  final String name;
  final String? code;

  AdminStoreCountry({
    required this.id,
    required this.name,
    this.code,
  });

  factory AdminStoreCountry.fromJson(Map<String, dynamic> json) {
    return AdminStoreCountry(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String?,
    );
  }
}
