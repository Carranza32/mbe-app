import 'package:mbe_orders_app/core/network/api_endpoints.dart';
import 'package:mbe_orders_app/core/network/api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user_model.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  /// Login con email y contraseña
  Future<User> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await _apiService.post<User>(
      endpoint: ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
      fromJson: (json) => User.fromJson(json),
    );
  }

  /// Login con Google
  Future<User> loginWithGoogle({required String googleToken}) async {
    return await _apiService.post<User>(
      endpoint: '/auth/google',
      data: {
        'token': googleToken,
      },
      fromJson: (json) => User.fromJson(json),
    );
  }

  /// Obtener perfil del usuario actual
  Future<User> getCurrentUser() async {
    return await _apiService.get<User>(
      endpoint: ApiEndpoints.profile,
      fromJson: (json) => User.fromJson(json),
    );
  }

  /// Cerrar sesión
  Future<void> logout() async {
    await _apiService.post<Map<String, dynamic>>(
      endpoint: ApiEndpoints.logout,
      data: {},
      fromJson: (json) => json,
    );
  }
}

/// Provider del repository - Se genera automáticamente
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(apiServiceProvider));
}