import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_orders_app/core/providers/user_role_provider.dart';
import 'package:mbe_orders_app/features/auth/providers/auth_provider.dart';
import 'admin_home_screen.dart';
import 'home_screen.dart';

class HomeRouterWidget extends ConsumerWidget {
  const HomeRouterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Verificar el estado del authProvider para asegurar que está cargado
    final authState = ref.watch(authProvider);
    
    return authState.when(
      data: (user) {
        // Si hay usuario, verificar si es admin
        final isAdmin = user?.isAdmin ?? false;
        return isAdmin ? const AdminHomeScreen() : const HomeScreen();
      },
      loading: () {
        // Mientras carga, mostrar un indicador de carga o el home por defecto
        // Usar el provider para obtener el valor actual si está disponible
        final isAdmin = ref.watch(isAdminProvider);
        return isAdmin ? const AdminHomeScreen() : const HomeScreen();
      },
      error: (error, stackTrace) {
        // Si hay error, mostrar el home del cliente por defecto
        return const HomeScreen();
      },
    );
  }
}

