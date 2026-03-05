import 'package:flutter/material.dart';
import 'package:mbe_orders_app/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';

import 'package:mbe_orders_app/config/theme/mbe_theme.dart';
import '../../../providers/create_order_provider.dart';
import '../../../providers/order_processor_provider.dart';
import '../../../providers/print_config_provider.dart';

class Step5Payment extends ConsumerWidget {
  const Step5Payment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.watch(printConfigProvider);
    final orderState = ref.watch(createOrderProvider);
    final orderNotifier = ref.read(createOrderProvider.notifier);
    final processorState = ref.watch(orderProcessorProvider);

    final paymentInfo = orderState.paymentInfo;
    final pricing = orderNotifier.calculatePricing();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: mismo título para todos los métodos; icono según método seleccionado
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
                  child: Icon(
                    _getPaymentIcon(paymentInfo.method),
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
                      Row(
                        children: [
                          Text(
                            '${AppLocalizations.of(context)!.printOrderTotal}: ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '\$${pricing.grandTotal.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: MBETheme.brandBlack,
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

        // Security Badge (solo si es tarjeta)
        if (paymentInfo.method == PaymentMethod.card) ...[
          FadeInUp(
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 50),
            child: Container(
              padding: const EdgeInsets.all(MBESpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(MBERadius.large),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(MBESpacing.sm),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(MBERadius.small),
                    ),
                    child: const Icon(
                      Iconsax.shield_tick,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: MBESpacing.md),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.printOrderSecurePaymentFull,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF059669),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: MBESpacing.lg),
        ],

        // Bloque único: método de pago seleccionado (Efectivo, Transferencia o Tarjeta)
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.all(MBESpacing.xl),
            decoration: MBECardDecoration.card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.printOrderPaymentMethodSelected,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: MBESpacing.md),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(MBESpacing.md),
                      decoration: BoxDecoration(
                        color: MBETheme.brandBlack.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(MBERadius.medium),
                      ),
                      child: Icon(
                        _getPaymentIcon(paymentInfo.method),
                        size: 28,
                        color: MBETheme.brandBlack,
                      ),
                    ),
                    const SizedBox(width: MBESpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getPaymentMethodName(context, paymentInfo.method),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: MBESpacing.xs),
                          Text(
                            paymentInfo.method == PaymentMethod.card
                                ? AppLocalizations.of(
                                    context,
                                  )!.printOrderCardStepDescription
                                : _getPaymentDescription(
                                    context,
                                    paymentInfo.method,
                                  ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: MBESpacing.lg),

        // Payment Summary
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.all(MBESpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MBETheme.brandBlack,
                  MBETheme.brandBlack.withValues(alpha: 0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(MBERadius.large),
              boxShadow: MBETheme.shadowLg,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.printOrderAmountToPay,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '\$${pricing.grandTotal.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MBESpacing.md),
                Container(
                  padding: const EdgeInsets.all(MBESpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(MBERadius.medium),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getPaymentIcon(paymentInfo.method),
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: MBESpacing.sm),
                      Expanded(
                        child: Text(
                          '${AppLocalizations.of(context)!.printOrderPaymentMethodLabel}: ${_getPaymentMethodName(context, paymentInfo.method)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
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

        const SizedBox(height: MBESpacing.lg),

        // Mostrar error si hay
        if (processorState.isError) ...[
          FadeInUp(
            duration: const Duration(milliseconds: 400),
            child: Container(
              padding: const EdgeInsets.all(MBESpacing.md),
              decoration: BoxDecoration(
                color: MBETheme.brandRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(MBERadius.medium),
                border: Border.all(
                  color: MBETheme.brandRed.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.warning_2, size: 18, color: MBETheme.brandRed),
                  const SizedBox(width: MBESpacing.sm),
                  Expanded(
                    child: Text(
                      processorState.errorMessage ??
                          AppLocalizations.of(
                            context,
                          )!.printOrderErrorProcessing,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: MBETheme.brandRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: MBESpacing.lg),
        ],

        // Terms
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 350),
          child: Container(
            padding: const EdgeInsets.all(MBESpacing.md),
            decoration: BoxDecoration(
              color: MBETheme.lightGray,
              borderRadius: BorderRadius.circular(MBERadius.medium),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Iconsax.info_circle,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: MBESpacing.sm),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.printOrderTermsAccept,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
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

  String _getPaymentDescription(BuildContext context, PaymentMethod method) {
    final l10n = AppLocalizations.of(context)!;
    switch (method) {
      case PaymentMethod.cash:
        return l10n.printOrderCashPaymentDesc;
      case PaymentMethod.transfer:
        return l10n.printOrderTransferPaymentDesc;
      case PaymentMethod.card:
        return l10n.printOrderCardPaymentDesc;
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

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Iconsax.money;
      case PaymentMethod.transfer:
        return Iconsax.bank;
      case PaymentMethod.card:
        return Iconsax.card;
    }
  }
}
