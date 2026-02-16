// lib/features/auth/providers/forgot_password_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/auth_repository.dart';

part 'forgot_password_provider.g.dart';

class ForgotPasswordState {
  final String email;
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  ForgotPasswordState({
    this.email = '',
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  ForgotPasswordState copyWith({
    String? email,
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }
}

@riverpod
class ForgotPassword extends _$ForgotPassword {
  @override
  ForgotPasswordState build() => ForgotPasswordState();

  void setEmail(String value) {
    state = state.copyWith(email: value, error: null);
  }

  /// Solicitar recuperación de contraseña
  Future<void> requestPasswordReset() async {
    if (state.email.isEmpty) {
      throw Exception('El correo electrónico es requerido');
    }

    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.forgotPassword(email: state.email);

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void reset() {
    state = ForgotPasswordState();
  }
}
