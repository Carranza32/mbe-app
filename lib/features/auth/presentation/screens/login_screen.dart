// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../../core/design_system/ds_inputs.dart';
import '../../../../core/design_system/ds_buttons.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends HookConsumerWidget {
  /// Email pre-llenado cuando se llega desde EmailEntryScreen (active_user)
  final String initialEmail;

  /// true cuando viene del portero con has_web_login: usuario ya tiene cuenta (web), mostrar mensaje
  final bool showHasAccountMessage;

  const LoginScreen({
    Key? key,
    this.initialEmail = '',
    this.showHasAccountMessage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final email = useState(initialEmail);
    final password = useState('');
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          // Si el email no está verificado, redirigir a verificación
          if (!user.isEmailVerified) {
            context.go('/auth/verify-email', extra: user.email);
            return;
          }

          // Redirigir según el rol del usuario
          final isAdmin = user.isAdmin;
          context.go(isAdmin ? '/' : '/');
        }
      });

      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: MBETheme.brandRed,
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Logo
                FadeInDown(
                  child: Container(
                    width: 205,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
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

                const SizedBox(height: 40),

                Text(
                  l10n.authWelcomeBack,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  l10n.authSignInToContinue,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: MBETheme.neutralGray,
                  ),
                ),

                if (showHasAccountMessage) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFF3B82F6).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFF3B82F6).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.authHasAccountMessage,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 48),

                // Form
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        DSInput.email(
                          label: l10n.authEmail,
                          value: email.value,
                          onChanged: (value) => email.value = value,
                          required: true,
                          enabled: initialEmail.isEmpty,
                        ),

                        const SizedBox(height: 16),

                        DSInput.password(
                          label: l10n.authPassword,
                          value: password.value,
                          onChanged: (value) => password.value = value,
                          required: true,
                        ),

                        const SizedBox(height: 24),

                        DSButton.primary(
                          label: l10n.authSignIn,
                          onPressed: authState.isLoading
                              ? null
                              : () async {
                                  if (email.value.isEmpty ||
                                      password.value.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          l10n.authCompleteAllFields,
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  await ref
                                      .read(authProvider.notifier)
                                      .login(
                                        email.value.trim(),
                                        password.value,
                                      );
                                },
                          isLoading: authState.isLoading,
                          fullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Link a recuperar contraseña
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${l10n.authForgotPassword} ',
                        style: theme.textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => context.go('/auth/forgot-password'),
                        child: Text(
                          l10n.authRecover,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: MBETheme.brandRed,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Link a activación de cuenta
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${l10n.authNoAccount} ',
                        style: theme.textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => context.go('/auth/email-entry'),
                        child: Text(
                          l10n.authActivateAccount,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: MBETheme.brandRed,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
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
      ),
    );
  }
}
