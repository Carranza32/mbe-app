// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mbe_orders_app/features/auth/presentation/screens/register_screen.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../../core/design_system/ds_inputs.dart';
import '../../../../core/design_system/ds_buttons.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = useState('mario.carranza996@gmail.com');
    final password = useState('Carranza32');
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

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
                
                Text(
                  'Bienvenido de nuevo',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Inicia sesión para continuar',
                  style: theme.textTheme.bodyLarge?.copyWith(
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
                        DSInput.email(
                          label: 'Correo Electrónico',
                          value: email.value,
                          onChanged: (value) => email.value = value,
                          required: true,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        DSInput.password(
                          label: 'Contraseña',
                          value: password.value,
                          onChanged: (value) => password.value = value,
                          required: true,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        DSButton.primary(
                          label: 'Iniciar Sesión',
                          onPressed: authState.isLoading
                              ? null
                              : () async {
                                  if (email.value.isEmpty || password.value.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Completa todos los campos'),
                                      ),
                                    );
                                    return;
                                  }
                                  
                                  await ref.read(authProvider.notifier).login(
                                    email.value.trim(),
                                    password.value,
                                  );
                                },
                          isLoading: authState.isLoading,
                          fullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Link a registro
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes una cuenta? ',
                        style: theme.textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        ),
                        child: Text(
                          'Crear cuenta',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: MBETheme.brandRed,
                            fontWeight: FontWeight.w600,
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
}