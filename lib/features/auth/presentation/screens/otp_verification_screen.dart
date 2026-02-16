// lib/features/auth/presentation/screens/otp_verification_screen.dart
// Pantalla de verificación OTP para usuarios nuevos y legacy.
// Tras validar: legacy → CreatePasswordScreen, nuevo → RegisterScreen.
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
import '../../../../l10n/app_localizations.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';

class OtpVerificationScreen extends HookConsumerWidget {
  final String email;
  final bool isLegacy;

  /// Mensaje dinámico según flujo: legacy ("Vamos a activar tu cuenta digital") o new_user ("Vamos a crear tu cuenta").
  final String? welcomeMessage;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.isLegacy = false,
    this.welcomeMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final pinController = useTextEditingController();
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);
    final focusNode = useFocusNode();

    useEffect(() {
      _checkClipboardForCode(context, pinController);
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
                const SizedBox(height: 24),

                // Icono
                FadeInDown(
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

                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    l10n.verifyEmailTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),

                FadeInDown(
                  delay: const Duration(milliseconds: 150),
                  child: Column(
                    children: [
                      if (welcomeMessage != null &&
                          welcomeMessage!.isNotEmpty) ...[
                        Text(
                          welcomeMessage!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: MBETheme.neutralGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        'Ingresa el código de 6 dígitos enviado a:',
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

                const SizedBox(height: 40),

                FadeInUp(
                  delay: const Duration(milliseconds: 200),
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
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onCompleted: (pin) => _handleVerify(
                      context,
                      ref,
                      pin,
                      isLoading,
                      errorMessage,
                    ),
                    onChanged: (_) => errorMessage.value = null,
                  ),
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

                const SizedBox(height: 32),

                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: DSButton.primary(
                    label: l10n.authVerify,
                    icon: Iconsax.tick_circle,
                    onPressed:
                        pinController.text.length == 6 && !isLoading.value
                        ? () => _handleVerify(
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

                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: TextButton(
                    onPressed: isLoading.value
                        ? null
                        : () => _handleResendCode(context, ref),
                    child: Text(
                      '¿No recibiste el código? Reenviar',
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
      ),
    );
  }

  Future<void> _handleVerify(
    BuildContext context,
    WidgetRef ref,
    String code,
    ValueNotifier<bool> isLoading,
    ValueNotifier<String?> errorMessage,
  ) async {
    if (code.length != 6) {
      errorMessage.value = AppLocalizations.of(context)!.enterSixDigits;
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final repository = ref.read(authRepositoryProvider);
      // Endpoint: POST /api/v1/auth/verify-otp (baseUrl + verifyOtp)
      final response = await repository.verifyOtp(email: email, code: code);

      if (!context.mounted) return;

      // Cuando el backend responde { status: 'otp_verified' }
      final status = response['status'] as String?;
      if (status == 'otp_verified') {
        final customerData = response['customer'] as Map<String, dynamic>?;
        final passwordSetToken =
            response['password_set_token'] as String? ?? code;

        // Legacy con datos del cliente → RegisterScreen en modo activación.
        // Solo se pasa el correo; nombre, teléfono y contraseña los ingresa el usuario.
        if (isLegacy && customerData != null) {
          context.go(
            '/auth/register',
            extra: {
              'email': email,
              'code': passwordSetToken,
              'isActivationFlow': true,
              'activationMessage': AppLocalizations.of(
                context,
              )!.activationMessageDefault,
            },
          );
          return;
        }

        // Legacy sin datos de cliente → CreatePasswordScreen (solo contraseña)
        if (isLegacy) {
          context.go(
            '/auth/create-password',
            extra: {'email': email, 'code': passwordSetToken},
          );
          return;
        }

        // Usuario nuevo → RegisterScreen con password_set_token (igual que legacy)
        // Backend devuelve password_set_token; register lo requiere para completar usuario temporal
        context.go(
          '/auth/register',
          extra: {
            'email': email,
            'code': passwordSetToken,
            'fromOtpFlow': true,
          },
        );
        return;
      }

      // Si la respuesta incluye token/user, el backend ya autenticó
      final token = response['token'] as String?;
      final userData = response['user'];
      if (token != null &&
          userData != null &&
          userData is Map<String, dynamic>) {
        final user = User.fromJson(userData);
        await ref.read(authProvider.notifier).setAuthData(token, user);
        if (context.mounted) context.go('/');
        return;
      }

      // Si requiere crear contraseña (legacy - fallback)
      if (isLegacy) {
        context.go(
          '/auth/create-password',
          extra: {'email': email, 'code': code},
        );
        return;
      }

      // Usuario nuevo → Register
      context.go('/auth/register', extra: {'email': email, 'code': code});
    } catch (e) {
      if (context.mounted) {
        errorMessage.value = e is ApiException
            ? e.message
            : AppLocalizations.of(context)!.invalidCodeError;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleResendCode(BuildContext context, WidgetRef ref) async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.sendActivationCode(email: email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Iconsax.tick_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.codeResentSuccess),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is ApiException
                  ? e.message
                  : AppLocalizations.of(context)!.resendCodeError,
            ),
            backgroundColor: MBETheme.brandRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _checkClipboardForCode(
    BuildContext context,
    TextEditingController controller,
  ) async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim();
      if (text != null) {
        final match = RegExp(r'\b\d{6}\b').firstMatch(text);
        if (match != null && controller.text.length < 6) {
          await Future.delayed(const Duration(milliseconds: 300));
          if (context.mounted) {
            controller.text = match.group(0)!;
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
                    Text(AppLocalizations.of(context)!.codeDetectedClipboard),
                  ],
                ),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Color(0xFF10B981),
              ),
            );
          }
        }
      }
    } catch (_) {}
  }
}
