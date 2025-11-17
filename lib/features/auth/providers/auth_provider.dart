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

    // await storage.delete(key: 'auth_token');
    //     await storage.delete(key: 'user');
    
    if (token != null) {
      try {
        return await ref.read(authRepositoryProvider).getCurrentUser();
      } catch (e) {
        // Si falla obtener usuario, limpiar token inválido
        await storage.delete(key: 'auth_token');
        await storage.delete(key: 'user');
        return null;
      }
    }
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {
      final authResponse = await ref.read(authRepositoryProvider).loginWithEmail(
        email: email,
        password: password,
      );
      
      // Guardar token
      final storage = ref.read(secureStorageProvider);
      await storage.write(key: 'auth_token', value: authResponse.token);
      await storage.write(key: 'user', value: jsonEncode(authResponse.user.toJson()));
      
      return authResponse.user;
    });
  }

  /// ✅ LOGOUT MEJORADO - Siempre limpia el estado local
  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);
    
    try {
      // 1. Intentar llamar al backend (NO crítico si falla)
      await ref.read(authRepositoryProvider).logout();
      print('✅ Logout en backend exitoso');
    } catch (e) {
      print('⚠️ Error en logout backend (continuando): $e');
      // NO lanzar error - continuar con limpieza local
    }
    
    // 2. SIEMPRE limpiar token local (crítico)
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'user');
    print('✅ Token local eliminado');
    
    // 3. SIEMPRE actualizar estado a null (crítico)
    state = const AsyncData(null);
    print('✅ Estado actualizado a null');
  }
}