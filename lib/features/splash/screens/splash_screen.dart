import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/router/app_router.dart';
import '../../../core/services/app_preferences.dart';
import '../../../core/services/deep_link_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/data/models/user_model.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  static bool _redirecting = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Capturar providers en el build (antes de callbacks async)
    // Usar router en vez de context para navegar: context puede desmontarse durante await
    final deepLink = ref.read(deepLinkServiceProvider);
    final router = ref.read(appRouterProvider);

    // Escuchar cambios en el authProvider
    ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
      print('🔔 [SPLASH] authProvider listener: ${next.runtimeType}');
      next.whenData((user) {
        print('🔔 [SPLASH] authProvider data: user=${user?.email ?? "null"}');
        Future.microtask(
          () =>
              SplashScreen._redirectFromSplash(context, router, deepLink, user),
        );
      });
      next.whenOrNull(
        error: (error, stackTrace) {
          print('🔔 [SPLASH] authProvider error: $error');
          Future.microtask(
            () => SplashScreen._redirectFromSplash(
              context,
              router,
              deepLink,
              null,
            ),
          );
        },
      );
    });

    // Verificar el estado actual
    final authState = ref.watch(authProvider);
    print(
      '🔔 [SPLASH] build: authState=${authState.runtimeType} loading=${authState.isLoading}',
    );

    return authState.when(
      data: (user) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SplashScreen._redirectFromSplash(context, router, deepLink, user);
        });
        return _buildSplashContent(context);
      },
      loading: () => _buildSplashContent(context),
      error: (error, stackTrace) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SplashScreen._redirectFromSplash(context, router, deepLink, null);
        });
        return _buildSplashContent(context);
      },
    );
  }

  /// Redirige desde splash; si hay deep link de reset-password, va ahí antes que login/home.
  /// Usa router.go() en vez de context.go() porque context puede desmontarse durante await.
  static Future<void> _redirectFromSplash(
    BuildContext context,
    GoRouter router,
    DeepLinkService deepLink,
    User? user,
  ) async {
    print(
      '📍 [SPLASH] _redirectFromSplash INICIO: user=${user?.email ?? "null"} _redirecting=$_redirecting',
    );
    if (_redirecting) {
      print('⚠️ [SPLASH] SALIDA: ya redirigiendo, skip');
      return;
    }
    _redirecting = true;
    try {
      // DEBUG: Imprimir SharedPreferences
      await debugPrintSharedPreferences();

      print('📍 [SPLASH] Esperando deep link (3.5s)...');
      // Esperar hasta ~3.5s a un enlace de reset-password (getInitialLink + stream)
      final uri = await deepLink.waitForResetPasswordLink(
        timeout: const Duration(milliseconds: 3500),
      );
      print(
        '📍 [SPLASH] Deep link wait terminó: uri=${uri?.toString() ?? "null"}',
      );

      // Usar router.go() (no context.go()): context puede estar desmontado tras await
      if (uri != null) {
        print('📍 [SPLASH] Navegando a reset-password');
        router.go(buildResetPasswordRoute(uri));
        return;
      }

      if (user != null) {
        print('📍 [SPLASH] Navegando a welcome-back (user existe)');
        router.go('/auth/welcome-back');
        return;
      }

      print('📍 [SPLASH] Verificando hasUsedAppOnThisDevice...');
      final hasUsedApp = await getHasUsedAppOnThisDevice();
      // final hasUsedApp = false;
      print('📍 [SPLASH] hasUsedApp=$hasUsedApp');

      if (hasUsedApp) {
        print('📍 [SPLASH] Navegando a login');
        router.go('/auth/login');
      } else {
        print('📍 [SPLASH] Navegando a email-entry (portero)');
        router.go('/auth/email-entry');
      }
    } catch (e, st) {
      print('❌ [SPLASH] ERROR en _redirectFromSplash: $e');
      print('$st');
    } finally {
      _redirecting = false;
      print('📍 [SPLASH] _redirectFromSplash FIN');
    }
  }

  Widget _buildSplashContent(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de la app
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
              child: Image.asset(
                'assets/images/logo-mbe_horizontal_3.png',
                width: 205,
                height: 80,
                fit: BoxFit.contain,
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
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
