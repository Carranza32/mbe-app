import 'package:flutter/material.dart';
import 'package:mbe_orders_app/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
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
    final showCardForm = paymentInfo.method == PaymentMethod.card;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
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
                    showCardForm ? Iconsax.card : Iconsax.money,
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
                        showCardForm ? AppLocalizations.of(context)!.printOrderMakePayment : AppLocalizations.of(context)!.printOrderConfirmTitle,
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
        if (showCardForm) ...[
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
                      'Pago 100% seguro y encriptado',
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
          const SizedBox(height: MBESpacing.xl),
        ],

        // Contenido según método de pago
        if (showCardForm) ...[
          // 🎴 Vista previa simple de la tarjeta
          FadeInUp(
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 100),
            child: _CardPreview(paymentInfo: paymentInfo),
          ),

          const SizedBox(height: MBESpacing.xl),

          // 📝 Formulario simple
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
                        Iconsax.card_pos,
                        size: 24,
                        color: colorScheme.onSurface,
                      ),
                      const SizedBox(width: MBESpacing.md),
                      Text(
                        AppLocalizations.of(context)!.printOrderCardInfo,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: MBESpacing.xl),

                  // 🎯 Campos individuales simples
                  _CardNumberField(
                    initialValue: paymentInfo.cardNumber ?? '',
                    onChanged: (value) {
                      orderNotifier.setCardNumber(value);
                    },
                  ),

                  const SizedBox(height: MBESpacing.lg),

                  _CardHolderField(
                    initialValue: paymentInfo.cardHolder ?? '',
                    onChanged: (value) {
                      orderNotifier.setCardHolder(value);
                    },
                  ),

                  const SizedBox(height: MBESpacing.lg),

                  Row(
                    children: [
                      Expanded(
                        child: _ExpiryDateField(
                          initialValue: paymentInfo.expiryDate ?? '',
                          onChanged: (value) {
                            orderNotifier.setExpiryDate(value);
                          },
                        ),
                      ),
                      const SizedBox(width: MBESpacing.md),
                      Expanded(
                        child: _CVVField(
                          initialValue: paymentInfo.cvv ?? '',
                          onChanged: (value) {
                            orderNotifier.setCVV(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          // Mensaje para otros métodos de pago
          FadeInUp(
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 100),
            child: Container(
              padding: const EdgeInsets.all(MBESpacing.xl),
              decoration: MBECardDecoration.card(),
              child: Column(
                children: [
                  Icon(
                    paymentInfo.method == PaymentMethod.cash
                        ? Iconsax.money
                        : Iconsax.bank,
                    size: 64,
                    color: MBETheme.brandBlack,
                  ),
                  const SizedBox(height: MBESpacing.lg),
                  Text(
                    _getPaymentMessage(context, paymentInfo.method),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: MBESpacing.sm),
                  Text(
                    _getPaymentDescription(context, paymentInfo.method),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],

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
                      'Monto a pagar',
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
                      Text(
                        _getPaymentMethodName(context, paymentInfo.method),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
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
                          'Error al procesar el pedido',
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

  String _getPaymentMessage(BuildContext context, PaymentMethod method) {
    final l10n = AppLocalizations.of(context)!;
    switch (method) {
      case PaymentMethod.cash:
        return l10n.printOrderCashPayment;
      case PaymentMethod.transfer:
        return l10n.printOrderTransferPayment;
      case PaymentMethod.card:
        return l10n.printOrderCardPayment;
    }
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

// 🎴 Vista previa simple de la tarjeta
class _CardPreview extends StatelessWidget {
  final PaymentInfo paymentInfo;

  const _CardPreview({required this.paymentInfo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(MBESpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MBETheme.brandBlack,
            MBETheme.brandBlack.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(MBERadius.large),
        boxShadow: MBETheme.shadowLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Iconsax.card,
                size: 40,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              Text(
                'VISA',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            paymentInfo.cardNumber?.isEmpty ?? true
                ? '•••• •••• •••• ••••'
                : _formatCardNumber(paymentInfo.cardNumber ?? ''),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TITULAR',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    paymentInfo.cardHolder?.isEmpty ?? true
                        ? 'NOMBRE APELLIDO'
                        : paymentInfo.cardHolder!.toUpperCase(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VÁLIDO HASTA',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    paymentInfo.expiryDate?.isEmpty ?? true
                        ? 'MM/AA'
                        : paymentInfo.expiryDate!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCardNumber(String number) {
    final cleaned = number.replaceAll(' ', '');
    if (cleaned.length <= 4) return cleaned;

    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(i < cleaned.length - 4 ? '•' : cleaned[i]);
    }
    return buffer.toString();
  }
}

// 📝 Campos personalizados simples
class _CardNumberField extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const _CardNumberField({required this.initialValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: 'Número de Tarjeta',
        hintText: '1234 5678 9012 3456',
        prefixIcon: const Icon(Iconsax.card),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MBERadius.large),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(16),
        _CardNumberFormatter(),
      ],
      onChanged: onChanged,
    );
  }
}

class _CardHolderField extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const _CardHolderField({required this.initialValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.printOrderCardHolder,
        hintText: AppLocalizations.of(context)!.printOrderCardHolderHint,
        prefixIcon: const Icon(Iconsax.user),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MBERadius.large),
        ),
      ),
      textCapitalization: TextCapitalization.words,
      onChanged: onChanged,
    );
  }
}

class _ExpiryDateField extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const _ExpiryDateField({required this.initialValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.printOrderExpiry,
        hintText: AppLocalizations.of(context)!.printOrderExpiryHint,
        prefixIcon: const Icon(Iconsax.calendar),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MBERadius.large),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
        _ExpiryDateFormatter(),
      ],
      onChanged: onChanged,
    );
  }
}

class _CVVField extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const _CVVField({required this.initialValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: 'CVV',
        hintText: '123',
        prefixIcon: const Icon(Iconsax.lock),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MBERadius.large),
        ),
      ),
      keyboardType: TextInputType.number,
      obscureText: true,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      onChanged: onChanged,
    );
  }
}

// 🔧 Formateadores
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1) buffer.write('/');
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
