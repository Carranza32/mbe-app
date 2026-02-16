import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide Orientation;
import 'package:mbe_orders_app/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';

import 'package:mbe_orders_app/config/theme/mbe_theme.dart';
import '../../../../../core/design_system/ds_badges.dart';
import '../../../../../core/design_system/ds_inputs.dart';
import '../../../../auth/providers/auth_provider.dart';

import '../../../providers/create_order_provider.dart';

Future<void> _pickTransferProof(
  BuildContext context,
  WidgetRef ref,
  CreateOrder orderNotifier,
  PaymentInfo paymentInfo,
) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    allowMultiple: false,
  );
  if (result == null || result.files.single.path == null) return;
  final path = result.files.single.path!;
  final name = result.files.single.name;
  orderNotifier.setPaymentTransferProof(path, name);
}

class Step4Confirmation extends HookConsumerWidget {
  final String? userName;
  final String? userEmail;
  final String? userPhone;

  const Step4Confirmation({super.key, this.userName, this.userEmail, this.userPhone});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final authState = ref.watch(authProvider);
    final user = authState.value;
    final orderState = ref.watch(createOrderProvider);
    final orderNotifier = ref.read(createOrderProvider.notifier);

    final customerInfo = orderState.request?.customerInfo;
    final printConfig = orderState.request?.printConfig;
    final deliveryInfo = orderState.request?.deliveryInfo;
    final paymentInfo = orderState.paymentInfo;

    final pricing = orderNotifier.calculatePricing();

    // Fuente única: usuario logueado (auth) o props del padre; así se llena siempre aunque el padre no haya pasado datos aún
    final fromUser = user?.name ?? user?.customer?.name ?? '';
    final fromUserEmail = user?.email ?? user?.customer?.email ?? '';
    final fromUserPhone = user?.customer?.phone ?? user?.customer?.homePhone ?? user?.customer?.officePhone ?? '';
    final effectiveName = (customerInfo?.name ?? '').isEmpty ? (userName ?? fromUser) : customerInfo!.name;
    final effectiveEmail = (customerInfo?.email ?? '').isEmpty ? (userEmail ?? fromUserEmail) : customerInfo!.email;
    final effectivePhone = (customerInfo?.phone ?? '').isEmpty ? (userPhone ?? fromUserPhone) : (customerInfo!.phone ?? '');

