import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mbe_orders_app/config/theme/mbe_theme.dart';
import 'package:mbe_orders_app/core/design_system/ds_inputs.dart';
import 'package:mbe_orders_app/core/design_system/ds_selection_cards.dart';
import '../../../data/models/pre_alert_model.dart';

class Step3Payment extends HookConsumerWidget {
  final PreAlert preAlert;

  const Step3Payment({
    Key? key,
    required this.preAlert,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // TODO: Usar un provider para manejar el estado del pago
    final paymentMethod = useState<String>('card');
    final cardNumberController = useTextEditingController();
    final cardHolderController = useTextEditingController();
    final expiryDateController = useTextEditingController();
    final cvvController = useTextEditingController();

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
                        'Completa los datos de pago',
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
                'Método de pago',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: MBESpacing.md),
              DSOptionCard(
                title: 'Tarjeta de crédito/débito',
                description: 'Paga con tu tarjeta Visa, Mastercard o American Express',
                icon: Iconsax.card,
                isSelected: paymentMethod.value == 'card',
                onTap: () {
                  paymentMethod.value = 'card';
                },
              ),
              const SizedBox(height: MBESpacing.md),
              DSOptionCard(
                title: 'Efectivo',
                description: 'Paga en efectivo al momento de la entrega',
                icon: Iconsax.money_recive,
                isSelected: paymentMethod.value == 'cash',
                onTap: () {
                  paymentMethod.value = 'cash';
                },
              ),
            ],
          ),
        ),

        // Formulario de tarjeta (solo si se selecciona tarjeta)
        if (paymentMethod.value == 'card') ...[
          const SizedBox(height: MBESpacing.lg),
          FadeInUp(
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 300),
            child: Column(
              children: [
                DSInput.text(
                  label: 'Número de tarjeta',
                  hint: '0000 0000 0000 0000',
                  controller: cardNumberController,
                  prefixIcon: Iconsax.card,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    // TODO: Agregar formateo de tarjeta
                  ],
                  onChanged: (value) {
                    // TODO: Guardar en provider
                  },
                  required: true,
                ),

                const SizedBox(height: MBESpacing.md),

                DSInput.text(
                  label: 'Titular de la tarjeta',
                  hint: 'Nombre como aparece en la tarjeta',
                  controller: cardHolderController,
                  prefixIcon: Iconsax.user,
                  onChanged: (value) {
                    // TODO: Guardar en provider
                  },
                  required: true,
                ),

                const SizedBox(height: MBESpacing.md),

                Row(
                  children: [
                    Expanded(
                      child: DSInput.text(
                        label: 'Fecha de vencimiento',
                        hint: 'MM/AA',
                        controller: expiryDateController,
                        prefixIcon: Iconsax.calendar,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          // TODO: Guardar en provider
                        },
                        required: true,
                      ),
                    ),
                    const SizedBox(width: MBESpacing.md),
                    Expanded(
                      child: DSInput.text(
                        label: 'CVV',
                        hint: '000',
                        controller: cvvController,
                        prefixIcon: Iconsax.lock,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          // TODO: Limitar a 3-4 dígitos
                        ],
                        onChanged: (value) {
                          // TODO: Guardar en provider
                        },
                        required: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
