// lib/features/auth/presentation/screens/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../../core/design_system/ds_inputs.dart';
import '../../../../core/design_system/ds_buttons.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/services/deep_link_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/reset_password_provider.dart';

class ResetPasswordScreen extends HookConsumerWidget {
  final String email;
  final String token;

  const ResetPasswordScreen({
    Key? key,
    required this.email,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final resetPasswordState = ref.watch(resetPasswordProvider);

    // Inicializar email y token si vienen como parámetros (fuera del ciclo de build)
    useEffect(() {
      if (email.isNotEmpty && token.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            final notifier = ref.read(resetPasswordProvider.notifier);
            notifier.setEmail(email);
            notifier.setToken(token);
          }
        });
      }
      return null;
    }, [email, token]);

    // Escuchar cambios en el estado para manejar el éxito
    ref.listen<ResetPasswordState>(resetPasswordProvider, (previous, next) {
      if (next.isSuccess && !next.isLoading && context.mounted) {
        final l10nSuccess = AppLocalizations.of(context)!;
        // Retrasar para no modificar durante build/listen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              icon: const Icon(
                Iconsax.tick_circle,
                size: 64,
                color: Color(0xFF10B981),
              ),
              title: Text(l10nSuccess.passwordResetSuccess),
              content: Text(l10nSuccess.passwordResetSuccessMessage),
              actions: [
                DSButton.primary(
                  label: l10nSuccess.goToSignIn,
                  onPressed: () async {
                    final token = ref.read(resetPasswordProvider).token;
                    if (token.isNotEmpty) {
                      await saveUsedResetToken(token);
                    }
                    if (!dialogContext.mounted) return;
                    Navigator.of(dialogContext).pop();
                    ref.read(resetPasswordProvider.notifier).reset();
                    if (context.mounted) {
                      context.go('/auth/login');
                    }
                  },
                  fullWidth: true,
                ),
              ],
            ),
          );
        });
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
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

                // Icono
                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: MBETheme.brandRed.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.key,
                      size: 40,
                      color: MBETheme.brandRed,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Título
                FadeInDown(
                  delay: const Duration(milliseconds: 150),
                  child: Text(
                    l10n.resetPasswordTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),

                // Descripción
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      Text(
                        l10n.resetPasswordSubtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: MBETheme.neutralGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: MBETheme.brandRed,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Formulario
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
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
                        // Contraseña
                        DSInput.password(
                          label: l10n.newPassword,
                          value: resetPasswordState.password,
                          onChanged: (value) => ref
                              .read(resetPasswordProvider.notifier)
                              .setPassword(value),
                          required: true,
                          errorText: resetPasswordState.errors['password'],
                        ),

                        const SizedBox(height: 8),

                        // Pista de validación de contraseña
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: MBETheme.lightGray,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.lamp,
                                size: 14,
                                color: MBETheme.neutralGray,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  l10n.passwordHint,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: MBETheme.neutralGray,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Confirmar Contraseña
                        DSInput.password(
                          label: l10n.confirmNewPassword,
                          value: resetPasswordState.passwordConfirmation,
                          onChanged: (value) => ref
                              .read(resetPasswordProvider.notifier)
                              .setPasswordConfirmation(value),
                          required: true,
                          errorText: resetPasswordState
                              .errors['password_confirmation'],
                        ),

                        // Validación de coincidencia de contraseñas
                        if (resetPasswordState.passwordConfirmation.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Icon(
                                  resetPasswordState.passwordsMatch
                                      ? Iconsax.tick_circle
                                      : Iconsax.close_circle,
                                  size: 14,
                                  color: resetPasswordState.passwordsMatch
                                      ? const Color(0xFF10B981)
                                      : MBETheme.brandRed,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  resetPasswordState.passwordsMatch
                                      ? l10n.passwordsMatch
                                      : l10n.passwordsDoNotMatch,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: resetPasswordState.passwordsMatch
                                        ? const Color(0xFF10B981)
                                        : MBETheme.brandRed,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Mensajes de error generales
                        if (resetPasswordState.errors['token'] != null ||
                            resetPasswordState.errors['email'] != null) ...[
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
                                    resetPasswordState.errors['token'] ??
                                        resetPasswordState.errors['email'] ??
                                        l10n.errorResettingPassword,
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

                // Botón de restablecer
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: DSButton.primary(
                    label: l10n.authResetPassword,
                    icon: Iconsax.tick_circle,
                    onPressed:
                        resetPasswordState.isValid &&
                            !resetPasswordState.isLoading
                        ? () => _handleResetPassword(context, ref)
                        : null,
                    isLoading: resetPasswordState.isLoading,
                    fullWidth: true,
                  ),
                ),

                const SizedBox(height: 24),

                // Link a login
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${l10n.authRememberedPassword} ',
                        style: theme.textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(resetPasswordProvider.notifier).reset();
                          context.go('/auth/login');
                        },
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

  Future<void> _handleResetPassword(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(resetPasswordProvider.notifier);
    final state = ref.read(resetPasswordProvider);

    if (!state.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.completeFieldsCorrectly),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }

    try {
      await notifier.resetPassword();
    } catch (e) {
      if (context.mounted) {
        final l10nLocal = AppLocalizations.of(context)!;
        String errorMessage = l10nLocal.errorResettingPassword;

        if (e is ApiException) {
          if (e.statusCode == 422 && e.errors != null) {
            notifier.setErrors(e.errors!);
            if (e.message.isNotEmpty) {
              errorMessage = e.message;
            }
          } else {
            errorMessage = e.message;
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: MBETheme.brandRed,
          ),
        );
      }
    }
  }
}
