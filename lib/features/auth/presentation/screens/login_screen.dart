import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mbe_orders_app/config/theme/mbe_colors.dart';
import '../../providers/auth_providers.dart';
import '../widgets/mbe_text_field.dart';
import '../widgets/mbe_button.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hooks para los controllers (se limpian automáticamente)
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    
    final authState = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;

    Future<void> handleEmailLogin() async {
      if (!formKey.currentState!.validate()) return;

      final success = await ref.read(authProvider.notifier).loginWithEmail(
            emailController.text.trim(),
            passwordController.text,
          );

      if (success && context.mounted) {
        // Navegar al home
        // context.go('/home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Bienvenido!'),
            backgroundColor: MBEColors.success,
          ),
        );
      }
    }

    Future<void> handleGoogleLogin() async {
      // TODO: Implementar Google Sign In
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Sign In - Próximamente'),
          backgroundColor: MBEColors.info,
        ),
      );
    }

    return Scaffold(
      backgroundColor: MBEColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: size.height - MediaQuery.of(context).padding.top,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Logo con animación
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: MBEColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: MBEColors.black.withOpacity(0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/mbe_logo.png',
                      height: 60,
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: MBEColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Iconsax.box,
                                size: 36,
                                color: MBEColors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'MAIL BOXES ETC.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: MBEColors.black,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Título
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 100),
                  child: const Text(
                    'Bienvenido',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: MBEColors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Ingresa tus credenciales para continuar',
                    style: TextStyle(
                      fontSize: 16,
                      color: MBEColors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Formulario
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 300),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        // Email
                        MBETextField(
                          controller: emailController,
                          label: 'Correo Electrónico',
                          hint: 'tu@ejemplo.com',
                          icon: Iconsax.sms,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu correo';
                            }
                            if (!value.contains('@')) {
                              return 'Ingresa un correo válido';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Contraseña
                        MBETextField(
                          controller: passwordController,
                          label: 'Contraseña',
                          hint: '••••••••',
                          icon: Iconsax.lock,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu contraseña';
                            }
                            if (value.length < 6) {
                              return 'Mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // Olvidé mi contraseña
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Navegar a recuperar contraseña
                            },
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                color: MBEColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Botón de login
                        MBEButton(
                          text: 'Iniciar Sesión',
                          onPressed: handleEmailLogin,
                          isLoading: authState.isLoading,
                        ),

                        // Mostrar error si existe
                        if (authState.error != null) ...[
                          const SizedBox(height: 16),
                          FadeIn(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: MBEColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: MBEColors.error.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Iconsax.warning_2,
                                    color: MBEColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      authState.error!,
                                      style: const TextStyle(
                                        color: MBEColors.error,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Divider
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 400),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(color: MBEColors.greyLight),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'o continúa con',
                          style: TextStyle(
                            color: MBEColors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: MBEColors.greyLight),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Botón de Google
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 500),
                  child: MBEButton(
                    text: 'Continuar con Google',
                    onPressed: handleGoogleLogin,
                    isOutlined: true,
                    icon: Iconsax.ghost
                  ),
                ),

                const Spacer(),

                // Footer
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 600),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      '© 2025 Mail Boxes Etc. Todos los derechos reservados.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: MBEColors.grey,
                        fontSize: 12,
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
}

/*
    return Scaffold(
      backgroundColor: MBEColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: size.height - MediaQuery.of(context).padding.top,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Logo con animación
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: MBEColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: MBEColors.black.withOpacity(0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/mbe_logo.png', // Debes agregar el logo
                      height: 60,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback si no hay imagen
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: MBEColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Iconsax.box,
                                size: 36,
                                color: MBEColors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'MAIL BOXES ETC.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: MBEColors.black,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Título
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 100),
                  child: const Text(
                    'Bienvenido',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: MBEColors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Ingresa tus credenciales para continuar',
                    style: TextStyle(
                      fontSize: 16,
                      color: MBEColors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Formulario
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 300),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email
                        MBETextField(
                          controller: _emailController,
                          label: 'Correo Electrónico',
                          hint: 'tu@ejemplo.com',
                          icon: Iconsax.sms,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu correo';
                            }
                            if (!value.contains('@')) {
                              return 'Ingresa un correo válido';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Contraseña
                        MBETextField(
                          controller: _passwordController,
                          label: 'Contraseña',
                          hint: '••••••••',
                          icon: Iconsax.lock,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu contraseña';
                            }
                            if (value.length < 6) {
                              return 'Mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // Olvidé mi contraseña
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Navegar a recuperar contraseña
                            },
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                color: MBEColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Botón de login
                        MBEButton(
                          text: 'Iniciar Sesión',
                          onPressed: _handleEmailLogin,
                          isLoading: authState.isLoading,
                        ),

                        // Mostrar error si existe
                        if (authState.error != null) ...[
                          const SizedBox(height: 16),
                          FadeIn(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: MBEColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: MBEColors.error.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Iconsax.warning_2,
                                    color: MBEColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      authState.error!,
                                      style: const TextStyle(
                                        color: MBEColors.error,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Divider
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 400),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(color: MBEColors.greyLight),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'o continúa con',
                          style: TextStyle(
                            color: MBEColors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: MBEColors.greyLight),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Botón de Google
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 500),
                  child: MBEButton(
                    text: 'Continuar con Google',
                    onPressed: _handleGoogleLogin,
                    isOutlined: true,
                    icon: Iconsax.google,
                  ),
                ),

                const Spacer(),

                // Footer
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 600),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      '© 2025 Mail Boxes Etc. Todos los derechos reservados.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: MBEColors.grey,
                        fontSize: 12,
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
  
}*/