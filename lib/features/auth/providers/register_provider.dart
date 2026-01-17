// lib/features/auth/providers/register_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'register_provider.g.dart';

class RegisterState {
  final String name;
  final String email;
  final String lockerCode;
  final String password;
  final String passwordConfirmation;
  
  // Errores de validación del servidor
  final Map<String, String> errors;

  RegisterState({
    this.name = '',
    this.email = '',
    this.lockerCode = '',
    this.password = '',
    this.passwordConfirmation = '',
    this.errors = const {},
  });

  RegisterState copyWith({
    String? name,
    String? email,
    String? lockerCode,
    String? password,
    String? passwordConfirmation,
    Map<String, String>? errors,
  }) {
    return RegisterState(
      name: name ?? this.name,
      email: email ?? this.email,
      lockerCode: lockerCode ?? this.lockerCode,
      password: password ?? this.password,
      passwordConfirmation: passwordConfirmation ?? this.passwordConfirmation,
      errors: errors ?? this.errors,
    );
  }

  bool get passwordsMatch => password == passwordConfirmation && passwordConfirmation.isNotEmpty;
  
  bool get isPasswordValid {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  bool get isValid {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        lockerCode.isNotEmpty &&
        password.isNotEmpty &&
        passwordConfirmation.isNotEmpty &&
        passwordsMatch &&
        isPasswordValid;
  }

  /// Normaliza el locker_code: agrega prefijo SAL si no lo tiene y convierte a mayúsculas
  String get normalizedLockerCode {
    String code = lockerCode.trim().toUpperCase();
    if (!code.startsWith('SAL')) {
      code = 'SAL$code';
    }
    return code;
  }
}

@riverpod
class Register extends _$Register {
  @override
  RegisterState build() => RegisterState();

  void setName(String value) => state = state.copyWith(name: value, errors: _removeError('name'));
  void setEmail(String value) => state = state.copyWith(email: value, errors: _removeError('email'));
  void setLockerCode(String value) => state = state.copyWith(lockerCode: value, errors: _removeError('locker_code'));
  void setPassword(String value) => state = state.copyWith(password: value, errors: _removeError('password'));
  void setPasswordConfirmation(String value) => state = state.copyWith(passwordConfirmation: value, errors: _removeError('password_confirmation'));

  void setErrors(Map<String, dynamic> serverErrors) {
    final Map<String, String> formattedErrors = {};
    serverErrors.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        formattedErrors[key] = value.first.toString();
      } else if (value is String) {
        formattedErrors[key] = value;
      }
    });
    state = state.copyWith(errors: formattedErrors);
  }

  void clearErrors() => state = state.copyWith(errors: {});

  Map<String, String> _removeError(String key) {
    final newErrors = Map<String, String>.from(state.errors);
    newErrors.remove(key);
    return newErrors;
  }

  void reset() => state = RegisterState();
}