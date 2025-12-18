// lib/features/auth/presentation/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../../core/design_system/ds_inputs.dart';
import '../../../../core/design_system/ds_buttons.dart';
import '../../providers/register_provider.dart';
import '../widgets/register_stepper.dart';

class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(registerStepProvider);
    final state = ref.watch(registerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: currentStep > 1
            ? IconButton(
                icon: const Icon(Iconsax.arrow_left_2),
                onPressed: () => ref.read(registerStepProvider.notifier).previous(),
              )
            : null,
        // title: Image.asset(
        //   'assets/images/logo.png',
        //   height: 40,
        //   errorBuilder: (context, error, stackTrace) => Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //     decoration: BoxDecoration(
        //       color: MBETheme.brandBlack,
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //     child: const Text(
        //       'MAIL BOXES ETC.',
        //       style: TextStyle(color: Colors.white, fontSize: 12),
        //     ),
        //   ),
        // ),
        title: Text("Crear una cuenta"),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Header
            // Padding(
            //   padding: const EdgeInsets.all(24),
            //   child: Column(
            //     children: [
            //       Text(
            //         'Crear una cuenta',
            //         style: theme.textTheme.headlineSmall?.copyWith(
            //           fontWeight: FontWeight.w600,
            //         ),
            //       ),
            //       // const SizedBox(height: 8),
            //       // Text(
            //       //   'Únete a Mail Boxes Etc. y disfruta de nuestros servicios',
            //       //   style: theme.textTheme.bodyMedium?.copyWith(
            //       //     color: theme.colorScheme.onSurfaceVariant,
            //       //   ),
            //       //   textAlign: TextAlign.center,
            //       // ),
            //     ],
            //   ),
            // ),

            // Stepper
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: RegisterStepper(currentStep: currentStep),
            ),

            const SizedBox(height: 32),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _getStepContent(currentStep, context, ref),
              ),
            ),

            // Buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (currentStep < 4)
                    DSButton.primary(
                      label: _getButtonText(currentStep),
                      onPressed: state.canContinue(currentStep)
                          ? () => ref.read(registerStepProvider.notifier).next()
                          : null,
                      icon: Iconsax.arrow_right_3,
                      fullWidth: true,
                    )
                  else
                    DSButton.primary(
                      label: 'Crear mi cuenta',
                      onPressed: state.isValid
                          ? () => _handleRegister(context, ref)
                          : null,
                      icon: Iconsax.tick_circle,
                      fullWidth: true,
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes una cuenta? ',
                        style: theme.textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => context.go('/auth/login'),
                        child: Text(
                          'Iniciar sesión',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: MBETheme.brandRed,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getButtonText(int step) {
    switch (step) {
      case 1:
        return 'Siguiente: Ubicación';
      case 2:
        return 'Siguiente: Contacto';
      case 3:
        return 'Siguiente: Seguridad';
      default:
        return 'Continuar';
    }
  }

  Widget _getStepContent(int step, BuildContext context, WidgetRef ref) {
    switch (step) {
      case 1:
        return _Step1PersonalInfo(ref: ref);
      case 2:
        return _Step2Location(ref: ref);
      case 3:
        return _Step3Contact(ref: ref);
      case 4:
        return _Step4Security(ref: ref);
      default:
        return const SizedBox();
    }
  }

  Future<void> _handleRegister(BuildContext context, WidgetRef ref) async {
    // TODO: Conectar con API
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Iconsax.tick_circle, size: 64, color: Color(0xFF10B981)),
        title: const Text('¡Cuenta creada!'),
        content: const Text('Tu cuenta ha sido creada exitosamente'),
        actions: [
          DSButton.primary(
            label: 'Iniciar sesión',
            onPressed: () {
              ref.read(registerProvider.notifier).reset();
              context.go('/auth/login');
            },
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

// STEP 1: Información Personal
class _Step1PersonalInfo extends StatelessWidget {
  final WidgetRef ref;
  const _Step1PersonalInfo({required this.ref});

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerProvider);
    final notifier = ref.read(registerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(icon: Iconsax.user, title: 'Información Personal'),
        const SizedBox(height: 24),
        
        Row(
          children: [
            Expanded(
              child: DSDropdown<String>(
                label: 'País',
                value: state.country ?? '',
                items: const [
                  DSDropdownItem(value: 'El Salvador', label: 'El Salvador'),
                  DSDropdownItem(value: 'Guatemala', label: 'Guatemala'),
                  DSDropdownItem(value: 'Honduras', label: 'Honduras'),
                ],
                onChanged: (value) {
                  if (value != null) notifier.setCountry(value);
                },
                required: true,
                hint: 'Selecciona un país',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DSDropdown<String>(
                label: 'Idioma',
                value: state.language ?? '',
                items: const [
                  DSDropdownItem(value: 'Español', label: 'Español'),
                  DSDropdownItem(value: 'English', label: 'English'),
                ],
                onChanged: (value) {
                  if (value != null) notifier.setLanguage(value);
                },
                required: true,
                hint: 'Selecciona un idioma',
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        DSInput.text(
          label: 'Nombre Completo',
          hint: 'Mario Carranza',
          value: state.fullName,
          onChanged: notifier.setFullName,
          required: true,
          prefixIcon: Iconsax.user,
        ),
        
        const SizedBox(height: 16),
        DSInput.email(
          label: 'Correo Electrónico',
          value: state.email,
          onChanged: notifier.setEmail,
          required: true,
        ),
        
        const SizedBox(height: 16),
        DSDropdown<String>(
          label: 'Tipo de Documento',
          value: state.documentType ?? '',
          items: const [
            DSDropdownItem(value: 'DUI', label: 'DUI'),
            DSDropdownItem(value: 'Pasaporte', label: 'Pasaporte'),
            DSDropdownItem(value: 'Licencia', label: 'Licencia'),
          ],
          onChanged: (value) {
            if (value != null) notifier.setDocumentType(value);
          },
          required: true,
          hint: 'Selecciona un tipo',
        ),
        
        const SizedBox(height: 16),
        DSInput.text(
          label: 'Número de Documento',
          hint: '00000000-0',
          value: state.documentNumber,
          onChanged: notifier.setDocumentNumber,
          required: true,
          prefixIcon: Iconsax.card,
        ),
        
        if (state.documentType == 'DUI')
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Iconsax.info_circle, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Formato: 12345678-9',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// STEP 2: Ubicación
class _Step2Location extends StatelessWidget {
  final WidgetRef ref;
  const _Step2Location({required this.ref});

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerProvider);
    final notifier = ref.read(registerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(icon: Iconsax.location, title: 'Selecciona tu Tienda de Preferencia'),
        const SizedBox(height: 24),
        
        DSDropdown<String>(
          label: 'Tienda de Preferencia',
          value: state.preferredStore ?? '',
          items: const [
            DSDropdownItem(value: 'Imprenta Santa Ana - Santa Ana', label: 'Imprenta Santa Ana - Santa Ana'),
            DSDropdownItem(value: 'Imprenta Central - San Salvador', label: 'Imprenta Central - San Salvador'),
          ],
          onChanged: (value) {
            if (value != null) notifier.setPreferredStore(value);
          },
          required: true,
          hint: 'Selecciona una tienda',
        ),
        
        const SizedBox(height: 32),
        _SectionTitle(icon: Iconsax.location, title: 'Especifica tu Ubicación'),
        const SizedBox(height: 24),
        
        DSDropdown<String>(
          label: 'Estado/Departamento',
          value: state.department ?? '',
          items: const [
            DSDropdownItem(value: 'San Salvador', label: 'San Salvador'),
            DSDropdownItem(value: 'Santa Ana', label: 'Santa Ana'),
            DSDropdownItem(value: 'La Libertad', label: 'La Libertad'),
          ],
          onChanged: (value) {
            if (value != null) notifier.setDepartment(value);
          },
          required: true,
          hint: 'Selecciona un departamento',
        ),
        
        const SizedBox(height: 16),
        DSDropdown<String>(
          label: 'Ciudad',
          value: state.city ?? '',
          items: const [
            DSDropdownItem(value: 'San Salvador', label: 'San Salvador'),
            DSDropdownItem(value: 'Santa Ana', label: 'Santa Ana'),
            DSDropdownItem(value: 'Santa Tecla', label: 'Santa Tecla'),
          ],
          onChanged: (value) {
            if (value != null) notifier.setCity(value);
          },
          required: true,
          hint: 'Selecciona una ciudad',
        ),
        
        const SizedBox(height: 16),
        DSInput.textArea(
          label: 'Dirección Completa',
          hint: 'Calle, número, colonia, etc.',
          value: state.address,
          onChanged: notifier.setAddress,
          required: true,
        ),
        
        const SizedBox(height: 16),
        DSInput.text(
          label: 'Referencias (opcional)',
          hint: 'Ej: Portón azul, cerca de la escuela...',
          value: state.references,
          onChanged: notifier.setReferences,
          prefixIcon: Iconsax.location_tick,
        ),
      ],
    );
  }
}

// STEP 3: Contacto
class _Step3Contact extends StatelessWidget {
  final WidgetRef ref;
  const _Step3Contact({required this.ref});

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerProvider);
    final notifier = ref.read(registerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(icon: Iconsax.call, title: 'Información de Contacto'),
        const SizedBox(height: 24),
        
        DSInput.phone(
          label: 'Celular',
          value: state.cellPhone,
          onChanged: notifier.setCellPhone,
          required: true,
        ),
        
        if (state.cellPhone.isNotEmpty && state.cellPhone.length >= 8)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: const [
                Icon(Iconsax.tick_circle, size: 14, color: Color(0xFF10B981)),
                SizedBox(width: 6),
                Text(
                  'Válido',
                  style: TextStyle(fontSize: 12, color: Color(0xFF10B981)),
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 16),
        DSInput.phone(
          label: 'Teléfono de Casa',
          value: state.homePhone,
          onChanged: notifier.setHomePhone,
        ),
        
        const SizedBox(height: 16),
        DSInput.phone(
          label: 'Teléfono de Trabajo',
          value: state.workPhone,
          onChanged: notifier.setWorkPhone,
        ),
        
        const SizedBox(height: 16),
        DSInput.text(
          label: 'Fax (Opcional)',
          hint: 'Número de fax',
          value: state.fax,
          onChanged: notifier.setFax,
          prefixIcon: Iconsax.printer,
        ),
      ],
    );
  }
}

// STEP 4: Seguridad
class _Step4Security extends StatelessWidget {
  final WidgetRef ref;
  const _Step4Security({required this.ref});

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerProvider);
    final notifier = ref.read(registerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(icon: Iconsax.lock, title: 'Seguridad de tu Cuenta'),
        const SizedBox(height: 24),
        
        DSInput.password(
          label: 'Contraseña',
          value: state.password,
          onChanged: notifier.setPassword,
          required: true,
        ),
        
        const SizedBox(height: 8),
        _PasswordRequirements(password: state.password),
        
        const SizedBox(height: 16),
        DSInput.password(
          label: 'Confirmar Contraseña',
          value: state.confirmPassword,
          onChanged: notifier.setConfirmPassword,
          required: true,
        ),
        
        if (state.confirmPassword.isNotEmpty)
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
                  style: TextStyle(
                    fontSize: 12,
                    color: state.passwordsMatch ? const Color(0xFF10B981) : MBETheme.brandRed,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// Widgets auxiliares
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}


class _PasswordRequirements extends StatelessWidget {
  final String password;
  const _PasswordRequirements({required this.password});

  @override
  Widget build(BuildContext context) {
    final has8Chars = password.length >= 8;
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MBETheme.lightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mínimo 8 caracteres, incluye mayúsculas, minúsculas y números',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          _Requirement(met: has8Chars, text: '8 caracteres'),
          _Requirement(met: hasUpper, text: 'Mayúsculas'),
          _Requirement(met: hasLower, text: 'Minúsculas'),
          _Requirement(met: hasNumber, text: 'Números'),
        ],
      ),
    );
  }
}

class _Requirement extends StatelessWidget {
  final bool met;
  final String text;
  const _Requirement({required this.met, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            met ? Iconsax.tick_circle : Iconsax.close_circle,
            size: 12,
            color: met ? const Color(0xFF10B981) : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 11, color: met ? const Color(0xFF10B981) : Colors.grey)),
        ],
      ),
    );
  }
}