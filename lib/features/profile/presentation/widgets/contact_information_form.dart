// lib/features/profile/presentation/widgets/contact_information_form.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/design_system/ds_inputs.dart';
import '../../../../core/design_system/ds_buttons.dart';

/// Widget para la sección de Información de Contacto
/// Muestra formulario para actualizar teléfono, teléfono de casa, tipo de documento y número de documento
class ContactInformationForm extends StatelessWidget {
  final String phone;
  final String? homePhone;
  final String documentType;
  final String documentNumber;
  final Function(String) onPhoneChanged;
  final Function(String) onHomePhoneChanged;
  final Function(String) onDocumentTypeChanged;
  final Function(String) onDocumentNumberChanged;
  final VoidCallback? onSave;
  final bool isLoading;
  final String? phoneError;
  final String? documentNumberError;
  final bool isPhoneValid;
  final bool isHomePhoneValid;

  const ContactInformationForm({
    Key? key,
    required this.phone,
    this.homePhone,
    required this.documentType,
    required this.documentNumber,
    required this.onPhoneChanged,
    required this.onHomePhoneChanged,
    required this.onDocumentTypeChanged,
    required this.onDocumentNumberChanged,
    this.onSave,
    this.isLoading = false,
    this.phoneError,
    this.documentNumberError,
    this.isPhoneValid = false,
    this.isHomePhoneValid = false,
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
                  Iconsax.call,
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
                      l10n.profileContactInfo,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: MBETheme.brandBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Actualiza tu información de contacto y documento',
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

          // Campo Teléfono
          _PhoneField(
            label: l10n.phone,
            value: phone,
            onChanged: onPhoneChanged,
            required: true,
            errorText: phoneError,
            isValid: isPhoneValid,
          ),

          const SizedBox(height: MBESpacing.lg),

          // Campo Teléfono de Casa (Opcional)
          _PhoneField(
            label: l10n.homePhoneOptional,
            value: homePhone ?? '',
            onChanged: onHomePhoneChanged,
            required: false,
            isValid: homePhone != null && homePhone!.isNotEmpty ? isHomePhoneValid : false,
          ),

          const SizedBox(height: MBESpacing.lg),

          // Campo Tipo de Documento
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Iconsax.document,
                    size: 20,
                    color: MBETheme.brandBlack,
                  ),
                  const SizedBox(width: MBESpacing.sm),
                  Text(
                    l10n.documentType,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '*',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: MBETheme.brandRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: MBESpacing.sm),
              _DocumentTypeDropdown(
                value: documentType,
                onChanged: onDocumentTypeChanged,
                l10n: l10n,
              ),
            ],
          ),

          const SizedBox(height: MBESpacing.lg),

          // Campo Número de Documento
          DSInput.text(
            label: 'Número de Documento',
            value: documentNumber,
            onChanged: onDocumentNumberChanged,
            required: true,
            prefixIcon: Iconsax.card,
            hint: documentType == 'DUI' ? '00000000-0' : null,
            errorText: documentNumberError,
          ),

          // Hint para formato DUI
          if (documentType == 'DUI' && documentNumber.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.info_circle,
                    size: 14,
                    color: MBETheme.neutralGray,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.profileFormatDui,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: MBETheme.neutralGray,
                    ),
                  ),
                ],
              ),
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

class _PhoneField extends StatelessWidget {
  final String label;
  final String value;
  final Function(String) onChanged;
  final bool required;
  final String? errorText;
  final bool isValid;

  const _PhoneField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.required = false,
    this.errorText,
    this.isValid = false,
  });

  @override
  Widget build(BuildContext context) {
    final showValidation = value.isNotEmpty && value.length >= 8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSInput.phone(
          label: label,
          value: value,
          onChanged: onChanged,
          required: required,
          errorText: errorText,
        ),
        // Indicador de validación
        if (showValidation && isValid)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(
                  Iconsax.tick_circle,
                  size: 14,
                  color: Color(0xFF10B981),
                ),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context)!.valid,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DocumentTypeDropdown extends StatelessWidget {
  final String value;
  final Function(String) onChanged;
  final AppLocalizations l10n;

  const _DocumentTypeDropdown({
    required this.value,
    required this.onChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(MBERadius.large),
        border: Border.all(
          color: MBETheme.neutralGray.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: MBETheme.shadowSm,
      ),
      child: DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
        items: [
          DropdownMenuItem(
            value: 'DUI',
            child: Text(l10n.profileDocumentDui),
          ),
          DropdownMenuItem(
            value: 'Pasaporte',
            child: Text(l10n.profileDocumentPassport),
          ),
          DropdownMenuItem(
            value: 'Licencia',
            child: Text(l10n.profileDocumentLicense),
          ),
        ],
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
        hint: Text(l10n.profileSelectType),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: MBESpacing.lg,
            vertical: MBESpacing.lg,
          ),
        ),
        dropdownColor: colorScheme.surface,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

