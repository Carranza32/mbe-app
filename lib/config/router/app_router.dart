import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mbe_orders_app/features/auth/presentation/screens/login_screen.dart';
import 'package:mbe_orders_app/features/auth/presentation/screens/register_screen.dart';
import 'package:mbe_orders_app/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:mbe_orders_app/core/network/dio_provider.dart';
import 'package:mbe_orders_app/features/home/screens/home_router_widget.dart';
import 'package:mbe_orders_app/features/home/screens/main_screen.dart';
import 'package:mbe_orders_app/features/profile/presentation/widgets/addresses_section.dart';
import 'package:mbe_orders_app/features/splash/screens/splash_screen.dart';
import 'package:mbe_orders_app/features/packages/screens/packages_screen.dart';
import 'package:mbe_orders_app/features/pre_alert/presentation/screens/create_pre_alert_screen.dart';
import 'package:mbe_orders_app/features/pre_alert/presentation/screens/pre_alerts_list_screen.dart';
import 'package:mbe_orders_app/features/pre_alert/presentation/screens/pre_alert_complete_information.dart';
import 'package:mbe_orders_app/features/pre_alert/data/models/pre_alert_model.dart';
import 'package:mbe_orders_app/features/print_orders/presentation/screens/my_orders_screen.dart';
import 'package:mbe_orders_app/features/print_orders/presentation/screens/print_order_screen.dart';
import 'package:mbe_orders_app/features/quoter/screens/quote_input_screen.dart';
import 'package:mbe_orders_app/features/tracking/screens/tracking_screen.dart';
import 'package:mbe_orders_app/features/admin/pre_alert/presentation/screens/admin_pre_alerts_list_screen.dart';
import 'package:mbe_orders_app/features/admin/pre_alert/presentation/screens/reception_scan_screen.dart';
import 'package:mbe_orders_app/features/admin/pre_alert/presentation/screens/rack_assignment_screen.dart';
import 'package:mbe_orders_app/features/admin/pre_alert/presentation/screens/pickup_delivery_screen.dart';
import 'package:mbe_orders_app/features/admin/pre_alert/presentation/screens/search_pre_alerts_screen.dart';
import 'package:mbe_orders_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:mbe_orders_app/features/auth/providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      // No redirigir desde la splash screen, ella maneja su propia lógica
      if (state.matchedLocation == '/splash') {
        return null;
      }

      final isLoginRoute =
          state.matchedLocation == '/auth/login' ||
          state.matchedLocation == '/auth/register';
      final isVerifyEmailRoute = state.matchedLocation == '/auth/verify-email';

      // Obtener el estado del authProvider
      final authState = ref.read(authProvider);
      final user = authState.value;
      final isAuthenticated = user != null;

      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      final isPreAlertRoute = state.matchedLocation == '/pre-alert';

      // Si está en una ruta de admin, verificar autenticación y rol
      if (isAdminRoute) {
        if (!isAuthenticated) {
          return '/auth/login';
        }
        final isAdmin = user.isAdmin;
        if (!isAdmin) {
          return '/print-orders/my-orders';
        }
      }

      // Si está en pre-alert y está autenticado, verificar si es admin
      if (isPreAlertRoute && isAuthenticated) {
        final isAdmin = user.isAdmin;
        if (isAdmin) {
          return '/admin/pre-alerts';
        }
      }

      // Si está autenticado pero el email no está verificado, redirigir a verificación
      // (excepto si ya está en la pantalla de verificación)
      if (isAuthenticated && !user.isEmailVerified && !isVerifyEmailRoute) {
        return '/auth/verify-email';
      }

      // Si está autenticado y está en login/register, redirigir según el rol
      if (isAuthenticated && isLoginRoute) {
        final isAdmin = user.isAdmin;
        return isAdmin ? '/' : '/print-orders/my-orders';
      }

      // Si está en verify-email pero no está autenticado, redirigir a login
      if (isVerifyEmailRoute && !isAuthenticated) {
        return '/auth/login';
      }

      // Si está en verify-email y el email ya está verificado, redirigir según el rol
      if (isVerifyEmailRoute && isAuthenticated && user.isEmailVerified) {
        final isAdmin = user.isAdmin;
        return isAdmin ? '/' : '/print-orders/my-orders';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SplashScreen()),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeRouterWidget()),
          ),
          GoRoute(
            path: '/print-orders/my-orders',
            name: 'my-print-orders',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: MyOrdersScreen()),
          ),
          GoRoute(
            path: '/tracking',
            name: 'tracking',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TrackingScreen()),
          ),
          GoRoute(
            path: '/pre-alert',
            name: 'pre-alert',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PreAlertsListScreen()),
          ),
          GoRoute(
            path: '/quoter',
            name: 'quoter',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: QuoteInputScreen()),
          ),
          GoRoute(
            path: '/packages',
            name: 'packages',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PackagesScreen()),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
          // Rutas principales de Admin (tabs en bottom nav)
          GoRoute(
            path: '/admin/pre-alerts',
            name: 'admin-pre-alerts',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AdminPreAlertsListScreen()),
          ),
          GoRoute(
            path: '/admin/pre-alerts/reception',
            name: 'reception-scan',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ReceptionScanScreen()),
          ),
          GoRoute(
            path: '/admin/pre-alerts/assign-rack',
            name: 'rack-assignment',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: RackAssignmentScreen()),
          ),
          GoRoute(
            path: '/admin/pre-alerts/delivery',
            name: 'pickup-delivery',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PickupDeliveryScreen()),
          ),
          GoRoute(
            path: '/admin/search',
            name: 'admin-search',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SearchPreAlertsScreen()),
          ),
        ],
      ),

      //Authentication module
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: '/auth/verify-email',
        name: 'verify-email',
        builder: (context, state) {
          // Intentar obtener el email de diferentes fuentes
          String email =
              state.extra as String? ??
              state.uri.queryParameters['email'] ??
              '';

          // Si no se proporcionó el email, intentar obtenerlo del authProvider
          if (email.isEmpty) {
            final ref = ProviderScope.containerOf(context);
            final authState = ref.read(authProvider);
            final user = authState.value;
            if (user != null) {
              email = user.email;
            }
          }

          // Si aún no hay email, intentar obtenerlo del secure storage de forma síncrona
          // (aunque esto puede no funcionar si el usuario aún no está cargado)
          if (email.isEmpty) {
            // Mostrar un widget que obtenga el email de forma asíncrona
            return _VerifyEmailScreenBuilder(email: email);
          }

          return VerifyEmailScreen(email: email);
        },
      ),

      //Modulo de impresiones
      GoRoute(
        path: '/print-orders/create',
        name: 'create-print-order',
        builder: (context, state) => const PrintOrderScreen(),
      ),

      GoRoute(
        path: '/pre-alert/create',
        name: 'create-pre-alert',
        builder: (context, state) => const CreatePreAlertScreen(),
      ),

      GoRoute(
        path: '/pre-alert/complete/:id',
        name: 'complete-pre-alert',
        builder: (context, state) {
          final preAlert = state.extra as PreAlert?;
          if (preAlert == null) {
            return const Scaffold(
              body: Center(child: Text('Error: Pre-alerta no encontrada')),
            );
          }
          return PreAlertCompleteInformationScreen(preAlert: preAlert);
        },
      ),

      GoRoute(
        path: '/profile/addresses',
        name: 'profile-addresses',
        builder: (context, state) => const AddressesSection(),
      ),
    ],
  );
});

