// lib/features/print_orders/presentation/widgets/steps/step5_payment.dart
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

import 'package:mbe_orders_app/config/theme/mbe_theme.dart';

class Step5Payment extends HookConsumerWidget {
  const Step5Payment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final cardNumber = useState('');
    final cardHolder = useState('');
    final expiryDate = useState('');
    final cvv = useState('');
    final saveCard = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    
    final orderTotal = 10.44;

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
                  child: const Icon(Iconsax.card, size: 28, color: Colors.white),
                ),
                const SizedBox(width: MBESpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Realizar Pago',
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
                            '\$$orderTotal',
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

        // Security Badge
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

        // Card Preview - Visual de la tarjeta
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
            customCardTypeIcons: <CustomCardTypeIcon>[
              CustomCardTypeIcon(
                cardType: CardType.mastercard,
                cardImage: Image.asset(
                  'assets/mastercard.png',
                  height: 48,
                  width: 48,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: MBESpacing.xl),

        // Card Form usando el paquete
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

                // Form con el paquete (personalizado con el tema MBE)
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
                  // Personalización de textos
                  cardNumberDecoration: InputDecoration(
                    labelText: 'Número de Tarjeta',
                    hintText: 'XXXX XXXX XXXX XXXX',
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
                  ),
                  expiryDateDecoration: InputDecoration(
                    labelText: 'Fecha de Vencimiento',
                    hintText: 'MM/AA',
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
                  ),
                  cvvCodeDecoration: InputDecoration(
                    labelText: 'CVV',
                    hintText: 'XXX',
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
                  ),
                  cardHolderDecoration: InputDecoration(
                    labelText: 'Nombre del Titular',
                    hintText: 'Como aparece en la tarjeta',
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
                  ),
                ),

                const SizedBox(height: MBESpacing.lg),

                // Checkbox
                // DSCheckbox(
                //   value: saveCard.value,
                //   onChanged: (value) => saveCard.value = value ?? false,
                //   label: 'Guardar tarjeta para futuros pagos',
                // ),
              ],
            ),
          ),
        ),

        const SizedBox(height: MBESpacing.lg),

        // Payment Summary (igual que antes)
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
                      '\$$orderTotal',
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
                      const Icon(Iconsax.card, size: 18, color: Colors.white),
                      const SizedBox(width: MBESpacing.sm),
                      Text(
                        'Tarjeta de crédito/débito',
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
}