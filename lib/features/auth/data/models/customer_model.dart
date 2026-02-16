// lib/features/auth/data/models/customer_model.dart
class Customer {
  final int id;
  final int userId;
  final String name;
  final String email;
  final String lockerCode;
  final DateTime? verifiedAt;
  final String country;
  final int storeId;
  final int? customerTierId;
  final String? tierName;
  final String language;
  final String? secondaryEmail;
  final String? cedulaRnc;
  final String? documentType;
  final String? address;
  final DateTime? birthDate;
  final String? phone;
  final String? homePhone;
  final String? officePhone;
  final String? fax;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? createdBy;
  final int? updatedBy;
  final int? deletedBy;

  Customer({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.lockerCode,
    this.verifiedAt,
    required this.country,
    required this.storeId,
    this.customerTierId,
    this.tierName,
    required this.language,
    this.secondaryEmail,
    this.cedulaRnc,
    this.documentType,
    this.address,
    this.birthDate,
    this.phone,
    this.homePhone,
    this.officePhone,
    this.fax,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      lockerCode: json['locker_code'] as String? ?? '',
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      country: json['country'] as String? ?? '',
      storeId: json['store_id'] as int? ?? 0,
      customerTierId: json['customer_tier_id'] as int?,
      // Intentar obtener tier_name de diferentes formas posibles
      tierName: json['tier_name'] as String? ??
          (json['customer_tier'] is Map
              ? (json['customer_tier'] as Map<String, dynamic>)['name'] as String?
              : null) ??
          (json['tier'] is Map
              ? (json['tier'] as Map<String, dynamic>)['name'] as String?
              : null),
      language: json['language'] as String? ?? 'es',
      secondaryEmail: json['secundary_email'] as String?,
      cedulaRnc: json['cedula_rnc'] as String?,
      documentType: json['document_type'] as String?,
      address: json['address'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      phone: json['phone'] as String?,
      homePhone: json['home_phone'] as String?,
      officePhone: json['office_phone'] as String?,
      fax: json['fax'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      createdBy: json['created_by'] as int?,
      updatedBy: json['updated_by'] as int?,
      deletedBy: json['deleted_by'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'locker_code': lockerCode,
      'verified_at': verifiedAt?.toIso8601String(),
      'country': country,
      'store_id': storeId,
      'customer_tier_id': customerTierId,
      'tier_name': tierName,
      'language': language,
      'secundary_email': secondaryEmail,
      'cedula_rnc': cedulaRnc,
      'document_type': documentType,
      'address': address,
      'birth_date': birthDate?.toIso8601String(),
      'phone': phone,
      'home_phone': homePhone,
      'office_phone': officePhone,
      'fax': fax,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'created_by': createdBy,
      'updated_by': updatedBy,
      'deleted_by': deletedBy,
    };
  }
}
