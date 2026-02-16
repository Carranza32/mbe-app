import 'package:flutter/material.dart';
import 'package:mbe_orders_app/l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mbe_orders_app/config/theme/mbe_theme.dart';
import 'package:mbe_orders_app/core/design_system/ds_inputs.dart';
import 'package:mbe_orders_app/core/design_system/ds_selection_cards.dart';
import '../../../data/models/pre_alert_model.dart';
import '../../../providers/pre_alert_complete_provider.dart';
import '../../../../auth/providers/auth_provider.dart';

class Step2Contact extends HookConsumerWidget {
  final PreAlert preAlert;

  const Step2Contact({Key? key, required this.preAlert}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Obtener datos del usuario autenticado
    final authState = ref.watch(authProvider);
    final user = authState.value;

    // Usar el provider para manejar el estado
    final completeState = ref.watch(preAlertCompleteProvider(preAlert));
    final completeNotifier = ref.read(
      preAlertCompleteProvider(preAlert).notifier,
    );

    // Obtener valores iniciales: primero del estado, luego del usuario
    final initialName = completeState.contactName ?? user?.name ?? '';
    final initialEmail = completeState.contactEmail ?? user?.email ?? '';
    final initialPhone =
        completeState.contactPhone ??
        user?.customer?.phone ??
        user?.customer?.homePhone ??
        user?.customer?.officePhone ??
        '';

    final nameController = useTextEditingController(text: initialName);
    final emailController = useTextEditingController(text: initialEmail);
    final phoneController = useTextEditingController(text: initialPhone);
    final notesController = useTextEditingController(
      text: completeState.contactNotes ?? '',
    );

    final receiverNameController = useTextEditingController(
      text: completeState.receiverName ?? '',
    );
    final receiverEmailController = useTextEditingController(
      text: completeState.receiverEmail ?? '',
    );
    final receiverPhoneController = useTextEditingController(
      text: completeState.receiverPhone ?? '',
    );

    final isDifferentReceiver = useState(completeState.isDifferentReceiver);

    // Inicializar los valores en el provider si no están establecidos
    // Usar Future para evitar modificar el provider durante el build
    useEffect(() {
      Future.microtask(() {
        if (completeState.contactName == null && user?.name != null) {
          completeNotifier.setContactInfo(name: user!.name);
        }
        if (completeState.contactEmail == null && user?.email != null) {
          completeNotifier.setContactInfo(email: user!.email);
        }
        if (completeState.contactPhone == null) {
          final phone =
              user?.customer?.phone ??
              user?.customer?.homePhone ??
              user?.customer?.officePhone;
          if (phone != null && phone.isNotEmpty) {
            completeNotifier.setContactInfo(phone: phone);
          }
        }
      });
      return null;
    }, []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header del paso
        FadeInDown(
          duration: const Duration(milliseconds: 400),
          child: Container(
            padding: const EdgeInsets.all(MBESpacing.lg),
            decoration: MBECardDecoration.card(),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(MBESpacing.md),
                  decoration: BoxDecoration(
                    color: MBETheme.brandBlack,
                    borderRadius: BorderRadius.circular(MBERadius.medium),
                    boxShadow: MBETheme.shadowSm,
                  ),
                  child: const Icon(
                    Iconsax.profile_circle,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: MBESpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.preAlertContactInfoTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: MBESpacing.xs),
                      Text(
                        l10n.preAlertContactInfoSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: MBESpacing.lg),

        // Formulario
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 100),
          child: Column(
            children: [
              DSInput.text(
                label: l10n.preAlertFullName,
                hint: l10n.preAlertFullNameHint,
                controller: nameController,
                prefixIcon: Iconsax.user,
                onChanged: (value) {
                  completeNotifier.setContactInfo(name: value);
                },
                required: true,
              ),

              const SizedBox(height: MBESpacing.md),

              DSInput.text(
                label: l10n.preAlertEmailLabel,
                hint: l10n.preAlertEmailHint,
                controller: emailController,
                prefixIcon: Iconsax.sms,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  completeNotifier.setContactInfo(email: value);
                },
                required: true,
              ),

              const SizedBox(height: MBESpacing.md),

              DSInput.phone(
                label: l10n.preAlertPhoneLabel,
                hint: l10n.preAlertPhoneHint,
                controller: phoneController,
                onChanged: (value) {
                  completeNotifier.setContactInfo(phone: value);
                },
                required: true,
              ),

              const SizedBox(height: MBESpacing.md),

              DSInput.textArea(
                label: 'Notas adicionales (opcional)',
                hint: 'Ej: Llamar antes de recoger, horario preferido...',
                controller: notesController,
                maxLines: 3,
                onChanged: (value) {
                  completeNotifier.setContactInfo(notes: value);
                },
                required: false,
              ),

              const SizedBox(height: MBESpacing.lg),

              // Opción de receptor diferente
              DSOptionCard(
                title: l10n.preAlertDifferentReceiver,
                description: l10n.preAlertDifferentReceiverDesc,
                icon: Iconsax.user_add,
                isSelected: isDifferentReceiver.value,
                onTap: () {
                  isDifferentReceiver.value = !isDifferentReceiver.value;
                  completeNotifier.setDifferentReceiver(
                    isDifferentReceiver.value,
                  );
                },
              ),

              // Información del receptor si es diferente
              if (isDifferentReceiver.value) ...[
                const SizedBox(height: MBESpacing.lg),
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 100),
                  child: Container(
                    padding: const EdgeInsets.all(MBESpacing.lg),
                    decoration: BoxDecoration(
                      color: MBETheme.brandBlack.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(MBERadius.large),
                      border: Border.all(
                        color: MBETheme.brandBlack.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Iconsax.user_tick,
                              color: MBETheme.brandBlack,
                              size: 20,
                            ),
                            const SizedBox(width: MBESpacing.sm),
                            Text(
                              'Información del Receptor',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: MBESpacing.lg),
                        DSInput.text(
                          label: l10n.preAlertReceiverName,
                          hint: l10n.preAlertReceiverNameHint,
                          controller: receiverNameController,
                          prefixIcon: Iconsax.user,
                          onChanged: (value) {
                            completeNotifier.setReceiverInfo(name: value);
                          },
                          required: true,
                        ),
                        const SizedBox(height: MBESpacing.md),
                        DSInput.text(
                          label: l10n.preAlertReceiverEmail,
                          hint: l10n.preAlertEmailHint,
                          controller: receiverEmailController,
                          prefixIcon: Iconsax.sms,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            completeNotifier.setReceiverInfo(email: value);
                          },
                          required: true,
                        ),
                        const SizedBox(height: MBESpacing.md),
                        DSInput.phone(
                          label: l10n.preAlertReceiverPhone,
                          hint: l10n.preAlertPhoneHint,
                          controller: receiverPhoneController,
                          onChanged: (value) {
                            completeNotifier.setReceiverInfo(phone: value);
                          },
                          required: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
