// lib/features/auth/presentation/screens/register_screen.dart
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
import '../../data/repositories/auth_repository.dart';
import '../../providers/register_provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerProvider);
    final theme = Theme.of(context);
    final isLoading = useState(false);

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
                    'Activar una cuenta',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Subtítulo
                FadeInDown(
                  delay: const Duration(milliseconds: 150),
                  child: Text(
                    'Únete a Mail Boxes Etc. y disfruta de nuestros servicios',
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
                            Icon(Iconsax.document_text, size: 20, color: MBETheme.brandBlack),
                            const SizedBox(width: 8),
                            Text(
                              'Información de Registro',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Nombre Completo
                        DSInput.text(
                          label: 'Nombre Completo',
                          hint: 'Mario Carranza',
                          value: state.name,
                          onChanged: (value) => ref.read(registerProvider.notifier).setName(value),
                          required: true,
                          prefixIcon: Iconsax.user,
                          errorText: state.errors['name'],
                        ),

                        const SizedBox(height: 16),

                        // Correo Electrónico
                        DSInput.email(
                          label: 'Correo Electrónico',
                          value: state.email,
                          onChanged: (value) => ref.read(registerProvider.notifier).setEmail(value),
                          required: true,
                          errorText: state.errors['email'],
                        ),

                        const SizedBox(height: 16),

                        // Casillero
                        DSInput.text(
                          label: 'Casillero',
                          value: state.lockerCode,
                          onChanged: (value) => ref.read(registerProvider.notifier).setLockerCode(value),
                          required: true,
                          prefixIcon: Iconsax.lock,
                          errorText: state.errors['locker_code'],
                        ),

                        const SizedBox(height: 8),

                        // Nota sobre ebox
                        Row(
                          children: [
                            Icon(Iconsax.info_circle, size: 14, color: MBETheme.neutralGray),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Recuerda que tienes que registrarte en ebox para poder tener tu código de casillero.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: MBETheme.neutralGray,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Contraseña
                        DSInput.password(
                          label: 'Contraseña',
                          value: state.password,
                          onChanged: (value) => ref.read(registerProvider.notifier).setPassword(value),
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
                              Icon(Iconsax.lamp, size: 14, color: MBETheme.neutralGray),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Mínimo 8 caracteres, incluye mayúsculas, minúsculas y números',
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
                          label: 'Confirmar Contraseña',
                          value: state.passwordConfirmation,
                          onChanged: (value) => ref.read(registerProvider.notifier).setPasswordConfirmation(value),
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
                                  state.passwordsMatch ? Iconsax.tick_circle : Iconsax.close_circle,
                                  size: 14,
                                  color: state.passwordsMatch ? const Color(0xFF10B981) : MBETheme.brandRed,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  state.passwordsMatch ? 'Las contraseñas coinciden' : 'Las contraseñas no coinciden',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: state.passwordsMatch ? const Color(0xFF10B981) : MBETheme.brandRed,
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
                    label: 'Activar mi cuenta',
                    icon: Iconsax.tick_circle,
                    onPressed: state.isValid && !isLoading.value
                        ? () => _handleRegister(context, ref, isLoading)
                        : null,
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
                        '¿Ya tienes una cuenta? ',
                        style: theme.textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => context.go('/auth/login'),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Iniciar sesión',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: MBETheme.brandRed,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Iconsax.arrow_right_3, size: 16, color: MBETheme.brandRed),
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
                      Icon(Iconsax.document_text, size: 14, color: MBETheme.neutralGray),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Al crear una cuenta, aceptas nuestros Términos de Servicio y Política de Privacidad',
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

    isLoading.value = true;
    notifier.clearErrors();

    try {
      final response = await repository.register(
        name: state.name,
        email: state.email,
        lockerCode: state.lockerCode,
        password: state.password,
        passwordConfirmation: state.passwordConfirmation,
      );

      // Guardar el token y usuario
      await authNotifier.setAuthData(response.token, response.user);

      if (context.mounted) {
        // Verificar si el email está verificado
        if (!response.user.isEmailVerified) {
          // Redirigir a la pantalla de verificación
          notifier.reset();
          context.go('/auth/verify-email', extra: response.user.email);
          return;
        } else {
          // Mostrar diálogo de éxito
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              icon: const Icon(Iconsax.tick_circle, size: 64, color: Color(0xFF10B981)),
              title: const Text('¡Cuenta creada!'),
              content: const Text('Tu cuenta ha sido creada exitosamente'),
              actions: [
                DSButton.primary(
                  label: 'Continuar',
                  onPressed: () {
                    Navigator.of(context).pop();
                    notifier.reset();
                    // El authProvider ya redirigirá automáticamente
                  },
                  fullWidth: true,
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
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
            // Otro tipo de error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.message),
                backgroundColor: MBETheme.brandRed,
              ),
            );
          }
        } else {
          // Error desconocido
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Ocurrió un error al crear tu cuenta. Por favor, intenta de nuevo.'),
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
