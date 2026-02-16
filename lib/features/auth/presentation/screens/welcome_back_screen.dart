import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../../core/design_system/ds_buttons.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';

class WelcomeBackScreen extends HookConsumerWidget {
  const WelcomeBackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final localAuth = LocalAuthentication();
    final isAuthenticating = useState(false);
    final canCheckBiometrics = useState(false);
    final availableBiometrics = useState<List<BiometricType>>([]);
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    // Verificar disponibilidad de autenticación biométrica
    useEffect(() {
      Future.microtask(() async {
        try {
          final canCheck = await localAuth.canCheckBiometrics;
          final isDeviceSupported = await localAuth.isDeviceSupported();

          if (canCheck && isDeviceSupported) {
            final available = await localAuth.getAvailableBiometrics();
            canCheckBiometrics.value = true;
            availableBiometrics.value = available;
          }
        } catch (e) {
          // Error verificando biometría - continuar sin biometría
        }
      });
      return null;
    }, []);

    // Intentar autenticación automática al cargar
    useEffect(() {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (canCheckBiometrics.value &&
            availableBiometrics.value.isNotEmpty &&
            context.mounted) {
          _authenticate(context, ref, localAuth, isAuthenticating);
        }
      });
      return null;
    }, [canCheckBiometrics.value]);

    final user = authState.value;

    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Logo MBE
              FadeInDown(
                child: Container(
                  width: 205,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: MBETheme.shadowMd,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/images/logo-mbe_horizontal_2.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: MBETheme.brandBlack,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'MAIL BOXES ETC.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Título
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  l10n.biometricWelcomeBack,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: MBETheme.brandBlack,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  l10n.biometricSignInSubtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: MBETheme.neutralGray,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Card con información del usuario
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: MBETheme.shadowMd,
                  ),
                  child: Column(
                    children: [
                      // Avatar del usuario
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              MBETheme.brandBlack,
                              MBETheme.brandBlack.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: MBETheme.shadowLg,
                        ),
                        child: Center(
                          child: Text(
                            user?.name.isNotEmpty == true
                                ? user!.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Nombre del usuario
                      Text(
                        user?.name ?? l10n.authUser,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: MBETheme.brandBlack,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Email del usuario
                      Text(
                        user?.email ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: MBETheme.neutralGray,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Botón de autenticación biométrica
                      if (canCheckBiometrics.value &&
                          availableBiometrics.value.isNotEmpty)
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                MBETheme.brandBlack,
                                MBETheme.brandBlack.withValues(alpha: 0.9),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: MBETheme.shadowLg,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isAuthenticating.value
                                  ? null
                                  : () => _authenticate(
                                      context,
                                      ref,
                                      localAuth,
                                      isAuthenticating,
                                    ),
                              borderRadius: BorderRadius.circular(20),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isAuthenticating.value)
                                      const SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                          strokeWidth: 3,
                                        ),
                                      )
                                    else ...[
                                      Icon(
                                        _getBiometricIcon(
                                          availableBiometrics.value,
                                        ),
                                        size: 48,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _getBiometricText(
                                          context,
                                          availableBiometrics.value,
                                        ),
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: MBETheme.lightGray,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: MBETheme.neutralGray,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.biometricNotAvailable,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: MBETheme.neutralGray,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botón de iniciar sesión manual
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: DSButton.secondary(
                  label: l10n.authSignInWithEmail,
                  onPressed: () => context.go('/auth/login'),
                  fullWidth: true,
                ),
              ),

              const SizedBox(height: 16),

              // Botón de cerrar sesión
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: TextButton(
                  onPressed: () => _logout(context, ref),
                  child: Text(
                    l10n.authLogout,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: MBETheme.brandRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getBiometricIcon(List<BiometricType> available) {
    if (available.contains(BiometricType.face)) {
      return Icons.face;
    } else if (available.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    } else if (available.contains(BiometricType.iris)) {
      return Icons.remove_red_eye;
    } else {
      return Icons.lock;
    }
  }

  String _getBiometricText(
    BuildContext context,
    List<BiometricType> available,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (available.contains(BiometricType.face)) {
      return l10n.biometricTouchFaceId;
    } else if (available.contains(BiometricType.fingerprint)) {
      return l10n.biometricTouchFingerprint;
    } else if (available.contains(BiometricType.iris)) {
      return l10n.biometricTouchIris;
    } else {
      return l10n.biometricTouchAuthenticate;
    }
  }

  Future<void> _authenticate(
    BuildContext context,
    WidgetRef ref,
    LocalAuthentication localAuth,
    ValueNotifier<bool> isAuthenticating,
  ) async {
    try {
      isAuthenticating.value = true;

      final authenticated = await localAuth.authenticate(
        localizedReason: AppLocalizations.of(context)!.authBiometricReason,
      );

      if (authenticated) {
        // Autenticación exitosa, redirigir según el rol
        final authState = ref.read(authProvider);
        final user = authState.value;
        if (user != null) {
          final isAdmin = user.isAdmin;
          if (context.mounted) {
            context.go(isAdmin ? '/' : '/');
          }
        }
      } else {
        // Usuario canceló o falló la autenticación
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.authCancelled),
              backgroundColor: MBETheme.brandRed,
            ),
          );
        }
      }
    } catch (e) {
      // Error en autenticación biométrica
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: MBETheme.brandRed,
          ),
        );
      }
    } finally {
      isAuthenticating.value = false;
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final l10nDialog = AppLocalizations.of(context)!;
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10nDialog.authLogout),
        content: Text(l10nDialog.authLogoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10nDialog.authCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: MBETheme.brandRed),
            child: Text(l10nDialog.authLogout),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) {
        context.go('/auth/login');
      }
    }
  }
}
