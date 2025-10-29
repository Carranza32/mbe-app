// lib/features/auth/presentation/providers/auth_provider.dart
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
    
    if (token != null) {
      try {
        return await ref.read(authRepositoryProvider).getCurrentUser();
      } catch (e) {
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
      
      return authResponse.user;
    });
  }

  Future<void> logout() async {
  try {
    await ref.read(authRepositoryProvider).logout();
  } catch (e) {
    print('⚠️ Error en logout backend: $e');
  } finally {
    final storage = ref.read(secureStorageProvider);
    await storage.delete(key: 'auth_token');
    
    if (ref.mounted) {
      state = const AsyncData(null);
    }
  }
}
}