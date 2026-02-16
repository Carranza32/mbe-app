import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mbe_orders_app/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mbe_orders_app/config/theme/mbe_theme.dart';
import 'package:mbe_orders_app/core/design_system/ds_selection_cards.dart';
import '../../../data/models/pre_alert_model.dart';
import '../../../providers/pre_alert_complete_provider.dart';

class Step3Payment extends ConsumerStatefulWidget {
  final PreAlert preAlert;

  const Step3Payment({Key? key, required this.preAlert}) : super(key: key);

  @override
  ConsumerState<Step3Payment> createState() => _Step3PaymentState();
}

class _Step3PaymentState extends ConsumerState<Step3Payment> {
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickTransferProof(PreAlertCompleteState state) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      allowMultiple: false,
    );
    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;
    final name = result.files.single.name;
    ref.read(preAlertCompleteProvider(widget.preAlert).notifier).setPaymentData({
      ...?state.paymentData,
      'filePath': path,
      'fileName': name,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final completeState = ref.watch(preAlertCompleteProvider(widget.preAlert));
    final completeNotifier = ref.read(
      preAlertCompleteProvider(widget.preAlert).notifier,
    );
    final preAlert = widget.preAlert;

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
                    Iconsax.dollar_circle,
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
                        'Información de Pago',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: MBESpacing.xs),
                      Text(
                        l10n.preAlertPaymentInfoSubtitle,
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

        // Resumen del total
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.all(MBESpacing.lg),
            decoration: BoxDecoration(
              color: MBETheme.brandBlack.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(MBERadius.large),
              border: Border.all(
                color: MBETheme.brandBlack.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total a pagar',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: MBESpacing.xs),
                    Text(
                      '\$${preAlert.totalValue.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: MBETheme.brandBlack,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Iconsax.dollar_circle,
                  size: 32,
                  color: MBETheme.brandBlack,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: MBESpacing.lg),

        // Selección de método de pago
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.preAlertPaymentMethod,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: MBESpacing.md),
              DSOptionCard(
                title: 'Transferencia bancaria',
                description:
                    'Sube el comprobante de transferencia (imagen o PDF). Será revisado por el equipo.',
                icon: Iconsax.bank,
                isSelected: completeState.paymentMethod == 'transfer',
                onTap: () {
                  completeNotifier.setPaymentMethod('transfer');
                },
              ),
              const SizedBox(height: MBESpacing.md),
              DSOptionCard(
                title: l10n.preAlertCashOnDelivery,
                description: l10n.preAlertCashOnDeliveryDesc,
                icon: Iconsax.money_recive,
                isSelected: completeState.paymentMethod == 'cash',
                onTap: () {
                  completeNotifier.setPaymentMethod('cash');
                },
              ),
            ],
          ),
        ),

        // Formulario transferencia: comprobante + referencia + notas
        if (completeState.paymentMethod == 'transfer') ...[
          const SizedBox(height: MBESpacing.lg),
          FadeInUp(
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(MBESpacing.lg),
              decoration: BoxDecoration(
                color: MBETheme.brandBlack.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(MBERadius.medium),
                border: Border.all(
                  color: MBETheme.brandBlack.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.preAlertTransferProof,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: MBESpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () => _pickTransferProof(completeState),
                    icon: const Icon(Iconsax.document_upload, size: 20),
                    label: Text(
                      completeState.paymentData?['fileName'] != null
                          ? completeState.paymentData!['fileName'] as String
                          : 'Seleccionar imagen o PDF',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(MBERadius.medium),
                      ),
                    ),
                  ),
                  if (completeState.paymentData?['filePath'] != null) ...[
                    const SizedBox(height: MBESpacing.sm),
                    Text(
                      l10n.preAlertProofSelected,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: MBESpacing.lg),
                  TextField(
                    controller: _referenceController,
                    decoration: InputDecoration(
                      labelText: l10n.preAlertBankReferenceOptional,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) {
                      completeNotifier.setPaymentData({
                        ...?completeState.paymentData,
                        'transferReference': v,
                      });
                    },
                  ),
                  const SizedBox(height: MBESpacing.md),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: l10n.preAlertNotesOptionalLabel,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    maxLines: 2,
                    onChanged: (v) {
                      completeNotifier.setPaymentData({
                        ...?completeState.paymentData,
                        'transferNotes': v,
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],

        // Info efectivo
        if (completeState.paymentMethod == 'cash') ...[
          const SizedBox(height: MBESpacing.lg),
          FadeInUp(
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(MBESpacing.lg),
              decoration: BoxDecoration(
                color: MBETheme.brandBlack.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(MBERadius.medium),
                border: Border.all(
                  color: MBETheme.brandBlack.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.info_circle,
                    color: MBETheme.brandBlack,
                    size: 24,
                  ),
                  const SizedBox(width: MBESpacing.md),
                  Expanded(
                    child: Text(
                      l10n.preAlertCashPaymentInfo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
