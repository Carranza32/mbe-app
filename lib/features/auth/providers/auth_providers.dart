import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_model.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_provider.dart';

part 'auth_providers.g.dart';

/// Estado de autenticación
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Provider del estado de autenticación usando Riverpod Generator
@riverpod
class Auth extends _$Auth {
  late final AuthRepository _authRepository;
  late final FlutterSecureStorage _storage;

  @override
  AuthState build() {
    _authRepository = ref.read(authRepositoryProvider);
    _storage = ref.read(secureStorageProvider);
    return AuthState();
  }

  /// Login con email y contraseña
  Future<bool> loginWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authRepository.loginWithEmail(
        email: email,
        password: password,
      );

      // Guardar el token (asumiendo que viene en la respuesta)
      // await _storage.write(key: 'auth_token', value: token);

      state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      );

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    }
  }

  /// Login con Google
  Future<bool> loginWithGoogle(String googleToken) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authRepository.loginWithGoogle(
        googleToken: googleToken,
      );

      state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      );

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    try {
      await _authRepository.logout();
      await _storage.delete(key: 'auth_token');
      state = AuthState();
    } catch (e) {
      // Limpiar sesión local aunque falle la petición
      await _storage.delete(key: 'auth_token');
      state = AuthState();
    }
  }

  /// Verificar si hay sesión activa
  Future<void> checkAuthStatus() async {
    final token = await _storage.read(key: 'auth_token');
    
    if (token != null) {
      try {
        final user = await _authRepository.getCurrentUser();
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
        );
      } catch (e) {
        // Token inválido o expirado
        await _storage.delete(key: 'auth_token');
        state = AuthState();
      }
    }
  }
}

// El provider authProvider se genera automáticamente como:
// final authProvider = AuthProvider();