/// Modelo de Usuario
class User {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      photoUrl: json['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      if (photoUrl != null) 'photo_url': photoUrl,
    };
  }
}