// lib/features/auth/providers/reset_password_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/auth_repository.dart';

part 'reset_password_provider.g.dart';

class ResetPasswordState {
  final String email;
  final String token;
  final String password;
  final String passwordConfirmation;
  final bool isLoading;
  final bool isSuccess;
  final Map<String, String> errors;

  ResetPasswordState({
    this.email = '',
    this.token = '',
    this.password = '',
    this.passwordConfirmation = '',
    this.isLoading = false,
    this.isSuccess = false,
    this.errors = const {},
  });

  ResetPasswordState copyWith({
    String? email,
    String? token,
    String? password,
    String? passwordConfirmation,
    bool? isLoading,
    bool? isSuccess,
    Map<String, String>? errors,
  }) {
    return ResetPasswordState(
      email: email ?? this.email,
      token: token ?? this.token,
      password: password ?? this.password,
      passwordConfirmation: passwordConfirmation ?? this.passwordConfirmation,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errors: errors ?? this.errors,
    );
  }

  bool get passwordsMatch =>
      password == passwordConfirmation && passwordConfirmation.isNotEmpty;

  bool get isPasswordValid {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  bool get isValid {
    return email.isNotEmpty &&
        token.isNotEmpty &&
        password.isNotEmpty &&
        passwordConfirmation.isNotEmpty &&
        passwordsMatch &&
        isPasswordValid;
  }
}

@riverpod
class ResetPassword extends _$ResetPassword {
  @override
  ResetPasswordState build() => ResetPasswordState();

  void setEmail(String value) {
    state = state.copyWith(email: value, errors: _removeError('email'));
  }

  void setToken(String value) {
    state = state.copyWith(token: value, errors: _removeError('token'));
  }

  void setPassword(String value) {
    state = state.copyWith(password: value, errors: _removeError('password'));
  }

  void setPasswordConfirmation(String value) {
    state = state.copyWith(
      passwordConfirmation: value,
      errors: _removeError('password_confirmation'),
    );
  }

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

  /// Restablecer contraseña
  Future<void> resetPassword() async {
    if (!state.isValid) {
      throw Exception('Por favor, completa todos los campos correctamente');
    }

    state = state.copyWith(isLoading: true, isSuccess: false);
    clearErrors();

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.resetPassword(
        email: state.email,
        token: state.token,
        password: state.password,
        passwordConfirmation: state.passwordConfirmation,
      );

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
      );
      rethrow;
    }
  }

  void reset() {
    state = ResetPasswordState();
  }
}
