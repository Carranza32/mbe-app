// lib/features/auth/presentation/screens/complete_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../../core/design_system/ds_inputs.dart';
import '../../../../core/design_system/ds_buttons.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../profile/presentation/widgets/address_form_modal.dart';
import '../../../profile/data/models/address_model.dart';
import '../../../profile/data/repositories/address_repository.dart';
import '../../../profile/providers/addresses_provider.dart';
import '../../providers/complete_profile_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/document_config_provider.dart';
import '../widgets/document_number_formatter.dart';
import 'package:flutter/services.dart';

class CompleteProfileScreen extends HookConsumerWidget {
  const CompleteProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final completeProfileState = ref.watch(completeProfileProvider);
    final completeProfileNotifier = ref.read(completeProfileProvider.notifier);
    final authState = ref.watch(authProvider);
    final customer = authState.value?.customer;

    // Cargar direcciones
    final addressesAsync = ref.watch(addressesProvider);

    // Cargar configuraciones de documentos
    final documentConfigsAsync = ref.watch(documentConfigsProvider);

    // Obtener código del país del customer
    final countryCode = customer?.country ?? 'SV';

    // Controller para el número de documento (mantiene el estado del formateador)
    final documentNumberController = useTextEditingController(
      text: completeProfileState.documentNumber ?? '',
    );

    // Obtener la configuración del documento seleccionado para crear el formateador
    final selectedDocumentConfig = documentConfigsAsync.when(
      data: (configs) {
        return completeProfileState.documentType != null
            ? configs.getTypeConfig(
                countryCode,
                completeProfileState.documentType!,
              )
            : null;
      },
      loading: () => null,
      error: (_, __) => null,
    );

    // Mantener el formateador estable usando useState para evitar recrearlo en cada build
    final documentFormatterState = useState<TextInputFormatter?>(null);
    final lastDocumentType = useRef<String?>(null);

    // Actualizar el formateador solo cuando cambia el tipo de documento
    useEffect(
      () {
        if (selectedDocumentConfig != null &&
            lastDocumentType.value != completeProfileState.documentType) {
          lastDocumentType.value = completeProfileState.documentType;

          // Obtener el texto actual sin formato para inicializar el formateador
          final currentText = documentNumberController.text.replaceAll(
            RegExp(r'[^\w]'),
            '',
          );

          final formatter = DocumentNumberFormatterHelper.createFormatter(
            format: selectedDocumentConfig.format,
            maxLength: selectedDocumentConfig.length,
            initialText: currentText.isNotEmpty ? currentText : null,
          );

          documentFormatterState.value = formatter;

          // Si hay texto actual y el formateador es MaskTextInputFormatter,
          // actualizar el texto del controller con el texto formateado
          if (formatter is MaskTextInputFormatter && currentText.isNotEmpty) {
            final maskedText = formatter.getMaskedText();
            if (maskedText.isNotEmpty) {
              Future.microtask(() {
                documentNumberController.value = TextEditingValue(
                  text: maskedText,
                  selection: TextSelection.collapsed(offset: maskedText.length),
                );
              });
            }
          }
        }
        return null;
      },
      [
        selectedDocumentConfig?.format,
        selectedDocumentConfig?.length,
        completeProfileState.documentType,
      ],
    );

    // Actualizar el controller cuando cambia el valor del estado externamente
    // (pero no cuando el usuario está escribiendo)
    useEffect(() {
      final currentValue = completeProfileState.documentNumber ?? '';
      // Solo actualizar si el texto es diferente y no está enfocado
      // para evitar interferir con la escritura del usuario
      if (documentNumberController.text != currentValue) {
        Future.microtask(() {
          documentNumberController.value = TextEditingValue(
            text: currentValue,
            selection: TextSelection.collapsed(offset: currentValue.length),
          );
        });
      }
      return null;
    }, [completeProfileState.documentNumber]);

    // Inicializar valores si el customer ya tiene datos (después del build)
    useEffect(() {
      final currentCustomer = customer;
      if (currentCustomer != null && !completeProfileState.isInitialized) {
        // Usar Future.microtask para evitar modificar el provider durante el build
        Future.microtask(() {
          completeProfileNotifier.initializeFromCustomer(currentCustomer);
        });
      }
      return null;
    }, [customer]);

