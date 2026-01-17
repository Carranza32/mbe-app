/// Modelo de tienda para pre-alertas
class StoreModel {
  final int id;
  final String name;
  final String? address;
  final String? phone;
  final String? zone;

  StoreModel({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.zone,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      zone: json['zone'] as String?,
    );
  }
}
