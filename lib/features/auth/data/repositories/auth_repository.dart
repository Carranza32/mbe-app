import 'package:mbe_orders_app/core/network/api_endpoints.dart';
import 'package:mbe_orders_app/core/network/api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  /// Login con email y contraseña
  Future<AuthResponse> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await _apiService.post<AuthResponse>(
      endpoint: ApiEndpoints.login,
      data: {'email': email, 'password': password},
      fromJson: (json) => AuthResponse.fromJson(json),
    );
  }

  /// Registro de nuevo usuario
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String lockerCode,
    required String password,
    required String passwordConfirmation,
    String? country,
  }) async {
    // Normalizar locker_code: agregar prefijo SAL si no lo tiene y convertir a mayúsculas
    String normalizedLockerCode = lockerCode.trim().toUpperCase();
    if (!normalizedLockerCode.startsWith('SAL')) {
      normalizedLockerCode = 'SAL$normalizedLockerCode';
    }

    final data = <String, dynamic>{
      'name': name,
      'email': email.trim(),
      'locker_code': normalizedLockerCode,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };

    if (country != null && country.isNotEmpty) {
      data['country'] = country;
    }

    return await _apiService.post<AuthResponse>(
      endpoint: ApiEndpoints.register,
      data: data,
      fromJson: (json) => AuthResponse.fromJson(json),
    );
  }

  /// Login con Google
  Future<User> loginWithGoogle({required String googleToken}) async {
    return await _apiService.post<User>(
      endpoint: '/auth/google',
      data: {'token': googleToken},
      fromJson: (json) => User.fromJson(json),
    );
  }

  /// Obtener perfil del usuario actual
  Future<User> getCurrentUser() async {
    return await _apiService.get<User>(
      endpoint: ApiEndpoints.profile,
      fromJson: (json) => User.fromJson(json['user']),
    );
  }

  /// Actualizar perfil del usuario
  Future<User> updateProfile({
    required String name,
    String? phone,
  }) async {
    final data = <String, dynamic>{
      'name': name,
    };
    if (phone != null && phone.isNotEmpty) {
      data['phone'] = phone;
    }

    return await _apiService.put<User>(
      endpoint: ApiEndpoints.updateProfile,
      data: data,
      fromJson: (json) => User.fromJson(json['user'] ?? json),
    );
  }

  /// Cambiar contraseña
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiService.post<Map<String, dynamic>>(
      endpoint: ApiEndpoints.changePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
      },
      fromJson: (json) => json,
    );
  }

  /// Verificar código de email
  Future<User> verifyCode(String code) async {
    return await _apiService.post<User>(
      endpoint: ApiEndpoints.verifyCode,
      data: {'code': code},
      fromJson: (json) {
        // El ApiService ya extrae el campo 'user' si existe
        // pero por si acaso, también verificamos aquí
        if (json is Map<String, dynamic> && json.containsKey('user')) {
          return User.fromJson(json['user'] as Map<String, dynamic>);
        }
        return User.fromJson(json as Map<String, dynamic>);
      },
    );
  }

  /// Reenviar código de verificación
  Future<Map<String, dynamic>> resendVerificationCode() async {
    return await _apiService.post<Map<String, dynamic>>(
      endpoint: ApiEndpoints.resendVerificationCode,
      data: {},
      fromJson: (json) => json as Map<String, dynamic>,
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
