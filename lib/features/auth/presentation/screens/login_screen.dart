// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController(text: 'mario.carranza996@gmail.com');
    final passwordController = useTextEditingController(text: 'Carranza32');
    final isPasswordVisible = useState(false);
    final authState = ref.watch(authProvider);

    ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) context.go('/print-orders/my-orders');
      });
      
      next.whenOrNull(error: (error, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: MBETheme.brandRed,
          ),
        );
      });
    });

    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      body: SafeArea(
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
                    color: MBETheme.lightGray,
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
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                'Bienvenido de nuevo',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Inicia sesión para continuar',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: MBETheme.neutralGray,
                ),
              ),
              
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
                      _TextField(
                        controller: emailController,
                        label: 'Correo Electrónico',
                        hint: 'tu@email.com',
                        icon: Iconsax.sms,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _TextField(
                        controller: passwordController,
                        label: 'Contraseña',
                        hint: '••••••••',
                        icon: Iconsax.lock,
                        obscureText: !isPasswordVisible.value,
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible.value ? Iconsax.eye : Iconsax.eye_slash,
                          ),
                          onPressed: () => isPasswordVisible.value = !isPasswordVisible.value,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: authState.isLoading
                              ? null
                              : () async {
                                  if (emailController.text.isEmpty || 
                                      passwordController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Completa todos los campos'),
                                      ),
                                    );
                                    return;
                                  }
                                  
                                  await ref.read(authProvider.notifier).login(
                                    emailController.text.trim(),
                                    passwordController.text,
                                  );
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: MBETheme.brandBlack,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: authState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : const Text('Iniciar Sesión'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const _TextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: MBETheme.neutralGray),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: MBETheme.lightGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: MBETheme.brandBlack, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}