    // Sincronizar al provider si tenemos datos del usuario y el estado está vacío (para que se llene siempre a la primera)
    final needsSyncName = effectiveName.isNotEmpty && (customerInfo == null || customerInfo.name.isEmpty);
    final needsSyncEmail = effectiveEmail.isNotEmpty && (customerInfo == null || customerInfo.email.isEmpty);
    final needsSyncPhone = effectivePhone.isNotEmpty && (customerInfo == null || (customerInfo.phone ?? '').isEmpty);
    if (needsSyncName || needsSyncEmail || needsSyncPhone) {
      Future.microtask(() {
        if (needsSyncName) orderNotifier.setCustomerName(effectiveName);
        if (needsSyncEmail) orderNotifier.setCustomerEmail(effectiveEmail);
        if (needsSyncPhone) orderNotifier.setCustomerPhone(effectivePhone);
      });
    }

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
                    Iconsax.clipboard_tick,
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
                        AppLocalizations.of(context)!.printOrderConfirmTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: MBESpacing.xs),
                      Text(
                        AppLocalizations.of(context)!.printOrderConfirmSubtitle,
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

        // Información de Contacto
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.all(MBESpacing.lg),
            decoration: MBECardDecoration.card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Iconsax.user,
                      size: 24,
                      color: colorScheme.onSurface,
                    ),
                    const SizedBox(width: MBESpacing.md),
                    Text(
                      'Información de Contacto',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: MBESpacing.xl),

                // Nombre Completo (prellenado con usuario logueado; fuente: auth o props)
                DSInput.text(
                  label: AppLocalizations.of(context)!.preAlertFullName,
                  value: effectiveName,
                  onChanged: (value) => orderNotifier.setCustomerName(value),
                  required: true,
                  prefixIcon: Iconsax.user,
                ),

                const SizedBox(height: MBESpacing.lg),

                // Correo Electrónico
                DSInput.email(
                  label: AppLocalizations.of(context)!.authEmail,
                  value: effectiveEmail,
                  onChanged: (value) => orderNotifier.setCustomerEmail(value),
                  required: true,
                ),

                const SizedBox(height: MBESpacing.lg),

                // Teléfono
                DSInput.phone(
                  label: 'Teléfono (opcional)',
                  value: effectivePhone,
                  onChanged: (value) => orderNotifier.setCustomerPhone(value),
                ),

                const SizedBox(height: MBESpacing.lg),

                // Notas Adicionales
                DSInput.textArea(
                  label: 'Notas Adicionales (opcional)',
                  hint: 'Alguna instrucción especial...',
                  value: customerInfo?.notes ?? '',
                  onChanged: (value) => orderNotifier.setCustomerNotes(value),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: MBESpacing.lg),

        // Método de Pago
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.all(MBESpacing.lg),
            decoration: MBECardDecoration.card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Iconsax.wallet_2,
                      size: 24,
                      color: colorScheme.onSurface,
                    ),
                    const SizedBox(width: MBESpacing.md),
                    Text(
                      AppLocalizations.of(context)!.preAlertPaymentMethod,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: MBESpacing.lg),

                // Solo Efectivo y Transferencia (igual que pre-alertas)
                _PaymentOption(
                  icon: Iconsax.money,
                  title: AppLocalizations.of(context)!.printOrderPaymentCash,
                  subtitle: AppLocalizations.of(context)!.printOrderPaymentCashDesc,
                  isSelected: paymentInfo.method == PaymentMethod.cash,
                  onTap: () => orderNotifier.setPaymentMethod(PaymentMethod.cash),
                  badge: DSBadge.success(label: AppLocalizations.of(context)!.preAlertNoAdditionalCost),
                ),

                const SizedBox(height: MBESpacing.md),

                _PaymentOption(
                  icon: Iconsax.bank,
                  title: 'Transferencia',
                  subtitle: 'Banco Agrícola, BAC, etc. Sube tu comprobante.',
                  isSelected: paymentInfo.method == PaymentMethod.transfer,
                  onTap: () => orderNotifier.setPaymentMethod(PaymentMethod.transfer),
                ),

                // Comprobante de transferencia (obligatorio)
                if (paymentInfo.method == PaymentMethod.transfer) ...[
                  const SizedBox(height: MBESpacing.lg),
                  Text(
                    AppLocalizations.of(context)!.preAlertTransferProof,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: MBESpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () => _pickTransferProof(context, ref, orderNotifier, paymentInfo),
                    icon: const Icon(Iconsax.document_upload, size: 20),
                    label: Text(
                      paymentInfo.transferProofFileName ?? 'Seleccionar imagen o PDF',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(MBERadius.medium),
                      ),
                    ),
                  ),
                  if (paymentInfo.transferProofFileName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: MBESpacing.xs),
                      child: Row(
                        children: [
                          Icon(Iconsax.tick_circle, size: 16, color: MBETheme.brandBlack),
                          const SizedBox(width: MBESpacing.xs),
                          Expanded(
                            child: Text(
                              paymentInfo.transferProofFileName!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: MBESpacing.lg),

        // Resumen del Pedido CON DATOS REALES
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.all(MBESpacing.lg),
            decoration: BoxDecoration(
              color: MBETheme.lightGray,
              borderRadius: BorderRadius.circular(MBERadius.large),
              border: Border.all(
                color: MBETheme.neutralGray.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(MBESpacing.sm),
                      decoration: BoxDecoration(
                        color: MBETheme.brandBlack,
                        borderRadius: BorderRadius.circular(MBERadius.small),
                      ),
                      child: const Icon(
                        Iconsax.receipt_text,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: MBESpacing.md),
                    Text(
                      AppLocalizations.of(context)!.printOrderOrderSummary,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: MBESpacing.xl),

                // Archivos
                _SummarySection(
                  icon: Iconsax.document,
                  title: 'Archivos',
                  items: [
                    _SummaryItem(
                      'Documentos:',
                      '${orderState.uploadedFiles.length}',
                    ),
                    _SummaryItem(
                      'Total páginas:',
                      '${orderState.totalPages ?? 0}',
                    ),
                  ],
                ),

                const SizedBox(height: MBESpacing.lg),
                const Divider(),
                const SizedBox(height: MBESpacing.lg),

                // Configuración
                _SummarySection(
                  icon: Iconsax.setting_2,
                  title: AppLocalizations.of(context)!.printOrderConfig,
                  items: [
                    _SummaryItem(
                      '${AppLocalizations.of(context)!.printOrderTypeLabel}:',
                      printConfig?.printType == 'bw' 
                          ? AppLocalizations.of(context)!.printOrderBwLabel 
                          : AppLocalizations.of(context)!.printOrderColorLabel,
                    ),
                    _SummaryItem(
                      '${AppLocalizations.of(context)!.printOrderSizeLabel}:',
                      _getPaperSizeName(context, printConfig?.paperSize ?? 'letter'),
                    ),
                    _SummaryItem(
                      '${AppLocalizations.of(context)!.printOrderOrientationLabel}:',
                      printConfig?.orientation == 'portrait' 
                          ? AppLocalizations.of(context)!.printOrderOrientationPortrait 
                          : AppLocalizations.of(context)!.printOrderOrientationLandscape,
                    ),
                    _SummaryItem(
                      '${AppLocalizations.of(context)!.printOrderCopiesLabel}:',
                      '${printConfig?.copies ?? 1}',
                    ),
                    if (printConfig?.doubleSided == true)
                      _SummaryItem(
                        '${AppLocalizations.of(context)!.printOrderDoubleSided}:',
                        AppLocalizations.of(context)!.printOrderYes,
                      ),
                    if (printConfig?.binding == true)
                      _SummaryItem(
                        '${AppLocalizations.of(context)!.printOrderBinding}:',
                        AppLocalizations.of(context)!.printOrderYes,
                      ),
                  ],
                ),

                const SizedBox(height: MBESpacing.lg),
                const Divider(),
                const SizedBox(height: MBESpacing.lg),

                // Entrega
                _SummarySection(
                  icon: Iconsax.truck,
                  title: 'Entrega',
                  items: [
                    _SummaryItem(
                      'Método:',
                      deliveryInfo?.method == 'pickup' 
                          ? 'Recoger en tienda' 
                          : 'Envío a domicilio',
                    ),
                    if (deliveryInfo?.method == 'delivery' && 
                        deliveryInfo?.address != null &&
                        deliveryInfo!.address!.isNotEmpty)
                      _SummaryItem(
                        'Dirección:',
                        deliveryInfo.address!.length > 30
                            ? '${deliveryInfo.address!.substring(0, 30)}...'
                            : deliveryInfo.address!,
                      ),
                  ],
                ),

                const SizedBox(height: MBESpacing.xl),

                // Desglose de Costos CON DATOS REALES
                Container(
                  padding: const EdgeInsets.all(MBESpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(MBERadius.medium),
                    boxShadow: MBETheme.shadowSm,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Iconsax.dollar_circle,
                            size: 20,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: MBESpacing.sm),
                          Text(
                            AppLocalizations.of(context)!.printOrderCostBreakdown,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: MBESpacing.lg),
                      
                      // Subtotal de impresión
                      _CostRow(
                        AppLocalizations.of(context)!.printOrderPrintSubtotal,
                        '\$${pricing.printSubtotal.toStringAsFixed(2)}',
                      ),
                      
                      const SizedBox(height: MBESpacing.sm),
                      
                      // IVA
                      // _CostRow(
                      //   'IVA (13%)',
                      //   '\$${printPricing.tax.toStringAsFixed(2)}',
                      // ),
                      
                      // Envío (si aplica)
                      if (pricing.deliveryCost > 0) ...[
                        const SizedBox(height: MBESpacing.sm),
                        _CostRow(
                          AppLocalizations.of(context)!.printOrderShippingCost,
                          '\$${pricing.deliveryCost.toStringAsFixed(2)}',
                        ),
                      ],
                      
                      // Envío gratis
                      if (deliveryInfo?.method == 'delivery' && pricing.isFreeDelivery) ...[
                        const SizedBox(height: MBESpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.printOrderShippingCost,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '\$0.00',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(width: MBESpacing.xs),
                                const Icon(
                                  Iconsax.tick_circle,
                                  size: 16,
                                  color: Color(0xFF10B981),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                      
                      const SizedBox(height: MBESpacing.lg),
                      const Divider(),
                      const SizedBox(height: MBESpacing.lg),
                      
                      // Total final
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.printOrderTotal,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '\$${pricing.grandTotal.toStringAsFixed(2)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: MBETheme.brandBlack,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: MBESpacing.md),
                      Row(
                        children: [
                          const Icon(
                            Iconsax.wallet_2,
                            size: 16,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: MBESpacing.xs),
                          Text(
                            '${AppLocalizations.of(context)!.printOrderPaymentMethodLabel} ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            _getPaymentMethodName(context, paymentInfo.method),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
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
        ),

        const SizedBox(height: MBESpacing.lg),

        // Mensaje de confirmación
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 400),
          child: Container(
            padding: const EdgeInsets.all(MBESpacing.lg),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(MBERadius.large),
              border: Border.all(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Iconsax.receipt_discount,
                  color: Color(0xFF3B82F6),
                  size: 24,
                ),
                const SizedBox(width: MBESpacing.md),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.printOrderEmailConfirmation,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF1E40AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: MBESpacing.xxxl),
      ],
    );
  }

  String _getPaperSizeName(BuildContext context, String size) {
    final l10n = AppLocalizations.of(context)!;
    switch (size) {
      case 'letter':
        return l10n.printOrderLetter;
      case 'legal':
        return l10n.printOrderLegal;
      case 'double_letter':
        return l10n.printOrderDoubleLetter;
      default:
        return l10n.printOrderLetter;
    }
  }
}

// Widgets auxiliares
class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? badge;

  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: MBEDuration.normal,
        padding: const EdgeInsets.all(MBESpacing.md),
        decoration: BoxDecoration(
          color: isSelected 
              ? MBETheme.brandBlack.withValues(alpha: 0.03)
              : MBETheme.lightGray,
          borderRadius: BorderRadius.circular(MBERadius.medium),
          border: Border.all(
            color: isSelected 
                ? MBETheme.brandBlack 
                : MBETheme.neutralGray.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: MBEDuration.normal,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? MBETheme.brandBlack : MBETheme.neutralGray,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: MBETheme.brandBlack,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: MBESpacing.md),
            Icon(icon, size: 24, color: colorScheme.onSurface),
            const SizedBox(width: MBESpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: MBESpacing.sm),
                        badge!,
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_SummaryItem> items;

  const _SummarySection({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: MBETheme.neutralGray),
            const SizedBox(width: MBESpacing.sm),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: MBESpacing.sm),
        ...items,
      ],
    );
  }
}

String _getPaymentMethodName(BuildContext context, PaymentMethod method) {
  final l10n = AppLocalizations.of(context)!;
  switch (method) {
    case PaymentMethod.card:
      return l10n.printOrderPaymentCard;
    case PaymentMethod.cash:
      return l10n.printOrderPaymentCash;
    case PaymentMethod.transfer:
      return l10n.printOrderPaymentTransfer;
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: MBESpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String amount;

  const _CostRow(this.label, this.amount);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          amount,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}