// lib/features/auth/presentation/screens/email_entry_screen.dart
// Pantalla "portero" - Primera pantalla tras el splash cuando el usuario no está logueado.
// Pide el correo, llama a check-email y redirige según la respuesta.
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../../core/design_system/ds_inputs.dart';
import '../../../../core/design_system/ds_buttons.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/repositories/auth_repository.dart';

class EmailEntryScreen extends HookConsumerWidget {
  const EmailEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final email = useState('');
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 60),

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
                        errorBuilder: (_, __, ___) => Container(
                          padding: const EdgeInsets.all(16),
                          child: const Center(
                            child: Text(
                              'MBE',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
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
                    l10n.welcomeTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                FadeInDown(
                  delay: const Duration(milliseconds: 150),
                  child: Text(
                    l10n.welcomeSubtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: MBETheme.neutralGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 40),

                // Campo de email
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DSInput.email(
                          label: l10n.authEmail,
                          value: email.value,
                          onChanged: (value) {
                            email.value = value;
                            errorMessage.value = null;
                          },
                          required: true,
                        ),

                        if (errorMessage.value != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: MBETheme.brandRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: MBETheme.brandRed.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.close_circle,
                                  size: 20,
                                  color: MBETheme.brandRed,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage.value!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: MBETheme.brandRed,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Botón Continuar
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: DSButton.primary(
                    label: l10n.authContinue,
                    icon: Iconsax.arrow_right_3,
                    onPressed: email.value.trim().isEmpty || isLoading.value
                        ? null
                        : () => _handleContinue(
                            context,
                            ref,
                            email.value.trim(),
                            isLoading,
                            errorMessage,
                          ),
                    isLoading: isLoading.value,
                    fullWidth: true,
                  ),
                ),

                const SizedBox(height: 32),

                // Link a login directo (por si el usuario ya tiene cuenta)
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${l10n.authAlreadyHaveAccount} ',
                        style: theme.textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => context.go('/auth/login'),
                        child: Text(
                          l10n.authSignIn,
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

  Future<void> _handleContinue(
    BuildContext context,
    WidgetRef ref,
    String email,
    ValueNotifier<bool> isLoading,
    ValueNotifier<String?> errorMessage,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.checkEmail(email: email);

      if (!context.mounted) return;

      // Escenario C: Usuario ya registrado (activo) o ya usa la web → login; si has_web_login, mostrar mensaje
      if (response.isActiveUser) {
        context.go(
          '/auth/login',
          extra: {'email': email, 'hasWebLogin': response.hasWebLogin},
        );
        return;
      }

      // Legacy pero ya usa la web (tiene contraseña) → ir a Login, no al flujo OTP/Crear contraseña
      if (response.isLegacyUser && response.hasWebLogin) {
        context.go('/auth/login', extra: {'email': email, 'hasWebLogin': true});
        return;
      }

      // Escenario A: Usuario importado (legacy, sin web) → OTP ya enviado por backend, ir a OTP
      if (response.isLegacyUser) {
        context.go(
          '/auth/otp-verification',
          extra: {
            'email': email,
            'isLegacy': true,
            'welcomeMessage': l10n.legacyWelcomeMessage,
          },
        );
        return;
      }

      // Escenario B: Usuario nuevo → Flutter llama send-activation-code, luego OTP
      if (response.isNewUser) {
        await repository.sendActivationCode(email: email);
        if (!context.mounted) return;
        context.go(
          '/auth/otp-verification',
          extra: {
            'email': email,
            'isLegacy': false,
            'welcomeMessage': l10n.newUserWelcomeMessage,
          },
        );
        return;
      }

      // Status no reconocido: mostrar mensaje del backend si viene, si no ir a login
      if (response.message.isNotEmpty) {
        errorMessage.value = response.message;
        return;
      }
      context.go('/auth/login', extra: {'email': email, 'hasWebLogin': false});
    } catch (e) {
      if (context.mounted) {
        final l10nLocal = AppLocalizations.of(context)!;
        errorMessage.value = e is ApiException
            ? e.message
            : l10nLocal.errorSendingLink;
      }
    } finally {
      isLoading.value = false;
    }
  }
}
