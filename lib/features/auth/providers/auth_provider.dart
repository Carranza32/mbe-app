// lib/features/auth/providers/auth_provider.dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/services/app_preferences.dart';
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
        // Si falla, verificar si es un error de autenticación (401) o un error temporal
        // Solo limpiar el token si es un error 401 (no autorizado)
        // Para otros errores (red, servidor, etc.), mantener el token y usuario en storage
        print('⚠️ Error al obtener usuario actual: $e');
        
        // Intentar leer el usuario desde storage como fallback
        final userJson = await storage.read(key: 'user');
        if (userJson != null) {
          try {
            final userData = jsonDecode(userJson) as Map<String, dynamic>;
            return User.fromJson(userData);
          } catch (_) {
            // Si no se puede parsear el usuario desde storage, solo entonces limpiar
            await storage.delete(key: 'auth_token');
            await storage.delete(key: 'user');
            return null;
          }
        }
        
        // Si no hay usuario en storage y hay error, limpiar todo
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
      
      // Verificar que el provider aún está montado
      if (!ref.mounted) {
        throw Exception('Provider disposed during login');
      }
      
      // Guardar token y usuario en secure storage
      final storage = ref.read(secureStorageProvider);
      await storage.write(key: 'auth_token', value: authResponse.token);
      await storage.write(key: 'user', value: jsonEncode(authResponse.user.toJson()));
      
      // Guardar customer si existe
      if (authResponse.user.customer != null) {
        await storage.write(
          key: 'customer',
          value: jsonEncode(authResponse.user.customer!.toJson()),
        );
      }

      // Marcar que ya usó la app en este dispositivo (para no mostrar portero tras logout)
      await setHasUsedAppOnThisDevice(true);
      
      // Verificar nuevamente antes de retornar
      if (!ref.mounted) {
        throw Exception('Provider disposed during login');
      }
      
      return authResponse.user;
    });
  }

  /// Guardar auth tras login o registro/activación (misma lógica que login).
  /// [storage] opcional: pasar si se llama desde widget con await previo (ref puede estar disposed).
  Future<void> setAuthData(String token, User user, {FlutterSecureStorage? storage}) async {
    final FlutterSecureStorage s = storage ?? ref.read(secureStorageProvider);

    // Misma lógica que login: guardar token y usuario
    await s.write(key: 'auth_token', value: token);
    await s.write(key: 'user', value: jsonEncode(user.toJson()));

    // Guardar customer si existe (igual que login)
    if (user.customer != null) {
      await s.write(
        key: 'customer',
        value: jsonEncode(user.customer!.toJson()),
      );
    }

    await setHasUsedAppOnThisDevice(true);

    // Si storage fue pasado, ref puede estar disposed: no actualizar state.
    // El caller debe invalidar authProvider para que reconstruya leyendo del storage.
    if (storage == null) {
      state = AsyncData(user);
    }
  }

  /// Actualizar usuario (para verificación de email, etc.)
  Future<void> updateUser(User user) async {
    // Capturar storage antes de operaciones asíncronas
    if (!ref.mounted) return;
    
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: 'user', value: jsonEncode(user.toJson()));
    
    // Actualizar customer si existe
    if (user.customer != null) {
      await storage.write(
        key: 'customer',
        value: jsonEncode(user.customer!.toJson()),
      );
    }
    
    // Verificar que el provider aún está montado antes de actualizar el estado
    if (ref.mounted) {
      state = AsyncData(user);
    }
  }

  /// Cerrar sesión - Limpia token y estado
  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);
    
    try {
      // 1. Intentar llamar al backend para invalidar el token (opcional, no crítico)
      await ref.read(authRepositoryProvider).logout();
    } catch (e) {
      // Si falla el logout en el backend, continuar con limpieza local
      print('⚠️ Error al hacer logout en backend: $e');
    }
    
    // 2. SIEMPRE limpiar datos locales (crítico) — sin usar ref tras await
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'user');
    await storage.delete(key: 'customer');
    
    // 3. Solo usar ref tras awaits si el provider sigue montado (evita UnmountedRefException)
    if (!ref.mounted) return;
    state = const AsyncData(null);
    ref.invalidateSelf();
  }
}