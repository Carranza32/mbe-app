// lib/features/auth/presentation/screens/create_password_screen.dart
// Pantalla para crear contraseña (usuarios legacy tras verificar OTP).
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
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';

class CreatePasswordScreen extends HookConsumerWidget {
  final String email;
  final String code;

  const CreatePasswordScreen({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final password = useState('');
    final passwordConfirmation = useState('');
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);

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
                const SizedBox(height: 32),

                FadeInDown(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: MBETheme.brandRed.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.lock,
                      size: 40,
                      color: MBETheme.brandRed,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    l10n.createPasswordTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 8),

                FadeInDown(
                  delay: const Duration(milliseconds: 150),
                  child: Text(
                    l10n.createPasswordSubtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: MBETheme.neutralGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 40),

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
                        DSInput.password(
                          label: l10n.authPassword,
                          value: password.value,
                          onChanged: (v) {
                            password.value = v;
                            errorMessage.value = null;
                          },
                          required: true,
                          errorText: _passwordError(context, password.value),
                        ),
                        const SizedBox(height: 16),
                        DSInput.password(
                          label: l10n.confirmPassword,
                          value: passwordConfirmation.value,
                          onChanged: (v) {
                            passwordConfirmation.value = v;
                            errorMessage.value = null;
                          },
                          required: true,
                          errorText:
                              passwordConfirmation.value.isNotEmpty &&
                                  password.value != passwordConfirmation.value
                              ? l10n.passwordsDoNotMatch
                              : null,
                        ),
                        if (errorMessage.value != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: MBETheme.brandRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
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

                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: DSButton.primary(
                    label: l10n.finishRegistration,
                    icon: Iconsax.tick_circle,
                    onPressed:
                        _isValid(
                              context,
                              password.value,
                              passwordConfirmation.value,
                            ) &&
                            !isLoading.value
                        ? () => _handleSubmit(
                            context,
                            ref,
                            password.value,
                            passwordConfirmation.value,
                            isLoading,
                            errorMessage,
                          )
                        : null,
                    isLoading: isLoading.value,
                    fullWidth: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _passwordError(BuildContext context, String p) {
    final l10n = AppLocalizations.of(context)!;
    if (p.isEmpty) return null;
    if (p.length < 8) return l10n.minEightChars;
    if (!p.contains(RegExp(r'[A-Z]'))) return l10n.includeUppercase;
    if (!p.contains(RegExp(r'[a-z]'))) return l10n.includeLowercase;
    if (!p.contains(RegExp(r'[0-9]'))) return l10n.includeNumber;
    return null;
  }

  bool _isValid(BuildContext context, String p, String pc) {
    if (p.isEmpty || pc.isEmpty) return false;
    if (_passwordError(context, p) != null) return false;
    return p == pc;
  }

  Future<void> _handleSubmit(
    BuildContext context,
    WidgetRef ref,
    String pwd,
    String pwdConf,
    ValueNotifier<bool> isLoading,
    ValueNotifier<String?> errorMessage,
  ) async {
    if (pwd != pwdConf) {
      errorMessage.value = AppLocalizations.of(context)!.passwordsDoNotMatch;
      return;
    }
    final err = _passwordError(context, pwd);
    if (err != null) {
      errorMessage.value = err;
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.setPassword(
        email: email,
        code: code,
        password: pwd,
        passwordConfirmation: pwdConf,
      );

      if (!context.mounted) return;

      // Si el backend retorna token y user, loguear automáticamente
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

      // Si no retorna sesión, ir a login
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Iconsax.tick_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.passwordCreatedSuccess),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/auth/login', extra: email);
      }
    } catch (e) {
      if (context.mounted) {
        errorMessage.value = e is ApiException
            ? e.message
            : AppLocalizations.of(context)!.errorCreatingPassword;
      }
    } finally {
      isLoading.value = false;
    }
  }
}
