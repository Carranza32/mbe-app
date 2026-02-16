// lib/features/auth/data/models/auth_response.dart
import 'user_model.dart';

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    final userJson = json['user'];
    if (token == null || userJson == null || userJson is! Map<String, dynamic>) {
      throw FormatException('AuthResponse: falta token o user. Keys: ${json.keys}');
    }
    return AuthResponse(
      token: token is String ? token : token.toString(),
      user: User.fromJson(userJson),
    );
  }
}