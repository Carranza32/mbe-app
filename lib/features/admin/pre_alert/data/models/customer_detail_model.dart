import 'customer_address_model.dart';

/// Cliente con direcciones (respuesta de GET pre-alert/{id} o by-locker-code).
class CustomerDetail {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? lockerCode;
  final List<CustomerAddress> addresses;

  CustomerDetail({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.lockerCode,
    this.addresses = const [],
  });

  factory CustomerDetail.fromJson(Map<String, dynamic> json) {
    final addressesJson = json['addresses'] as List<dynamic>? ?? [];
    return CustomerDetail(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? json['full_name'] as String? ?? '',
      email: _stringFromJson(json['email']),
      phone: _stringFromJson(json['phone']),
      lockerCode: json['locker_code'] as String? ?? json['code'] as String?,
      addresses: addressesJson
          .map((e) => CustomerAddress.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static String? _stringFromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    if (value is num) return value.toString();
    return value.toString();
  }

  CustomerAddress? get defaultAddress =>
      addresses.cast<CustomerAddress?>().firstWhere(
            (a) => a?.isDefault == true,
            orElse: () => addresses.isNotEmpty ? addresses.first : null,
          );
}
