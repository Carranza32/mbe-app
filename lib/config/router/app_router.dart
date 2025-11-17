import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_orders_app/features/auth/presentation/screens/login_screen.dart';
import 'package:mbe_orders_app/features/home/screens/home_screen.dart';
import 'package:mbe_orders_app/features/home/screens/main_screen.dart';
import 'package:mbe_orders_app/features/packages/screens/packages_screen.dart';
import 'package:mbe_orders_app/features/pre_alert/presentation/screens/create_pre_alert_screen.dart';
import 'package:mbe_orders_app/features/pre_alert/presentation/screens/pre_alerts_list_screen.dart';
import 'package:mbe_orders_app/features/print_orders/presentation/screens/my_orders_screen.dart';
import 'package:mbe_orders_app/features/print_orders/presentation/screens/print_order_screen.dart';
import 'package:mbe_orders_app/features/quoter/screens/quote_input_screen.dart';
import 'package:mbe_orders_app/features/tracking/screens/tracking_screen.dart';

import '../../core/network/dio_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final storage = ref.read(secureStorageProvider);
      final token = await storage.read(key: 'auth_token');
      final hasToken = token != null && token.isNotEmpty;

      // await storage.delete(key: 'auth_token');
      
      final isLoginRoute = state.matchedLocation == '/auth/login';
      
      if (!hasToken && !isLoginRoute) {
        return '/auth/login';
      }
      
      if (hasToken && isLoginRoute) {
        return '/print-orders/my-orders';
      }
      
      return null; // No redirigir
    },
    routes: [
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
              child: PreAlertsListScreen(),
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

        GoRoute(
          path: '/print-orders/my-orders',
          name: 'my-print-orders',
          builder: (context, state) => const MyOrdersScreen(),
        ),

        // GoRoute(
        //   path: '/pre-alert',
        //   name: 'pre-alert',
        //   pageBuilder: (context, state) => const NoTransitionPage(
        //     child: PreAlertsListScreen(),
        //   ),
        // ),

        GoRoute(
          path: '/pre-alert/create',
          name: 'create-pre-alert',
          builder: (context, state) => const CreatePreAlertScreen(),
        ),
    ],
  );
});