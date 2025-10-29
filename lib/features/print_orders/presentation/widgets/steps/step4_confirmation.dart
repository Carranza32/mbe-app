import 'package:flutter/material.dart' hide Orientation;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';

import 'package:mbe_orders_app/config/theme/mbe_theme.dart';
import '../../../../../core/design_system/ds_badges.dart';
import '../../../../../core/design_system/ds_inputs.dart';

import '../../../providers/print_order_provider.dart';
import '../../../providers/print_configuration_state_provider.dart';
import '../../../providers/print_pricing_provider.dart';
import '../../../providers/delivery_state_provider.dart';
import '../../../providers/delivery_pricing_provider.dart';
import '../../../providers/order_total_provider.dart';
import '../../../providers/confirmation_state_provider.dart';

class Step4Confirmation extends HookConsumerWidget {
  const Step4Confirmation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Estados desde providers
    final confirmationState = ref.watch(confirmationStateProvider);
    final confirmationNotifier = ref.read(confirmationStateProvider.notifier);
    
    // Datos del pedido
    final orderState = ref.watch(printOrderProvider);
    final printConfig = ref.watch(printConfigurationStateProvider);
    final printPricing = ref.watch(printPricingProvider);
    final deliveryState = ref.watch(deliveryStateProvider);
    final deliveryPricing = ref.watch(deliveryPricingProvider);
    final orderTotal = ref.watch(orderTotalCalculatorProvider);

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
                        'Confirmar Pedido',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: MBESpacing.xs),
                      Text(
                        'Revisa y completa tu información',
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

                // Nombre Completo
                DSInput.text(
                  label: 'Nombre Completo',
                  value: confirmationState.fullName,
                  onChanged: (value) => confirmationNotifier.setFullName(value),
                  required: true,
                  prefixIcon: Iconsax.user,
                ),

                const SizedBox(height: MBESpacing.lg),

                // Correo Electrónico
                DSInput.email(
                  label: 'Correo Electrónico',
                  value: confirmationState.email,
                  onChanged: (value) => confirmationNotifier.setEmail(value),
                  required: true,
                ),

                const SizedBox(height: MBESpacing.lg),

                // Teléfono
                DSInput.phone(
                  label: 'Teléfono (opcional)',
                  value: confirmationState.phone,
                  onChanged: (value) => confirmationNotifier.setPhone(value),
                ),

                const SizedBox(height: MBESpacing.lg),

                // Notas Adicionales
                DSInput.textArea(
                  label: 'Notas Adicionales (opcional)',
                  hint: 'Alguna instrucción especial...',
                  value: confirmationState.notes,
                  onChanged: (value) => confirmationNotifier.setNotes(value),
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
                      'Método de Pago',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: MBESpacing.lg),

                // Tarjeta
                _PaymentOption(
                  icon: Iconsax.card,
                  title: 'Tarjeta',
                  subtitle: 'Débito o crédito',
                  isSelected: confirmationState.paymentMethod == PaymentMethod.card,
                  onTap: () => confirmationNotifier.setPaymentMethod(PaymentMethod.card),
                ),

                const SizedBox(height: MBESpacing.md),

                // Efectivo
                _PaymentOption(
                  icon: Iconsax.money,
                  title: 'Efectivo',
                  subtitle: 'Paga al recibir tu pedido',
                  isSelected: confirmationState.paymentMethod == PaymentMethod.cash,
                  onTap: () => confirmationNotifier.setPaymentMethod(PaymentMethod.cash),
                  badge: DSBadge.success(label: 'Sin cargo extra'),
                ),

                const SizedBox(height: MBESpacing.md),

                // Transferencia
                _PaymentOption(
                  icon: Iconsax.bank,
                  title: 'Transferencia',
                  subtitle: 'Banco Agrícola, BAC, etc.',
                  isSelected: confirmationState.paymentMethod == PaymentMethod.transfer,
                  onTap: () => confirmationNotifier.setPaymentMethod(PaymentMethod.transfer),
                ),
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
                      'Resumen del Pedido',
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
                      '${orderState.files.length}',
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
                  title: 'Configuración',
                  items: [
                    _SummaryItem(
                      'Tipo:',
                      printConfig.printType == PrintType.blackWhite 
                          ? 'Blanco y Negro' 
                          : 'Color',
                    ),
                    _SummaryItem(
                      'Tamaño:',
                      _getPaperSizeName(printConfig.paperSize),
                    ),
                    _SummaryItem(
                      'Orientación:',
                      printConfig.orientation == Orientation.vertical 
                          ? 'Vertical' 
                          : 'Horizontal',
                    ),
                    _SummaryItem(
                      'Copias:',
                      '${printConfig.copies}',
                    ),
                    if (printConfig.doubleSided)
                      _SummaryItem(
                        'Doble cara:',
                        'Sí',
                      ),
                    if (printConfig.binding)
                      _SummaryItem(
                        'Engargolado:',
                        'Sí',
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
                      deliveryState.isPickup 
                          ? 'Recoger en tienda' 
                          : 'Envío a domicilio',
                    ),
                    if (deliveryState.isDelivery && deliveryState.deliveryAddress.isNotEmpty)
                      _SummaryItem(
                        'Dirección:',
                        deliveryState.deliveryAddress.length > 30
                            ? '${deliveryState.deliveryAddress.substring(0, 30)}...'
                            : deliveryState.deliveryAddress,
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
                            'Desglose de Costos',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: MBESpacing.lg),
                      
                      // Subtotal de impresión
                      _CostRow(
                        'Subtotal impresión',
                        '\$${printPricing.subtotal.toStringAsFixed(2)}',
                      ),
                      
                      const SizedBox(height: MBESpacing.sm),
                      
                      // IVA
                      _CostRow(
                        'IVA (13%)',
                        '\$${printPricing.tax.toStringAsFixed(2)}',
                      ),
                      
                      // Envío (si aplica)
                      if (deliveryPricing.deliveryCost > 0) ...[
                        const SizedBox(height: MBESpacing.sm),
                        _CostRow(
                          'Envío',
                          '\$${deliveryPricing.deliveryCost.toStringAsFixed(2)}',
                        ),
                      ],
                      
                      // Envío gratis
                      if (deliveryState.isDelivery && deliveryPricing.isFreeDelivery) ...[
                        const SizedBox(height: MBESpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Envío',
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
                            'Total',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '\$${orderTotal.grandTotal.toStringAsFixed(2)}',
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
                            'Método de pago: ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            confirmationState.getPaymentMethodName(),
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
                    'Recibirás un correo con los detalles de tu pedido',
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

  String _getPaperSizeName(PaperSize size) {
    switch (size) {
      case PaperSize.letter:
        return 'Carta';
      case PaperSize.legal:
        return 'Legal';
      case PaperSize.doubleLetter:
        return 'Doble Carta';
    }
  }
}

// Widgets auxiliares (mantén los mismos que ya tienes)...
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