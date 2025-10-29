import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_orders_app/features/auth/presentation/screens/login_screen.dart';
import 'package:mbe_orders_app/features/home/screens/home_screen.dart';
import 'package:mbe_orders_app/features/home/screens/main_screen.dart';
import 'package:mbe_orders_app/features/packages/screens/packages_screen.dart';
import 'package:mbe_orders_app/features/pre_alert/screens/pre_alert_screen.dart';
import 'package:mbe_orders_app/features/print_orders/presentation/screens/print_order_screen.dart';
import 'package:mbe_orders_app/features/quoter/screens/quote_input_screen.dart';
import 'package:mbe_orders_app/features/tracking/screens/tracking_screen.dart';

// Provider del router
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/print-orders/create',
    routes: [
      // Shell route para mantener el bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/tracking',
            name: 'tracking',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TrackingScreen(),
            ),
          ),
          GoRoute(
            path: '/pre-alert',
            name: 'pre-alert',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PreAlertScreen(),
            ),
          ),
          GoRoute(
            path: '/quoter',
            name: 'quoter',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: QuoteInputScreen(),
            ),
          ),
          GoRoute(
            path: '/packages',
            name: 'packages',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PackagesScreen(),
            ),
          ),
        ],
      ),

        //Authentication module
        GoRoute(
          path: '/auth/login',
          name: 'login',
          builder: (context, state) => const LoginScreen()
        ),

        //Modulo de impresiones
        GoRoute(
          path: '/print-orders/create',
          name: 'create-print-order',
          builder: (context, state) => const PrintOrderScreen(),
        ),
    ],
  );
});