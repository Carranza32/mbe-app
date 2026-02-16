// lib/features/auth/presentation/screens/verify_email_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:pinput/pinput.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../../core/design_system/ds_buttons.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/repositories/auth_repository.dart';
import '../../providers/auth_provider.dart';

class VerifyEmailScreen extends HookConsumerWidget {
  final String email;

  const VerifyEmailScreen({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final pinController = useTextEditingController();
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);
    final focusNode = useFocusNode();

    // Intentar obtener código del portapapeles al iniciar y cuando la app vuelve al foreground
    useEffect(() {
      _checkClipboardForCode(context, pinController);

      // También verificar cuando la app vuelve al foreground
      // (cuando el usuario vuelve de ver el correo)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkClipboardForCode(context, pinController);
      });

      return null;
    }, []);

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

                // Icono de verificación
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
                      Iconsax.message_text,
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
                    l10n.verifyEmailTitle,
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
                        l10n.verifyEmailCodeSent,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: MBETheme.neutralGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        email,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: MBETheme.brandRed,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Input de código PIN
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: Pinput(
                    length: 6,
                    controller: pinController,
                    focusNode: focusNode,
                    defaultPinTheme: PinTheme(
                      width: 56,
                      height: 56,
                      textStyle: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
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
                      textStyle: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: MBETheme.brandRed, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: MBETheme.brandRed.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    errorPinTheme: PinTheme(
                      width: 56,
                      height: 56,
                      textStyle: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: MBETheme.brandRed, width: 2),
                      ),
                    ),
                    submittedPinTheme: PinTheme(
                      width: 56,
                      height: 56,
                      textStyle: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: BoxDecoration(
                        color: MBETheme.brandRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: MBETheme.brandRed, width: 2),
                      ),
                    ),
                    pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                    showCursor: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    // Reconocimiento automático de SMS (Android)
                    // androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsUserConsentApi,
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                    onCompleted: (pin) {
                      _handleVerifyCode(
                        context,
                        ref,
                        pin,
                        isLoading,
                        errorMessage,
                      );
                    },
                    onChanged: (value) {
                      errorMessage.value = null;
                    },
                  ),
                ),

                // Mensaje de error
                if (errorMessage.value != null) ...[
                  const SizedBox(height: 16),
                  FadeInUp(
                    child: Container(
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
                  ),
                ],

                const SizedBox(height: 32),

                // Botón de verificación
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: DSButton.primary(
                    label: l10n.verifyCode,
                    icon: Iconsax.tick_circle,
                    onPressed:
                        pinController.text.length == 6 && !isLoading.value
                        ? () => _handleVerifyCode(
                            context,
                            ref,
                            pinController.text,
                            isLoading,
                            errorMessage,
                          )
                        : null,
                    isLoading: isLoading.value,
                    fullWidth: true,
                  ),
                ),

                const SizedBox(height: 24),

                // Opción de reenviar código
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: _ResendCodeButton(
                    onResend: () => _handleResendCode(context, ref),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Verifica el código ingresado
  Future<void> _handleVerifyCode(
    BuildContext context,
    WidgetRef ref,
    String code,
    ValueNotifier<bool> isLoading,
    ValueNotifier<String?> errorMessage,
  ) async {
    if (code.length != 6) {
      errorMessage.value = AppLocalizations.of(context)!.enterSixDigitsError;
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Capturar el notifier, repository y storage antes de las operaciones asíncronas
      // Esto asegura que las referencias sean válidas incluso si el widget se desmonta
      final authNotifier = ref.read(authProvider.notifier);
      final repository = ref.read(authRepositoryProvider);
      final storage = ref.read(secureStorageProvider);

      final updatedUser = await repository.verifyCode(code);

      // IMPORTANTE: Verificar que el token aún existe antes de actualizar
      // Esto evita perder el token durante la actualización
      final existingToken = await storage.read(key: 'auth_token');
      print(
        '🔑 Token antes de actualizar usuario: ${existingToken != null ? "EXISTE (${existingToken.substring(0, 10)}...)" : "NO EXISTE"}',
      );
      if (existingToken == null || existingToken.isEmpty) {
        throw Exception(
          'Token no encontrado. Por favor, inicia sesión nuevamente.',
        );
      }

      // Guardar el usuario y customer directamente en storage
      // Esto evita problemas si el provider se dispose durante la operación
      // IMPORTANTE: NO borramos ni sobrescribimos el token, solo actualizamos user y customer
      await storage.write(key: 'user', value: jsonEncode(updatedUser.toJson()));
      if (updatedUser.customer != null) {
        await storage.write(
          key: 'customer',
          value: jsonEncode(updatedUser.customer!.toJson()),
        );
      }

      // Actualizar el estado del provider solo si aún está montado
      // Usar try-catch para manejar el caso de dispose
      try {
        // Verificar que el context aún está montado antes de actualizar el provider
        if (context.mounted) {
          await authNotifier.updateUser(updatedUser);
        }
      } catch (e) {
        // Si el provider se dispose, el storage ya está actualizado
        // No invalidar aquí para evitar problemas con el token
        print('⚠️ Provider disposed durante updateUser: $e');
      }

      if (context.mounted) {
        // Limpiar cualquier error previo
        errorMessage.value = null;

        // Verificar que el token todavía existe después de actualizar
        final tokenStillExists = await storage.read(key: 'auth_token');
        print(
          '🔑 Token después de actualizar usuario: ${tokenStillExists != null ? "EXISTE (${tokenStillExists.substring(0, 10)}...)" : "NO EXISTE"}',
        );
        if (tokenStillExists == null || tokenStillExists.isEmpty) {
          // Si el token se perdió, intentar recuperarlo de alguna forma
          // Pero primero, verificar si el usuario ya fue guardado
          final savedUser = await storage.read(key: 'user');
          if (savedUser == null) {
            throw Exception(
              'Token y usuario perdidos durante la verificación. Por favor, inicia sesión nuevamente.',
            );
          }
          // Si el usuario existe pero no el token, esto es un error grave
          print('❌ ERROR: Usuario existe en storage pero el token se perdió!');
          throw Exception(
            'Token perdido durante la verificación. Por favor, inicia sesión nuevamente.',
          );
        }

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Iconsax.tick_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.emailVerifiedSuccess),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );

        // Esperar un poco para que el provider se actualice
        await Future.delayed(const Duration(milliseconds: 300));

        // Redirigir según el rol del usuario
        if (context.mounted) {
          final isAdmin = updatedUser.isAdmin;
          final redirectPath = isAdmin ? '/' : '/';

          // Usar go en lugar de pop para forzar la navegación
          // El router detectará automáticamente que el email está verificado
          context.go(redirectPath);
        }
      }
    } catch (e, stackTrace) {
      print('❌ Error al verificar código: $e');
      print('Stack trace: $stackTrace');

      if (context.mounted) {
        if (e is ApiException) {
          errorMessage.value = e.message;
        } else {
          errorMessage.value = AppLocalizations.of(context)!.invalidCodeError;
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Verifica el portapapeles en busca de un código de 6 dígitos
  Future<void> _checkClipboardForCode(
    BuildContext context,
    TextEditingController controller,
  ) async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        final text = clipboardData!.text!.trim();

        // Buscar un código de 6 dígitos en el texto del portapapeles
        // Puede estar solo o dentro de un texto más largo
        final codeRegex = RegExp(r'\b\d{6}\b');
        final match = codeRegex.firstMatch(text);

        if (match != null) {
          final code = match.group(0)!;

          // Solo auto-completar si el campo está vacío o tiene menos de 6 dígitos
          if (controller.text.length < 6) {
            // Pequeño delay para que la UI esté lista
            await Future.delayed(const Duration(milliseconds: 300));

            if (context.mounted && controller.text.length < 6) {
              controller.text = code;

              // Mostrar un mensaje sutil
              final l10nClipboard = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Iconsax.tick_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(l10nClipboard.codeDetectedClipboard),
                    ],
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      // Silenciosamente fallar si no se puede acceder al portapapeles
      // Esto puede pasar en algunos dispositivos o versiones
    }
  }

  /// Maneja el reenvío del código de verificación
  Future<void> _handleResendCode(BuildContext context, WidgetRef ref) async {
    try {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.resendVerificationCode();

      if (context.mounted) {
        final success = response['success'] as bool? ?? false;
        final message = response['message'] as String? ?? '';

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Iconsax.tick_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(message)),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          // Email ya verificado o error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    message.contains('ya está verificado')
                        ? Iconsax.info_circle
                        : Iconsax.close_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(message)),
                ],
              ),
              backgroundColor: message.contains('ya está verificado')
                  ? Colors.orange
                  : MBETheme.brandRed,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Si el email ya está verificado, actualizar el usuario y redirigir
          if (message.contains('ya está verificado')) {
            // Obtener el usuario actualizado del servidor
            final updatedUser = await repository.getCurrentUser();
            await ref.read(authProvider.notifier).updateUser(updatedUser);

            // El router redirigirá automáticamente
            if (context.canPop()) {
              context.pop();
            }
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        final l10nLocal = AppLocalizations.of(context)!;
        String errorMessage = l10nLocal.resendCodeError;

        if (e is ApiException) {
          errorMessage = e.message;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Iconsax.close_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: MBETheme.brandRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

/// Widget para el botón de reenviar código con estado de loading
class _ResendCodeButton extends HookConsumerWidget {
  final VoidCallback onResend;

  const _ResendCodeButton({required this.onResend});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLoading = useState(false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('¿No recibiste el código? ', style: theme.textTheme.bodyMedium),
        GestureDetector(
          onTap: isLoading.value
              ? null
              : () async {
                  isLoading.value = true;
                  onResend();
                  isLoading.value = false;
                },
          child: isLoading.value
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      MBETheme.brandRed,
                    ),
                  ),
                )
              : Text(
                  AppLocalizations.of(context)!.authResend,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: MBETheme.brandRed,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
        ),
      ],
    );
  }
}
