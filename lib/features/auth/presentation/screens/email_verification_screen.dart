// lib/features/auth/presentation/screens/email_verification_screen.dart
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
import '../../../../l10n/app_localizations.dart';
import '../../providers/email_verification_provider.dart';

class EmailVerificationScreen extends HookConsumerWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final emailController = useTextEditingController();
    final verificationState = ref.watch(emailVerificationProvider);

    // Escuchar cambios en el estado para manejar la respuesta
    ref.listen<EmailVerificationState>(emailVerificationProvider, (
      previous,
      next,
    ) {
      if (next.checkResponse != null && !next.isLoading) {
        final response = next.checkResponse!;

        if (response.exists) {
          // El correo existe - mostrar mensaje y redirigir a login
          _handleEmailExists(context, response);
        } else {
          // El correo NO existe - enviar código y redirigir a registro
          _handleEmailNotExists(context, ref, emailController.text);
        }
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

                // Título
                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    l10n.activateAccountScreenTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 8),

                // Descripción
                FadeInDown(
                  delay: const Duration(milliseconds: 150),
                  child: Text(
                    l10n.activateAccountScreenSubtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: MBETheme.neutralGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 48),

                // Formulario
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
                        // Correo Electrónico
                        DSInput.email(
                          label: l10n.authEmail,
                          value: emailController.text,
                          onChanged: (value) {
                            emailController.text = value;
                            ref
                                .read(emailVerificationProvider.notifier)
                                .setEmail(value);
                          },
                          required: true,
                          controller: emailController,
                        ),

                        const SizedBox(height: 16),

                        // Mensaje de error
                        if (verificationState.error != null) ...[
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
                                    verificationState.error!,
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

                // Botón de continuar
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: DSButton.primary(
                    label: l10n.authContinue,
                    icon: Iconsax.arrow_right_3,
                    onPressed:
                        emailController.text.isNotEmpty &&
                            !verificationState.isLoading
                        ? () => _handleContinue(context, ref)
                        : null,
                    isLoading: verificationState.isLoading,
                    fullWidth: true,
                  ),
                ),

                const SizedBox(height: 24),

                // Link a login
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

  Future<void> _handleContinue(BuildContext context, WidgetRef ref) async {
    final l10nContinue = AppLocalizations.of(context)!;
    final notifier = ref.read(emailVerificationProvider.notifier);
    final state = ref.read(emailVerificationProvider);

    if (state.email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10nContinue.pleaseEnterEmail),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }

    try {
      await notifier.checkEmail();
    } catch (e) {
      if (context.mounted) {
        String errorMessage = l10nContinue.errorVerifyingEmail;

        if (e is ApiException) {
          errorMessage = e.message;
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

  void _handleEmailExists(BuildContext context, dynamic response) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(Iconsax.info_circle, size: 64, color: MBETheme.brandRed),
        title: Text(l10n.emailAlreadyRegistered),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              response.message.isNotEmpty
                  ? response.message
                  : l10n.emailAlreadyRegisteredMessage,
            ),
            const SizedBox(height: 16),
            Text(l10n.forgotPasswordHint),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/auth/login');
            },
            child: Text(l10n.goToSignIn),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEmailNotExists(
    BuildContext context,
    WidgetRef ref,
    String email,
  ) async {
    // Enviar código de activación
    try {
      await ref.read(emailVerificationProvider.notifier).sendActivationCode();

      if (context.mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Iconsax.tick_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.verificationCodeSentTo(email),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );

        // Esperar un momento antes de redirigir
        await Future.delayed(const Duration(milliseconds: 500));

        if (context.mounted) {
          // Redirigir a pantalla de registro con el email
          context.go('/auth/register', extra: email);
        }
      }
    } catch (e) {
      if (context.mounted) {
        final l10nErr = AppLocalizations.of(context)!;
        String errorMessage = l10nErr.errorVerifyingEmail;

        if (e is ApiException) {
          errorMessage = e.message;
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
