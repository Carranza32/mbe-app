class User {
  final int id;
  final String email;
  final String name;
  final String role;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role_name'] as String? ?? 'customer',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name, 'role': role};
  }

  bool get isAdmin =>
      role == 'admin' || role == 'super_admin' || role == 'admin_orders';
  bool get isCustomer => role == 'customer';
}
