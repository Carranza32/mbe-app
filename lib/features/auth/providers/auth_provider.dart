// lib/features/auth/providers/auth_provider.dart
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/dio_provider.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  Future<User?> build() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(key: 'auth_token');
    
    if (token != null && token.isNotEmpty) {
      try {
        // Intentar obtener el usuario actual desde el servidor
        final user = await ref.read(authRepositoryProvider).getCurrentUser();
        return user;
      } catch (e) {
        // Si falla (token inválido/expirado), limpiar datos locales
        await storage.delete(key: 'auth_token');
        await storage.delete(key: 'user');
        return null;
      }
    }
    return null;
  }

  /// Login con email y contraseña
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {
      // Validación básica
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email y contraseña son requeridos');
      }
      
      // Llamar al repositorio
      final authResponse = await ref.read(authRepositoryProvider).loginWithEmail(
        email: email.trim(),
        password: password,
      );
      
      // Guardar token y usuario en secure storage
      final storage = ref.read(secureStorageProvider);
      await storage.write(key: 'auth_token', value: authResponse.token);
      await storage.write(key: 'user', value: jsonEncode(authResponse.user.toJson()));
      
      return authResponse.user;
    });
  }

  /// Cerrar sesión - Limpia token y estado
  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);
    
    try {
      // 1. Intentar llamar al backend para invalidar el token (opcional, no crítico)
      await ref.read(authRepositoryProvider).logout();
    } catch (e) {
      // Si falla el logout en el backend, continuar con limpieza local
      // Esto es importante para que el logout siempre funcione incluso sin conexión
    }
    
    // 2. SIEMPRE limpiar datos locales (crítico)
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'user');
    
    // 3. SIEMPRE actualizar estado a null para forzar rebuild
    state = const AsyncData(null);
    
    // 4. Invalidar el provider para forzar reconstrucción en el próximo acceso
    ref.invalidateSelf();
  }
}