    // Seleccionar automáticamente el primer tipo de documento cuando se cargan los datos
    useEffect(() {
      documentConfigsAsync.whenData((configs) {
        // Solo si no hay un tipo de documento seleccionado
        // y el customer no tiene un tipo de documento ya establecido
        if (completeProfileState.documentType == null &&
            (customer == null || customer.documentType == null)) {
          final documentTypes = configs.getTypesForCountry(countryCode);
          if (documentTypes.isNotEmpty) {
            // Seleccionar el primer tipo de documento
            Future.microtask(() {
              completeProfileNotifier.setDocumentType(documentTypes.first.code);
            });
          }
        }
      });
      return null;
    }, [documentConfigsAsync, countryCode, customer]);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección: Cuenta en Revisión
              FadeInDown(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFFA726).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Iconsax.clock,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.accountUnderReview,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFE65100),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.accountUnderReviewMessage,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFE65100),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Iconsax.clock,
                              size: 20,
                              color: Color(0xFFE65100),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.reviewingEmailLocker,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFFE65100),
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

              const SizedBox(height: 24),

              // Sección: Completa tu Perfil
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: MBECardDecoration.card(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.completeYourProfile,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.completeProfileSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: MBETheme.neutralGray,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Teléfono (requerido)
                      DSInput.phone(
                        label: l10n.phone,
                        value: completeProfileState.phone,
                        onChanged: (value) =>
                            completeProfileNotifier.setPhone(value),
                        required: true,
                        errorText: completeProfileState.errors['phone'],
                      ),

                      // Mostrar validación si el teléfono es válido
                      if (completeProfileState.phone.isNotEmpty &&
                          _isValidPhone(completeProfileState.phone))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Iconsax.tick_circle,
                                size: 16,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.valid,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Teléfono de Casa (Opcional)
                      DSInput.phone(
                        label: l10n.homePhoneOptional,
                        value: completeProfileState.homePhone ?? '',
                        onChanged: (value) =>
                            completeProfileNotifier.setHomePhone(value),
                        required: false,
                        errorText: completeProfileState.errors['home_phone'],
                      ),

                      // Mostrar validación si el teléfono de casa es válido
                      if (completeProfileState.homePhone != null &&
                          completeProfileState.homePhone!.isNotEmpty &&
                          _isValidPhone(completeProfileState.homePhone!))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Iconsax.tick_circle,
                                size: 16,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.valid,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Tipo de Documento
                      documentConfigsAsync.when(
                        data: (configs) {
                          final documentTypes = configs.getTypesForCountry(
                            countryCode,
                          );
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DSDropdown<String?>(
                                label: l10n.documentType,
                                value: completeProfileState.documentType,
                                items: documentTypes
                                    .map(
                                      (type) => DSDropdownItem<String?>(
                                        value: type.code,
                                        label: type.name,
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) => completeProfileNotifier
                                    .setDocumentType(value),
                                hint: l10n.selectDocumentType,
                                required: true,
                              ),
                              if (completeProfileState
                                      .errors['document_type'] !=
                                  null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    completeProfileState
                                        .errors['document_type']!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: MBETheme.brandRed,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                        loading: () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DSDropdown<String?>(
                              label: l10n.documentType,
                              value: completeProfileState.documentType,
                              items: const [],
                              onChanged: (_) {},
                              hint: l10n.loadingDocumentTypes,
                              required: true,
                              enabled: false,
                            ),
                          ],
                        ),
                        error: (error, _) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DSDropdown<String?>(
                              label: l10n.documentType,
                              value: completeProfileState.documentType,
                              items: const [],
                              onChanged: (_) {},
                              hint: l10n.errorLoadingDocuments,
                              required: true,
                              enabled: false,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Número de Documento
                      DSInput.text(
                        label: l10n.documentNumber,
                        controller: documentNumberController,
                        onChanged: (value) =>
                            completeProfileNotifier.setDocumentNumber(value),
                        required: true,
                        hint: documentConfigsAsync.when(
                          data: (configs) {
                            final config =
                                completeProfileState.documentType != null
                                ? configs.getTypeConfig(
                                    countryCode,
                                    completeProfileState.documentType!,
                                  )
                                : null;
                            return config?.format ?? '12345678-9';
                          },
                          loading: () => '12345678-9',
                          error: (_, __) => '12345678-9',
                        ),
                        keyboardType: documentConfigsAsync.when(
                          data: (configs) {
                            final config =
                                completeProfileState.documentType != null
                                ? configs.getTypeConfig(
                                    countryCode,
                                    completeProfileState.documentType!,
                                  )
                                : null;
                            return config != null &&
                                    config.format.contains(RegExp(r'[A-Za-z]'))
                                ? TextInputType.text
                                : TextInputType.number;
                          },
                          loading: () => TextInputType.number,
                          error: (_, __) => TextInputType.number,
                        ),
                        errorText: completeProfileState.errors['cedula_rnc'],
                        inputFormatters: documentFormatterState.value != null
                            ? [documentFormatterState.value!]
                            : (selectedDocumentConfig?.length != null
                                  ? [
                                      LengthLimitingTextInputFormatter(
                                        selectedDocumentConfig!.length,
                                      ),
                                    ]
                                  : null),
                        maxLength: documentConfigsAsync.when(
                          data: (configs) {
                            final config =
                                completeProfileState.documentType != null
                                ? configs.getTypeConfig(
                                    countryCode,
                                    completeProfileState.documentType!,
                                  )
                                : null;
                            return config?.length;
                          },
                          loading: () => null,
                          error: (_, __) => null,
                        ),
                      ),

                      // Formato esperado
                      documentConfigsAsync.when(
                        data: (configs) {
                          final config =
                              completeProfileState.documentType != null
                              ? configs.getTypeConfig(
                                  countryCode,
                                  completeProfileState.documentType!,
                                )
                              : null;
                          if (config != null) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                config.description.isNotEmpty
                                    ? config.description
                                    : 'Formato: ${config.format}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: MBETheme.neutralGray,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sección: Direcciones
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: MBECardDecoration.card(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hacemos el encabezado scrollable si se desborda en ancho
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Iconsax.location,
                                  size: 24,
                                  color: MBETheme.brandBlack,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.addresses,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            // Botón para agregar nueva dirección
                            TextButton.icon(
                              onPressed: () =>
                                  _showAddAddressModal(context, ref),
                              icon: const Icon(Iconsax.add, size: 18),
                              label: Text(l10n.newAddress),
                              style: TextButton.styleFrom(
                                foregroundColor: MBETheme.brandRed,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.yourAddresses,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: MBETheme.neutralGray,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Lista de direcciones
                      addressesAsync.when(
                        data: (addresses) {
                          if (addresses.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Iconsax.location,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    l10n.noAddresses,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.addAddressHint,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: MBETheme.neutralGray,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          return Column(
                            children: addresses.map((address) {
                              return _AddressCard(
                                address: address,
                                onEdit: () => _showEditAddressModal(
                                  context,
                                  ref,
                                  address,
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, stack) => Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: MBETheme.brandRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Iconsax.danger,
                                color: MBETheme.brandRed,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.errorLoadingAddresses,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: MBETheme.brandRed,
                                  ),
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

              const SizedBox(height: 32),

              // Botón Guardar Perfil
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: DSButton.primary(
                  label: l10n.saveProfile,
                  onPressed: completeProfileState.isLoading
                      ? null
                      : () => _handleSaveProfile(context, ref),
                  isLoading: completeProfileState.isLoading,
                  fullWidth: true,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  bool _isValidPhone(String phone) {
    // Validación básica de teléfono
    final phoneRegex = RegExp(r'^(\d{4}-\d{4}|\d{8}|\+\d{1,3}\d{4,14})$');
    return phoneRegex.hasMatch(phone);
  }

  void _showAddAddressModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddressFormModal(
        onSave: (address) async {
          try {
            final repo = ref.read(addressRepositoryProvider);
            await repo.createAddress(address);
            ref.invalidate(addressesProvider);
            if (context.mounted) {
              Navigator.of(context).pop();
              final l10nSave = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10nSave.addressSavedSuccess(address.name)),
                  backgroundColor: MBETheme.brandBlack,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${AppLocalizations.of(context)!.errorSavingAddress}: ${e.toString()}',
                  ),
                  backgroundColor: MBETheme.brandRed,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditAddressModal(
    BuildContext context,
    WidgetRef ref,
    AddressModel address,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddressFormModal(
        address: address,
        onSave: (updatedAddress) async {
          try {
            final repo = ref.read(addressRepositoryProvider);
            await repo.updateAddress(
              updatedAddress.id.toString(),
              updatedAddress,
            );
            ref.invalidate(addressesProvider);
            if (context.mounted) {
              Navigator.of(context).pop();
              final l10nUpdate = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10nUpdate.addressUpdatedSuccess(updatedAddress.name),
                  ),
                  backgroundColor: MBETheme.brandBlack,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${AppLocalizations.of(context)!.errorUpdatingAddress}: ${e.toString()}',
                  ),
                  backgroundColor: MBETheme.brandRed,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _handleSaveProfile(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(completeProfileProvider.notifier);
    final result = await notifier.saveProfile(l10n);

    if (context.mounted) {
      final l10nSave = AppLocalizations.of(context)!;
      result.when(
        defaultError: l10nSave.unknownError,
        success: () {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10nSave.profileSavedSuccess),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Refrescar el usuario y redirigir después del build
          Future.microtask(() {
            if (context.mounted) {
              ref.invalidate(authProvider);
              // Redirigir al home después de un breve delay
              Future.delayed(const Duration(milliseconds: 500), () {
                if (context.mounted) {
                  context.go('/');
                }
              });
            }
          });
        },
        error: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10nSave.errorSavingProfile}: $error'),
              backgroundColor: MBETheme.brandRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    }
  }
}

// Widget para mostrar una tarjeta de dirección
class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;

  const _AddressCard({required this.address, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: address.isDefault ? MBETheme.brandBlack : Colors.grey[200]!,
          width: address.isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: address.isDefault
                      ? MBETheme.brandBlack
                      : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  address.isDefault ? Iconsax.home_25 : Iconsax.location,
                  color: address.isDefault ? Colors.white : Colors.grey[600],
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (address.isDefault)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: MBETheme.brandBlack,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.defaultAddress,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.edit, size: 18),
                onPressed: onEdit,
                color: MBETheme.brandBlack,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(Iconsax.map_1, address.address),
          const SizedBox(height: 6),
          _InfoRow(Iconsax.global, address.fullLocation),
          const SizedBox(height: 6),
          _InfoRow(Iconsax.call, address.phone),
          if (address.references != null && address.references!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _InfoRow(Iconsax.note_text, address.references!),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[800],
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
