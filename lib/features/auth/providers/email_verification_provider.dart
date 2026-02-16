// lib/features/auth/providers/email_verification_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/email_check_response.dart';

part 'email_verification_provider.g.dart';

class EmailVerificationState {
  final String email;
  final String? lockerCode;
  final bool isLoading;
  final EmailCheckResponse? checkResponse;
  final String? error;

  EmailVerificationState({
    this.email = '',
    this.lockerCode,
    this.isLoading = false,
    this.checkResponse,
    this.error,
  });

  EmailVerificationState copyWith({
    String? email,
    String? lockerCode,
    bool? isLoading,
    EmailCheckResponse? checkResponse,
    String? error,
  }) {
    return EmailVerificationState(
      email: email ?? this.email,
      lockerCode: lockerCode ?? this.lockerCode,
      isLoading: isLoading ?? this.isLoading,
      checkResponse: checkResponse ?? this.checkResponse,
      error: error,
    );
  }
}

@riverpod
class EmailVerification extends _$EmailVerification {
  @override
  EmailVerificationState build() => EmailVerificationState();

  void setEmail(String value) {
    state = state.copyWith(email: value, error: null);
  }

  void setLockerCode(String? value) {
    state = state.copyWith(lockerCode: value, error: null);
  }

  /// Verificar si el correo existe en la base de datos
  Future<EmailCheckResponse> checkEmail() async {
    if (state.email.isEmpty) {
      throw Exception('El correo electrónico es requerido');
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.checkEmail(
        email: state.email,
        lockerCode: state.lockerCode,
      );

      state = state.copyWith(
        isLoading: false,
        checkResponse: response,
      );

      return response;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Enviar código de activación
  Future<void> sendActivationCode() async {
    if (state.email.isEmpty) {
      throw Exception('El correo electrónico es requerido');
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.sendActivationCode(email: state.email);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void reset() {
    state = EmailVerificationState();
  }
}
