// lib/features/auth/presentation/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/router/app_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:pinput/pinput.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../../core/design_system/ds_inputs.dart';
import '../../../../core/design_system/ds_buttons.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../providers/register_provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends HookConsumerWidget {
  final String initialEmail;
  final String initialCode;

  /// Modo activación: usuario ya existe, primera vez en la app. Muestra mensaje dinámico y oculta el código OTP.
  final bool isActivationFlow;

  /// Mensaje dinámico para modo activación (ej: "¡Hola! Vemos que ya tienes una cuenta con nosotros. Vamos a activarla.").
  final String? activationMessage;

  /// Nombre pre-llenado (modo activación, desde backend).
  final String? initialName;

  /// Teléfono pre-llenado (modo activación, desde backend).
  final String? initialPhone;

  /// Viene del flujo OTP (usuario nuevo): ocultar campo de código (ya lo ingresó).
  final bool fromOtpFlow;

  const RegisterScreen({
    Key? key,
    this.initialEmail = '',
    this.initialCode = '',
    this.isActivationFlow = false,
    this.activationMessage,
    this.initialName,
    this.initialPhone,
    this.fromOtpFlow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLoading = useState(false);
    final hasInitialized = useState(false);

    // Establecer valores iniciales ANTES del primer build.
    // En flujo de activación solo prellenamos el correo; nombre y teléfono los ingresa el usuario.
    if (!hasInitialized.value) {
      hasInitialized.value = true;
      Future.microtask(() {
        ref
            .read(registerProvider.notifier)
            .setInitialData(
              name: isActivationFlow ? null : initialName,
              email: initialEmail.isNotEmpty ? initialEmail : null,
              phone: isActivationFlow ? null : initialPhone,
              verificationCode: initialCode.isNotEmpty ? initialCode : null,
            );
      });
    }

    final state = ref.watch(registerProvider);

    final displayActivationMessage = isActivationFlow
        ? (activationMessage ?? l10n.activationMessageDefault)
        : null;

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
                      color: MBETheme.brandBlack,
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
                              'MBE MAIL BOXES ETC.',
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
                    isActivationFlow
                        ? l10n.activateAccountTitle
                        : l10n.activateAccountTitleAnAccount,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Subtítulo o mensaje dinámico (modo activación)
                FadeInDown(
                  delay: const Duration(milliseconds: 150),
                  child: Text(
                    displayActivationMessage ?? l10n.activateAccountSubtitle,
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
                        // Título del formulario
                        Row(
                          children: [
                            Icon(
                              Iconsax.document_text,
                              size: 20,
                              color: MBETheme.brandBlack,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.registerInfo,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Código de Verificación: no mostrar en modo activación ni si viene de OTP (ya lo ingresó)
                        if (initialEmail.isNotEmpty &&
                            !isActivationFlow &&
                            !fromOtpFlow) ...[
                          Text(
                            l10n.verificationCode,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.verificationCodeHint,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: MBETheme.neutralGray,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Pinput(
                            length: 6,
                            onChanged: (value) => ref
                                .read(registerProvider.notifier)
                                .setVerificationCode(value),
                            defaultPinTheme: PinTheme(
                              width: 56,
                              height: 56,
                              textStyle: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              decoration: BoxDecoration(
                                color: MBETheme.lightGray,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                            focusedPinTheme: PinTheme(
                              width: 56,
                              height: 56,
                              textStyle: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: MBETheme.brandRed,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: MBETheme.brandRed.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          if (state.errors['verification_code'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              state.errors['verification_code']!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: MBETheme.brandRed,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                        ],

                        // Nombre Completo
                        DSInput.text(
                          label: l10n.fullName,
                          hint: l10n.fullNameHint,
                          value: state.name.isNotEmpty
                              ? state.name
                              : (initialName ?? ''),
                          onChanged: (value) => ref
                              .read(registerProvider.notifier)
                              .setName(value),
                          required: true,
                          prefixIcon: Iconsax.user,
                          errorText: state.errors['name'],
                        ),

                        const SizedBox(height: 16),

                        // Correo Electrónico (en activación solo lectura, solo se pasa desde el flujo)
                        DSInput.email(
                          label: l10n.authEmail,
                          value: state.email.isNotEmpty
                              ? state.email
                              : initialEmail,
                          onChanged: (value) => ref
                              .read(registerProvider.notifier)
                              .setEmail(value),
                          required: true,
                          enabled: !isActivationFlow,
                          errorText: state.errors['email'],
                        ),

                        const SizedBox(height: 16),

                        // Teléfono
                        DSInput.phone(
                          label: l10n.phone,
                          value: state.phone.isNotEmpty
                              ? state.phone
                              : (initialPhone ?? ''),
                          onChanged: (value) => ref
                              .read(registerProvider.notifier)
                              .setPhone(value),
                          required: true,
                          errorText: state.errors['phone'],
                        ),

                        const SizedBox(height: 16),

                        // Contraseña
                        DSInput.password(
                          label: l10n.authPassword,
                          value: state.password,
                          onChanged: (value) => ref
                              .read(registerProvider.notifier)
                              .setPassword(value),
                          required: true,
                          errorText: state.errors['password'],
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
                          label: l10n.confirmPassword,
                          value: state.passwordConfirmation,
                          onChanged: (value) => ref
                              .read(registerProvider.notifier)
                              .setPasswordConfirmation(value),
                          required: true,
                          errorText: state.errors['password_confirmation'],
                        ),

                        // Validación de coincidencia de contraseñas
                        if (state.passwordConfirmation.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Icon(
                                  state.passwordsMatch
                                      ? Iconsax.tick_circle
                                      : Iconsax.close_circle,
                                  size: 14,
                                  color: state.passwordsMatch
                                      ? const Color(0xFF10B981)
                                      : MBETheme.brandRed,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  state.passwordsMatch
                                      ? l10n.passwordsMatch
                                      : l10n.passwordsDoNotMatch,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: state.passwordsMatch
                                        ? const Color(0xFF10B981)
                                        : MBETheme.brandRed,
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

                // Botón de registro
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: DSButton.primary(
                    label: isActivationFlow
                        ? l10n.finishRegistration
                        : l10n.activateMyAccount,
                    icon: Iconsax.tick_circle,
                    onPressed: () => _handleRegister(context, ref, isLoading),
                    isLoading: isLoading.value,
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.authSignIn,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: MBETheme.brandRed,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Iconsax.arrow_right_3,
                              size: 16,
                              color: MBETheme.brandRed,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Términos y condiciones
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.document_text,
                        size: 14,
                        color: MBETheme.neutralGray,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l10n.termsAndPrivacy,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: MBETheme.neutralGray,
                          ),
                          textAlign: TextAlign.center,
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

  Future<void> _handleRegister(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> isLoading,
  ) async {
    final state = ref.read(registerProvider);
    final notifier = ref.read(registerProvider.notifier);
    final authNotifier = ref.read(authProvider.notifier);
    final repository = ref.read(authRepositoryProvider);

    // Capturar ANTES del await (ref puede estar disposed después)
    final storage = ref.read(secureStorageProvider);
    final router = ref.read(appRouterProvider);

    isLoading.value = true;
    notifier.clearErrors();

    try {
      final response = await repository.register(
        name: state.name,
        email: state.email,
        phone: state.phone,
        password: state.password,
        passwordConfirmation: state.passwordConfirmation,
        // Legacy y usuario nuevo: enviar password_set_token (del verify-otp)
        passwordSetToken:
            (isActivationFlow || fromOtpFlow) &&
                state.verificationCode.isNotEmpty
            ? state.verificationCode
            : null,
      );

      // Guardar token y usuario (pasar storage: ref del auth puede estar disposed tras await)
      await authNotifier.setAuthData(
        response.token,
        response.user,
        storage: storage,
      );

      // Invalidar authProvider para que reconstruya leyendo del storage (setAuthData no pudo actualizar state)
      ref.invalidate(authProvider);

      notifier.reset();

      // Verificar si el email está verificado
      if (!response.user.isEmailVerified) {
        router.go('/auth/verify-email', extra: response.user.email);
        return;
      }

      // Toast de éxito y redirección al home (usar router para evitar context desmontado)
      final l10nMsg = AppLocalizations.of(context)!;
      final message = isActivationFlow
          ? l10nMsg.accountActivatedSuccess
          : l10nMsg.accountCreatedSuccess;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Iconsax.tick_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      router.go('/');
    } catch (e, st) {
      // DEBUG: Log del error real
      print('❌ [REGISTER] Error: $e');
      print('$st');
      if (context.mounted) {
        // Manejar errores de validación del servidor
        if (e is ApiException) {
          if (e.statusCode == 422 && e.errors != null) {
            // Errores de validación - mostrarlos en los campos correspondientes
            notifier.setErrors(e.errors!);

            // Mostrar mensaje general si existe
            if (e.message.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.message),
                  backgroundColor: MBETheme.brandRed,
                ),
              );
            }
          } else {
            // Otro tipo de error API
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.message),
                backgroundColor: MBETheme.brandRed,
              ),
            );
          }
        } else {
          // Error desconocido (parseo, etc.)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString().length > 100
                    ? AppLocalizations.of(context)!.errorCreatingAccount
                    : e.toString(),
              ),
              backgroundColor: MBETheme.brandRed,
            ),
          );
        }
      }
    } finally {
      isLoading.value = false;
    }
  }
}
