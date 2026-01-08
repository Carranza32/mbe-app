import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../config/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/data/models/user_model.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchar cambios en el authProvider
    ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
      next.whenData((user) {
        // Cuando el authProvider termine de cargar, redirigir
        if (user != null) {
          // Usuario autenticado
          final isAdmin = user.isAdmin;
          Future.microtask(() {
            context.go(isAdmin ? '/' : '/print-orders/my-orders');
          });
        } else {
          // Usuario no autenticado
          Future.microtask(() {
            context.go('/auth/login');
          });
        }
      });

      // Si hay error, redirigir al login
      next.whenOrNull(
        error: (error, stackTrace) {
          Future.microtask(() {
            context.go('/auth/login');
          });
        },
      );
    });

    // Verificar el estado actual
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        // Si ya tenemos datos, redirigir inmediatamente
        if (user != null) {
          final isAdmin = user.isAdmin;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(isAdmin ? '/' : '/print-orders/my-orders');
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/auth/login');
          });
        }
        return _buildSplashContent(context);
      },
      loading: () => _buildSplashContent(context),
      error: (error, stackTrace) {
        // Si hay error, redirigir al login después de un momento
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/auth/login');
        });
        return _buildSplashContent(context);
      },
    );
  }

  Widget _buildSplashContent(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o icono de la app
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Iconsax.box,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            // Indicador de carga
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 24),
            // Texto de carga
            const Text(
              'MBE El Salvador',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cargando...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

