import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';

import 'package:mbe_orders_app/config/theme/mbe_theme.dart';
import '../../../providers/order_total_provider.dart';
import '../../../providers/confirmation_state_provider.dart';
import '../../../providers/order_processor_provider.dart';
import '../../../providers/card_data_provider.dart';

class Step5Payment extends ConsumerWidget {
  const Step5Payment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // 🎯 LEER del provider (como en tus otros pasos)
    final cardData = ref.watch(cardDataProvider);
    final orderTotal = ref.watch(orderTotalCalculatorProvider);
    final confirmationState = ref.watch(confirmationStateProvider);
    final processorState = ref.watch(orderProcessorProvider);
    
    final showCardForm = confirmationState.paymentMethod == PaymentMethod.card;

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
                        showCardForm ? 'Realizar Pago' : 'Confirmar Pedido',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: MBESpacing.xs),
                      Row(
                        children: [
                          Text(
                            'Total: ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '\$${orderTotal.grandTotal.toStringAsFixed(2)}',
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
            child: _CardPreview(cardData: cardData),
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
                      Icon(Iconsax.card_pos, size: 24, color: colorScheme.onSurface),
                      const SizedBox(width: MBESpacing.md),
                      Text(
                        'Información de Tarjeta',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: MBESpacing.xl),

                  // 🎯 Campos individuales simples
                  _CardNumberField(
                    initialValue: cardData.cardNumber,
                    onChanged: (value) {
                      ref.read(cardDataProvider.notifier).updateCardNumber(value);
                    },
                  ),

                  const SizedBox(height: MBESpacing.lg),

                  _CardHolderField(
                    initialValue: cardData.cardHolder,
                    onChanged: (value) {
                      ref.read(cardDataProvider.notifier).updateCardHolder(value);
                    },
                  ),

                  const SizedBox(height: MBESpacing.lg),

                  Row(
                    children: [
                      Expanded(
                        child: _ExpiryDateField(
                          initialValue: cardData.expiryDate,
                          onChanged: (value) {
                            ref.read(cardDataProvider.notifier).updateExpiryDate(value);
                          },
                        ),
                      ),
                      const SizedBox(width: MBESpacing.md),
                      Expanded(
                        child: _CVVField(
                          initialValue: cardData.cvv,
                          onChanged: (value) {
                            ref.read(cardDataProvider.notifier).updateCVV(value);
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
                    confirmationState.paymentMethod == PaymentMethod.cash
                        ? Iconsax.money
                        : Iconsax.bank,
                    size: 64,
                    color: MBETheme.brandBlack,
                  ),
                  const SizedBox(height: MBESpacing.lg),
                  Text(
                    _getPaymentMessage(confirmationState.paymentMethod),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: MBESpacing.sm),
                  Text(
                    _getPaymentDescription(confirmationState.paymentMethod),
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
                      '\$${orderTotal.grandTotal.toStringAsFixed(2)}',
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
                        _getPaymentIcon(confirmationState.paymentMethod),
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: MBESpacing.sm),
                      Text(
                        confirmationState.getPaymentMethodName(),
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
                  Icon(
                    Iconsax.warning_2,
                    size: 18,
                    color: MBETheme.brandRed,
                  ),
                  const SizedBox(width: MBESpacing.sm),
                  Expanded(
                    child: Text(
                      processorState.errorMessage ?? 'Error al procesar el pedido',
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
                    'Al continuar, aceptas nuestros términos y condiciones de servicio',
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

  String _getPaymentMessage(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Pago en efectivo';
      case PaymentMethod.transfer:
        return 'Pago por transferencia';
      case PaymentMethod.card:
        return 'Pago con tarjeta';
    }
  }

  String _getPaymentDescription(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Pagarás al momento de recibir tu pedido';
      case PaymentMethod.transfer:
        return 'Recibirás las instrucciones por correo electrónico';
      case PaymentMethod.card:
        return 'Paga de forma segura con tu tarjeta';
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
  final CardData cardData;

  const _CardPreview({required this.cardData});

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
              Icon(Iconsax.card, size: 40, color: Colors.white.withValues(alpha: 0.8)),
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
            cardData.cardNumber.isEmpty
                ? '•••• •••• •••• ••••'
                : _formatCardNumber(cardData.cardNumber),
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
                    cardData.cardHolder.isEmpty
                        ? 'NOMBRE APELLIDO'
                        : cardData.cardHolder.toUpperCase(),
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
                    cardData.expiryDate.isEmpty ? 'MM/AA' : cardData.expiryDate,
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

  const _CardNumberField({
    required this.initialValue,
    required this.onChanged,
  });

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

  const _CardHolderField({
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: 'Nombre del Titular',
        hintText: 'Como aparece en la tarjeta',
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

  const _ExpiryDateField({
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: 'Vencimiento',
        hintText: 'MM/AA',
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

  const _CVVField({
    required this.initialValue,
    required this.onChanged,
  });

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