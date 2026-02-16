import 'customer_model.dart';

class User {
  final int id;
  final String email;
  final String name;
  final String role;
  final DateTime? emailVerifiedAt;
  final String? verificationCode;
  final Customer? customer;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.emailVerifiedAt,
    this.verificationCode,
    this.customer,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role_name'] as String? ?? 'customer',
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
      verificationCode: json['verification_code'] as String?,
      customer: json['customer'] != null && json['customer'] is Map<String, dynamic>
          ? Customer.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'verification_code': verificationCode,
      'customer': customer?.toJson(),
    };
  }

  bool get isAdmin =>
      role == 'admin' || role == 'super_admin' || role == 'admin_orders';
  bool get isCustomer => role == 'customer';
  bool get isEmailVerified => emailVerifiedAt != null;
}
