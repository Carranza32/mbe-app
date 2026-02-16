import 'package:mbe_orders_app/core/network/api_endpoints.dart';
import 'package:mbe_orders_app/core/network/api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';
import '../models/email_check_response.dart';

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

  /// Registro de nuevo usuario o activación legacy
  /// - Si [passwordSetToken] viene (legacy): backend activa cuenta y hace login
  /// - Casillero (locker_code) no se pide ni se envía en el flujo de activación.
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? passwordSetToken,
    String? country,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'email': email.trim(),
      'phone': phone.trim(),
      'password': password,
      'password_confirmation': passwordConfirmation,
    };

    // Activación legacy: enviar password_set_token (token de verify-otp)
    // No se envía verification_code
    if (passwordSetToken != null && passwordSetToken.isNotEmpty) {
      data['password_set_token'] = passwordSetToken.trim();
    }

    if (country != null && country.isNotEmpty) {
      data['country'] = country;
    }

    return await _apiService.post<AuthResponse>(
      endpoint: ApiEndpoints.register,
      data: data,
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
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
      fromJson: (json) {
        // El api_service puede extraer el campo 'user' de la respuesta
        // Necesitamos manejar ambos casos: cuando viene directamente y cuando viene envuelto
        
        // Si json es null, lanzar error
        if (json == null) {
          throw Exception('Respuesta vacía del servidor');
        }
        
        // Si json es un Map, verificar si tiene el campo 'user'
        if (json is Map<String, dynamic>) {
          // Si tiene el campo 'user', extraerlo
          if (json.containsKey('user') && json['user'] != null) {
            final userData = json['user'];
            if (userData is Map<String, dynamic>) {
              return User.fromJson(userData);
            }
            throw Exception('El campo "user" no es un objeto válido');
          }
          // Si no tiene 'user', asumir que json ya es el objeto user
          return User.fromJson(json);
        }
        
        throw Exception('Formato de respuesta inválido para getCurrentUser: ${json.runtimeType}');
      },
    );
  }

  /// Actualizar perfil del usuario
  Future<User> updateProfile({required String name, String? phone}) async {
    final data = <String, dynamic>{'name': name};
    if (phone != null && phone.isNotEmpty) {
      data['phone'] = phone;
    }

    return await _apiService.put<User>(
      endpoint: ApiEndpoints.updateProfile,
      data: data,
      fromJson: (json) => User.fromJson(json['user'] ?? json),
    );
  }

  /// Actualizar perfil del customer (para completar perfil)
  Future<User> updateCustomerProfile({
    required String phone,
    String? homePhone,
    String? documentType,
    String? documentNumber,
    String? name,
    String? email,
    String? officePhone,
    DateTime? birthDate,
  }) async {
    final data = <String, dynamic>{'phone': phone};

    // Campos del formulario
    if (homePhone != null && homePhone.isNotEmpty) {
      data['home_phone'] = homePhone;
    }

    if (documentType != null && documentType.isNotEmpty) {
      data['document_type'] = documentType;
    }

    if (documentNumber != null && documentNumber.isNotEmpty) {
      data['cedula_rnc'] = documentNumber;
    }

    // Campos del customer actual (si se proporcionan)
    if (name != null && name.isNotEmpty) {
      data['name'] = name;
    }

    if (email != null && email.isNotEmpty) {
      data['email'] = email;
    }

    if (officePhone != null && officePhone.isNotEmpty) {
      data['office_phone'] = officePhone;
    }

    if (birthDate != null) {
      // Formatear fecha como YYYY-MM-DD
      data['birth_date'] = birthDate.toIso8601String().split('T')[0];
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

  /// Verificar si un correo existe en la base de datos
  Future<EmailCheckResponse> checkEmail({
    required String email,
    String? lockerCode,
  }) async {
    final data = <String, dynamic>{
      'email': email.trim(),
    };

    if (lockerCode != null && lockerCode.isNotEmpty) {
      // Normalizar locker_code
      String normalizedLockerCode = lockerCode.trim().toUpperCase();
      if (!normalizedLockerCode.startsWith('SAL')) {
        normalizedLockerCode = 'SAL$normalizedLockerCode';
      }
      data['locker_code'] = normalizedLockerCode;
    }

    return await _apiService.post<EmailCheckResponse>(
      endpoint: ApiEndpoints.checkEmail,
      data: data,
      fromJson: (json) => EmailCheckResponse.fromJson(json),
    );
  }

  /// Enviar código de activación para usuario nuevo
  Future<Map<String, dynamic>> sendActivationCode({
    required String email,
  }) async {
    return await _apiService.post<Map<String, dynamic>>(
      endpoint: ApiEndpoints.sendActivationCode,
      data: {'email': email.trim()},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Verificar OTP cuando el usuario no está logueado (flujo email-entry → OTP)
  /// Usado para usuarios nuevos y legacy. Backend espera el campo "otp".
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String code,
  }) async {
    return await _apiService.post<Map<String, dynamic>>(
      endpoint: ApiEndpoints.verifyOtp,
      data: {'email': email.trim(), 'otp': code.trim()},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Crear contraseña para usuario legacy (tras verificar OTP)
  Future<Map<String, dynamic>> setPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await _apiService.post<Map<String, dynamic>>(
      endpoint: ApiEndpoints.setPassword,
      data: {
        'email': email.trim(),
        'code': code.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Solicitar recuperación de contraseña
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    return await _apiService.post<Map<String, dynamic>>(
      endpoint: ApiEndpoints.forgotPassword,
      data: {'email': email.trim()},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Restablecer contraseña con token
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await _apiService.post<Map<String, dynamic>>(
      endpoint: ApiEndpoints.resetPassword,
      data: {
        'email': email.trim(),
        'token': token.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}

/// Provider del repository - Se genera automáticamente
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(apiServiceProvider));
}