/// Widget builder que obtiene el email del usuario guardado de forma asíncrona
class _VerifyEmailScreenBuilder extends ConsumerStatefulWidget {
  final String email;

  const _VerifyEmailScreenBuilder({required this.email});

  @override
  ConsumerState<_VerifyEmailScreenBuilder> createState() =>
      _VerifyEmailScreenBuilderState();
}

class _VerifyEmailScreenBuilderState
    extends ConsumerState<_VerifyEmailScreenBuilder> {
  String? _email;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    // Si ya tenemos el email, usarlo
    if (widget.email.isNotEmpty) {
      setState(() {
        _email = widget.email;
        _isLoading = false;
      });
      return;
    }

    // Intentar obtener del authProvider
    final authState = ref.read(authProvider);
    final user = authState.value;
    if (user != null && user.email.isNotEmpty) {
      setState(() {
        _email = user.email;
        _isLoading = false;
      });
      return;
    }

    // Si no está en el provider, intentar obtener del secure storage
    try {
      final storage = ref.read(secureStorageProvider);
      final userJson = await storage.read(key: 'user');
      if (userJson != null) {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        final email = userData['email'] as String?;
        if (email != null && email.isNotEmpty) {
          setState(() {
            _email = email;
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      print('Error al obtener email del storage: $e');
    }

    // Si no se encontró, marcar como error
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_email == null || _email!.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Error: No se pudo obtener el email')),
      );
    }

    return VerifyEmailScreen(email: _email!);
  }
}
