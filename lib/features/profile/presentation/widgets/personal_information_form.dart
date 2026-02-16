// lib/features/profile/presentation/widgets/personal_information_form.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/design_system/ds_inputs.dart';
import '../../../../core/design_system/ds_buttons.dart';

/// Widget para la sección de Información Personal
/// Muestra formulario para actualizar nombre completo y correo electrónico
class PersonalInformationForm extends StatelessWidget {
  final String fullName;
  final String email;
  final Function(String) onFullNameChanged;
  final Function(String) onEmailChanged;
  final VoidCallback? onSave;
  final bool isLoading;
  final String? fullNameError;
  final String? emailError;

  const PersonalInformationForm({
    Key? key,
    required this.fullName,
    required this.email,
    required this.onFullNameChanged,
    required this.onEmailChanged,
    this.onSave,
    this.isLoading = false,
    this.fullNameError,
    this.emailError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(MBESpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBERadius.large),
        boxShadow: MBETheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y subtítulo
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: MBETheme.brandBlack.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Iconsax.profile_circle,
                  color: MBETheme.brandBlack,
                  size: 24,
                ),
              ),
              const SizedBox(width: MBESpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profilePersonalInfo,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: MBETheme.brandBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Actualiza tu nombre y correo electrónico',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: MBETheme.neutralGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: MBESpacing.xl),

          // Campo Nombre Completo
          DSInput.text(
            label: l10n.fullName,
            value: fullName,
            onChanged: onFullNameChanged,
            required: true,
            prefixIcon: Iconsax.user,
            errorText: fullNameError,
          ),

          const SizedBox(height: MBESpacing.lg),

          // Campo Correo Electrónico
          DSInput.email(
            label: l10n.authEmail,
            value: email,
            onChanged: onEmailChanged,
            required: true,
            errorText: emailError,
          ),

          const SizedBox(height: MBESpacing.xl),

          // Botón Guardar
          if (onSave != null)
            SizedBox(
              width: double.infinity,
              child: DSButton.primary(
                label: l10n.saveProfile,
                onPressed: isLoading ? null : onSave,
                isLoading: isLoading,
              ),
            ),
        ],
      ),
    );
  }
}

