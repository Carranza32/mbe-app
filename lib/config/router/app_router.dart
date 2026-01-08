import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_orders_app/features/auth/presentation/screens/login_screen.dart';
import 'package:mbe_orders_app/features/auth/presentation/screens/register_screen.dart';
import 'package:mbe_orders_app/features/home/screens/home_router_widget.dart';
import 'package:mbe_orders_app/features/home/screens/main_screen.dart';
import 'package:mbe_orders_app/features/splash/screens/splash_screen.dart';
import 'package:mbe_orders_app/features/packages/screens/packages_screen.dart';
import 'package:mbe_orders_app/features/pre_alert/presentation/screens/create_pre_alert_screen.dart';
import 'package:mbe_orders_app/features/pre_alert/presentation/screens/pre_alerts_list_screen.dart';
import 'package:mbe_orders_app/features/print_orders/presentation/screens/my_orders_screen.dart';
import 'package:mbe_orders_app/features/print_orders/presentation/screens/print_order_screen.dart';
import 'package:mbe_orders_app/features/quoter/screens/quote_input_screen.dart';
import 'package:mbe_orders_app/features/tracking/screens/tracking_screen.dart';
import 'package:mbe_orders_app/features/admin/pre_alert/presentation/screens/admin_pre_alerts_list_screen.dart';
import 'package:mbe_orders_app/features/admin/pre_alert/presentation/screens/reception_scan_screen.dart';
import 'package:mbe_orders_app/features/admin/pre_alert/presentation/screens/rack_assignment_screen.dart';
import 'package:mbe_orders_app/features/admin/pre_alert/presentation/screens/pickup_delivery_screen.dart';
import 'package:mbe_orders_app/features/admin/pre_alert/presentation/screens/search_pre_alerts_screen.dart';

import '../../features/auth/providers/auth_provider.dart';

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

      // Si está autenticado y está en login/register, redirigir según el rol
      if (isAuthenticated && isLoginRoute) {
        final isAdmin = user.isAdmin;
        return isAdmin ? '/' : '/print-orders/my-orders';
      }

      return null;
    },
    routes: [
      // Splash Screen - Primera pantalla que se muestra
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
    ],
  );
});
