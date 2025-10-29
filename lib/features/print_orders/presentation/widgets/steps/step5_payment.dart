// lib/features/print_orders/presentation/widgets/steps/step5_payment.dart
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

import 'package:mbe_orders_app/config/theme/mbe_theme.dart';
import '../../../providers/order_total_provider.dart';
import '../../../providers/confirmation_state_provider.dart';

class Step5Payment extends HookConsumerWidget {
  const Step5Payment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final cardNumber = useState('5100010000000015');
    final cardHolder = useState('Mario Carranza');
    final expiryDate = useState('12/28');
    final cvv = useState('123');
    final saveCard = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    
    // Obtener total real
    final orderTotal = ref.watch(orderTotalCalculatorProvider);
    final confirmationState = ref.watch(confirmationStateProvider);
    
    // Solo mostrar si el método de pago es tarjeta
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
          // Card Preview
          FadeInUp(
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 100),
            child: CreditCardWidget(
              onCreditCardWidgetChange: (CreditCardBrand brand) {},
              cardNumber: cardNumber.value,
              expiryDate: expiryDate.value,
              cardHolderName: cardHolder.value,
              cvvCode: cvv.value,
              showBackView: false,
              obscureCardNumber: true,
              obscureCardCvv: true,
              isHolderNameVisible: true,
              cardBgColor: MBETheme.brandBlack,
              glassmorphismConfig: Glassmorphism.defaultConfig(),
              backgroundImage: null,
              isSwipeGestureEnabled: true,
            ),
          ),

          const SizedBox(height: MBESpacing.xl),

          // Card Form
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

                  CreditCardForm(
                    formKey: formKey,
                    cardNumber: cardNumber.value,
                    expiryDate: expiryDate.value,
                    cardHolderName: cardHolder.value,
                    cvvCode: cvv.value,
                    onCreditCardModelChange: (CreditCardModel data) {
                      cardNumber.value = data.cardNumber;
                      expiryDate.value = data.expiryDate;
                      cardHolder.value = data.cardHolderName;
                      cvv.value = data.cvvCode;
                    },
                    themeColor: MBETheme.brandBlack,
                    obscureCvv: true,
                    obscureNumber: false,
                    isHolderNameVisible: true,
                    isCardNumberVisible: true,
                    isExpiryDateVisible: true,
                    enableCvv: true,
                    cvvValidationMessage: 'Ingresa un CVV válido',
                    dateValidationMessage: 'Ingresa una fecha válida',
                    numberValidationMessage: 'Ingresa un número válido',
                    cardNumberValidator: (String? cardNumber) {
                      if (cardNumber == null || cardNumber.isEmpty) {
                        return 'El número de tarjeta es requerido';
                      }
                      if (cardNumber.replaceAll(' ', '').length < 13) {
                        return 'Número de tarjeta inválido';
                      }
                      return null;
                    },
                    expiryDateValidator: (String? expiryDate) {
                      if (expiryDate == null || expiryDate.isEmpty) {
                        return 'La fecha de vencimiento es requerida';
                      }
                      return null;
                    },
                    cvvValidator: (String? cvv) {
                      if (cvv == null || cvv.isEmpty) {
                        return 'El CVV es requerido';
                      }
                      if (cvv.length < 3) {
                        return 'CVV inválido';
                      }
                      return null;
                    },
                    cardHolderValidator: (String? cardHolderName) {
                      if (cardHolderName == null || cardHolderName.isEmpty) {
                        return 'El nombre del titular es requerido';
                      }
                      return null;
                    },
                    cardNumberDecoration: _buildInputDecoration(
                      'Número de Tarjeta',
                      'XXXX XXXX XXXX XXXX',
                      colorScheme,
                    ),
                    expiryDateDecoration: _buildInputDecoration(
                      'Fecha de Vencimiento',
                      'MM/AA',
                      colorScheme,
                    ),
                    cvvCodeDecoration: _buildInputDecoration(
                      'CVV',
                      'XXX',
                      colorScheme,
                    ),
                    cardHolderDecoration: _buildInputDecoration(
                      'Nombre del Titular',
                      'Como aparece en la tarjeta',
                      colorScheme,
                    ),
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

  InputDecoration _buildInputDecoration(
    String label,
    String hint,
    ColorScheme colorScheme,
  ) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MBERadius.large),
        borderSide: BorderSide(
          color: MBETheme.neutralGray.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MBERadius.large),
        borderSide: BorderSide(
          color: MBETheme.neutralGray.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MBERadius.large),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 2,
        ),
      ),
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