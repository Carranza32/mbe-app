import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mbe_orders_app/features/auth/presentation/screens/login_screen.dart';
import 'package:mbe_orders_app/features/auth/presentation/screens/register_screen.dart';
import 'package:mbe_orders_app/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:mbe_orders_app/features/auth/presentation/screens/email_entry_screen.dart';
import 'package:mbe_orders_app/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:mbe_orders_app/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:mbe_orders_app/features/auth/presentation/screens/create_password_screen.dart';
import 'package:mbe_orders_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:mbe_orders_app/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:mbe_orders_app/features/auth/presentation/screens/welcome_back_screen.dart';
import 'package:mbe_orders_app/features/auth/presentation/screens/complete_profile_screen.dart';
import 'package:mbe_orders_app/core/network/dio_provider.dart';
import 'package:mbe_orders_app/features/home/screens/home_router_widget.dart';
import 'package:mbe_orders_app/features/home/screens/main_screen.dart';
import 'package:mbe_orders_app/features/profile/presentation/widgets/addresses_section.dart';
import 'package:mbe_orders_app/features/splash/screens/splash_screen.dart';
import 'package:mbe_orders_app/features/packages/screens/packages_screen.dart';
import 'package:mbe_orders_app/features/pre_alert/presentation/screens/create_pre_alert_screen.dart';
import 'package:mbe_orders_app/features/pre_alert/presentation/screens/pre_alerts_list_screen.dart';
import 'package:mbe_orders_app/features/pre_alert/presentation/screens/pre_alert_complete_information.dart';
import 'package:mbe_orders_app/features/pre_alert/presentation/screens/pre_alert_detail_screen.dart';
import 'package:mbe_orders_app/features/pre_alert/data/models/pre_alert_model.dart';
import 'package:mbe_orders_app/features/print_orders/presentation/screens/my_orders_screen.dart';
import 'package:mbe_orders_app/features/print_orders/presentation/screens/print_order_screen.dart';
import 'package:mbe_orders_app/features/quoter/screens/quote_input_screen.dart';
import 'package:mbe_orders_app/features/trends/presentation/screens/trends_screen.dart';
import 'package:mbe_orders_app/features/tracking/screens/tracking_screen.dart';
import 'package:mbe_orders_app/features/admin/pre_alert/presentation/screens/admin_pre_alerts_list_screen.dart';
import 'package:mbe_orders_app/features/admin/pre_alert/presentation/screens/reception_scan_screen.dart';
import 'package:mbe_orders_app/features/admin/pre_alert/presentation/screens/rack_assignment_screen.dart';
import 'package:mbe_orders_app/features/admin/pre_alert/presentation/screens/pickup_delivery_screen.dart';
import 'package:mbe_orders_app/features/admin/pre_alert/presentation/screens/search_pre_alerts_screen.dart';
import 'package:mbe_orders_app/features/admin/locker_retrieval/presentation/screens/locker_retrieval_screen.dart';
import 'package:mbe_orders_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:mbe_orders_app/features/auth/providers/auth_provider.dart';
import 'package:mbe_orders_app/core/services/deep_link_service.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // No hacer ref.watch(authProvider) aquí: provocaría recrear GoRouter al cambiar auth,
  // dejando obsoleto el router capturado en splash (router.go() no tendría efecto).
  // El redirect lee authProvider al evaluar, eso basta.
  // Si la app se abrió desde un deep link de reset-password, ir ahí de entrada
  final initialUri = ref.watch(initialDeepLinkUriProvider);
  final initialLocation =
      (initialUri != null && isResetPasswordUri(initialUri))
          ? buildResetPasswordRoute(initialUri)
          : '/splash';

  return GoRouter(
    initialLocation: initialLocation,
    redirect: (context, state) async {
      // No redirigir desde splash, porter, OTP, create-password, welcome-back, forgot-password ni reset-password
      if (state.matchedLocation == '/splash' ||
          state.matchedLocation == '/auth/email-entry' ||
          state.matchedLocation == '/auth/otp-verification' ||
          state.matchedLocation == '/auth/create-password' ||
          state.matchedLocation == '/auth/welcome-back' ||
          state.matchedLocation == '/auth/forgot-password' ||
          state.matchedLocation.startsWith('/auth/reset-password')) {
        return null;
      }

      final isLoginRoute =
          state.matchedLocation == '/auth/login' ||
          state.matchedLocation == '/auth/register' ||
          state.matchedLocation == '/auth/email-entry' ||
          state.matchedLocation == '/auth/otp-verification' ||
          state.matchedLocation == '/auth/create-password';
      final isVerifyEmailRoute = state.matchedLocation == '/auth/verify-email';
      final isCompleteProfileRoute = state.matchedLocation == '/auth/complete-profile';
      final isForgotPasswordRoute = state.matchedLocation == '/auth/forgot-password';
      final isResetPasswordRoute = state.matchedLocation.startsWith('/auth/reset-password');

      // Obtener el estado del authProvider
      // Usar read para obtener el estado actual (el router se reconstruye cuando cambia)
      final authState = ref.read(authProvider);
      
      // Si el estado está cargando, no redirigir (dejar que la splash screen maneje)
      if (authState.isLoading) {
        return null;
      }
      
      // Si hay error, solo redirigir si no estamos en rutas de autenticación/recuperación
      if (authState.hasError) {
        if (!isLoginRoute &&
            !isVerifyEmailRoute &&
            !isCompleteProfileRoute &&
            !isForgotPasswordRoute &&
            !isResetPasswordRoute) {
          return '/auth/email-entry';
        }
        return null;
      }
      
      final user = authState.value;
      final isAuthenticated = user != null;

      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      final isPreAlertRoute = state.matchedLocation == '/pre-alert';

      // Si est? en una ruta de admin, verificar autenticaci?n y rol
      if (isAdminRoute) {
        if (!isAuthenticated) {
          return '/auth/login';
        }
        final isAdmin = user.isAdmin;
        if (!isAdmin) {
          return '/';
        }
      }

      // Si est? en pre-alert y est? autenticado, verificar si es admin
      if (isPreAlertRoute && isAuthenticated) {
        final isAdmin = user.isAdmin;
        if (isAdmin) {
          return '/admin/pre-alerts';
        }
      }

      // Si est? autenticado pero el email no est? verificado, redirigir a verificaci?n
      // (excepto si ya est? en la pantalla de verificaci?n o completar perfil)
      if (isAuthenticated && !user.isEmailVerified && !isVerifyEmailRoute && !isCompleteProfileRoute) {
        return '/auth/verify-email';
      }

      // Si est? en complete-profile pero no est? autenticado, redirigir a login
      if (isCompleteProfileRoute && !isAuthenticated) {
        return '/auth/login';
      }

      // Si est? en complete-profile pero el customer ya est? verificado, redirigir al home
      if (isCompleteProfileRoute && 
          isAuthenticated && 
          user.customer != null && 
          user.customer!.verifiedAt != null) {
        return '/';
      }

      // Si est? autenticado y est? en login/register, redirigir seg?n el rol
      if (isAuthenticated && isLoginRoute) {
        final isAdmin = user.isAdmin;
        return isAdmin ? '/' : '/';
      }

      // Si está en verify-email pero no está autenticado, redirigir al portero
      if (isVerifyEmailRoute && !isAuthenticated) {
        return '/auth/email-entry';
      }

      // Si est? en verify-email y el email ya est? verificado, redirigir seg?n el rol
      if (isVerifyEmailRoute && isAuthenticated && user.isEmailVerified) {
        final isAdmin = user.isAdmin;
        return isAdmin ? '/' : '/';
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
            path: '/trends',
            name: 'trends',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TrendsScreen()),
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
          GoRoute(
            path: '/admin/locker-retrieval',
            name: 'admin-locker-retrieval',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: LockerRetrievalScreen()),
          ),
        ],
      ),

      //Authentication module
      GoRoute(
        path: '/auth/email-entry',
        name: 'email-entry',
        builder: (context, state) => const EmailEntryScreen(),
      ),

      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) {
          String email = '';
          bool hasWebLogin = false;
          final extra = state.extra;
          if (extra is String) {
            email = extra;
          } else if (extra is Map<String, dynamic>) {
            email = extra['email'] as String? ?? '';
            hasWebLogin = extra['hasWebLogin'] as bool? ?? false;
          }
          return LoginScreen(initialEmail: email, showHasAccountMessage: hasWebLogin);
        },
      ),

      GoRoute(
        path: '/auth/welcome-back',
        name: 'welcome-back',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: WelcomeBackScreen()),
      ),

      GoRoute(
        path: '/auth/email-verification',
        name: 'email-verification',
        builder: (context, state) => const EmailVerificationScreen(),
      ),

      GoRoute(
        path: '/auth/otp-verification',
        name: 'otp-verification',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final email = extra['email'] as String? ?? '';
          final isLegacy = extra['isLegacy'] as bool? ?? false;
          final welcomeMessage = extra['welcomeMessage'] as String?;
          return OtpVerificationScreen(
            email: email,
            isLegacy: isLegacy,
            welcomeMessage: welcomeMessage,
          );
        },
      ),

      GoRoute(
        path: '/auth/create-password',
        name: 'create-password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final email = extra['email'] as String? ?? '';
          final code = extra['code'] as String? ?? '';
          if (email.isEmpty || code.isEmpty) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(
                child: Text('Enlace inválido. Regresa e intenta de nuevo.'),
              ),
            );
          }
          return CreatePasswordScreen(email: email, code: code);
        },
      ),

      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) {
          // extra puede ser String (email) o Map con email, code, isActivationFlow, activationMessage, etc.
          final extra = state.extra;
          String email = '';
          String code = '';
          bool isActivationFlow = false;
          String? activationMessage;
          String? initialName;
          if (extra is String) {
            email = extra;
          } else if (extra is Map<String, dynamic>) {
            email = extra['email'] as String? ?? '';
            code = extra['code'] as String? ?? '';
            isActivationFlow = extra['isActivationFlow'] as bool? ?? false;
            activationMessage = extra['activationMessage'] as String?;
            initialName = extra['name'] as String?;
          }
          final initialPhone = extra is Map<String, dynamic> ? extra['phone'] as String? : null;
          final fromOtpFlow = extra is Map<String, dynamic>
              ? (extra['fromOtpFlow'] as bool? ?? false)
              : false;
          return RegisterScreen(
            initialEmail: email,
            initialCode: code,
            isActivationFlow: isActivationFlow,
            activationMessage: activationMessage,
            initialName: initialName,
            initialPhone: initialPhone,
            fromOtpFlow: fromOtpFlow,
          );
        },
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

          // Si no se proporcion? el email, intentar obtenerlo del authProvider
          if (email.isEmpty) {
            final ref = ProviderScope.containerOf(context);
            final authState = ref.read(authProvider);
            final user = authState.value;
            if (user != null) {
              email = user.email;
            }
          }

          // Si a?n no hay email, intentar obtenerlo del secure storage de forma s?ncrona
          // (aunque esto puede no funcionar si el usuario a?n no est? cargado)
          if (email.isEmpty) {
            // Mostrar un widget que obtenga el email de forma as?ncrona
            return _VerifyEmailScreenBuilder(email: email);
          }

          return VerifyEmailScreen(email: email);
        },
      ),

      GoRoute(
        path: '/auth/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      GoRoute(
        path: '/auth/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          // Obtener token y email de los query parameters
          final token = state.uri.queryParameters['token'] ?? '';
          final email = state.uri.queryParameters['email'] ?? '';

          if (token.isEmpty || email.isEmpty) {
            // Si no hay parámetros, mostrar error
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(
                child: Text(
                  'Enlace inválido. Por favor, solicita un nuevo enlace de recuperación.',
                ),
              ),
            );
          }

          return ResetPasswordScreen(
            email: email,
            token: token,
          );
        },
      ),

      GoRoute(
        path: '/auth/complete-profile',
        name: 'complete-profile',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: CompleteProfileScreen()),
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
        path: '/pre-alert/detail/:id',
        name: 'pre-alert-detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PreAlertDetailScreen(preAlertId: id);
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

/// Widget builder que obtiene el email del usuario guardado de forma as?ncrona
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

    // Si no est? en el provider, intentar obtener del secure storage
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

    // Si no se encontr?, marcar como error
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
