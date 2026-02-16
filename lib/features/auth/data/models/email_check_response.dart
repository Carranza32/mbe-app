// lib/features/auth/data/models/email_check_response.dart
/// Respuesta del endpoint POST /v1/auth/check-email (check-status).
/// Backend devuelve status según el tipo de usuario.
class EmailCheckResponse {
  final bool exists;
  final bool isActivated;
  final bool hasLocker;
  final String message;
  /// status del backend: 'active_user' | 'legacy_user' | 'new_user'
  final String status;
  /// true si el usuario ya tiene login en la web (tiene contraseña / web_last_login)
  final bool hasWebLogin;

  EmailCheckResponse({
    required this.exists,
    required this.isActivated,
    required this.hasLocker,
    required this.message,
    this.status = 'active_user',
    this.hasWebLogin = false,
  });

  factory EmailCheckResponse.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String? ?? 'active_user';
    final existsFromJson = json['exists'] as bool?;
    final exists = existsFromJson ?? (status == 'active_user' || status == 'legacy_user');
    return EmailCheckResponse(
      exists: exists,
      isActivated: json['is_activated'] as bool? ?? false,
      hasLocker: json['has_locker'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      status: status,
      hasWebLogin: json['has_web_login'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exists': exists,
      'is_activated': isActivated,
      'has_locker': hasLocker,
      'message': message,
      'status': status,
      'has_web_login': hasWebLogin,
    };
  }

  /// Usuario ya registrado en la app (tiene contraseña) → mostrar solo campo contraseña y login
  bool get isActiveUser => status == 'active_user';
  /// Usuario importado (casillero, nunca entró a la app) → OTP ya enviado por backend, luego crear contraseña
  bool get isLegacyUser => status == 'legacy_user';
  /// Usuario nuevo (no existe) → Flutter llama send-activation-code, luego OTP y registro
  bool get isNewUser => status == 'new_user';
}
