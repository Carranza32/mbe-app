// lib/features/print_orders/presentation/widgets/steps/step2_configuration.dart
import 'package:flutter/material.dart' hide Orientation;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mbe_orders_app/config/theme/mbe_theme.dart';
import 'package:mbe_orders_app/core/design_system/ds_badges.dart';
import 'package:mbe_orders_app/core/design_system/ds_inputs.dart';

import '../../../providers/print_order_provider.dart';
import '../../../providers/print_configuration_state_provider.dart';
import '../../../providers/print_pricing_provider.dart';

class Step2Configuration extends HookConsumerWidget {
  const Step2Configuration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Estados desde providers
    final userConfig = ref.watch(printConfigurationStateProvider);
    final configNotifier = ref.read(printConfigurationStateProvider.notifier);
    final orderState = ref.watch(printOrderProvider);
    final pricing = ref.watch(printPricingProvider);

    // Total de páginas
    final totalPages = orderState.totalPages ?? 0;

    if (totalPages == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Iconsax.warning_2,
              size: 48,
              color: MBETheme.brandRed,
            ),
            const SizedBox(height: MBESpacing.lg),
            Text(
              'No se detectaron páginas',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: MBESpacing.sm),
            Text(
              'Regresa al paso anterior y sube tus archivos',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
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
                    Iconsax.setting_2,
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
                        'Configurar Impresión',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: MBESpacing.xs),
                      Text(
                        'Personaliza tu pedido • $totalPages páginas',
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

        // Tipo de Impresión
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 100),
          child: _SectionCard(
            title: 'Tipo de Impresión',
            child: Row(
              children: [
                Expanded(
                  child: _ToggleButton(
                    label: 'Blanco y Negro',
                    icon: Iconsax.document_text,
                    isSelected: userConfig.printType == PrintType.blackWhite,
                    onTap: () => configNotifier.setPrintType(PrintType.blackWhite),
                  ),
                ),
                const SizedBox(width: MBESpacing.md),
                Expanded(
                  child: _ToggleButton(
                    label: 'Color',
                    icon: Iconsax.color_swatch,
                    isSelected: userConfig.printType == PrintType.color,
                    onTap: () => configNotifier.setPrintType(PrintType.color),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: MBESpacing.lg),

        // Papel
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.all(MBESpacing.lg),
            decoration: MBECardDecoration.card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Papel',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: MBESpacing.lg),
                
                // Tamaño de Papel
                _PaperSizeSelector(
                  value: userConfig.paperSize,
                  onChanged: (size) => configNotifier.setPaperSize(size),
                ),

                const SizedBox(height: MBESpacing.lg),

                // Tipo de Papel
                _PaperTypeSelector(
                  value: userConfig.paperType,
                  onChanged: (type) => configNotifier.setPaperType(type),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: MBESpacing.lg),

        // Orientación
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 300),
          child: _SectionCard(
            title: 'Orientación',
            child: Row(
              children: [
                Expanded(
                  child: _ToggleButton(
                    label: 'Vertical',
                    icon: Iconsax.menu,
                    isSelected: userConfig.orientation == Orientation.vertical,
                    onTap: () => configNotifier.setOrientation(Orientation.vertical),
                  ),
                ),
                const SizedBox(width: MBESpacing.md),
                Expanded(
                  child: _ToggleButton(
                    label: 'Horizontal',
                    icon: Iconsax.row_horizontal,
                    isSelected: userConfig.orientation == Orientation.horizontal,
                    onTap: () => configNotifier.setOrientation(Orientation.horizontal),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: MBESpacing.lg),

        // Número de Copias
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 400),
          child: _CopiesSelector(
            copies: userConfig.copies,
            onChanged: (value) => configNotifier.setCopies(value),
          ),
        ),

        const SizedBox(height: MBESpacing.lg),

        // Opciones Adicionales
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 500),
          child: Container(
            padding: const EdgeInsets.all(MBESpacing.lg),
            decoration: MBECardDecoration.card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Opciones Adicionales',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: MBESpacing.lg),
                
                // Impresión a Doble Cara
                _OptionCheckbox(
                  icon: Iconsax.copy,
                  title: 'Impresión a Doble Cara',
                  description: pricing.doubleSidedCost > 0 
                      ? '+\$${pricing.doubleSidedCost.toStringAsFixed(2)}'
                      : 'Ahorra papel',
                  value: userConfig.doubleSided,
                  onChanged: (value) => configNotifier.setDoubleSided(value ?? false),
                  badge: userConfig.doubleSided ? DSBadge.success(label: 'Eco') : null,
                ),
                
                const SizedBox(height: MBESpacing.md),
                
                // Engargolado
                _OptionCheckbox(
                  icon: Iconsax.note_21,
                  title: 'Engargolado',
                  description: pricing.bindingCost > 0
                      ? '+\$${pricing.bindingCost.toStringAsFixed(2)}'
                      : 'Presentación profesional',
                  value: userConfig.binding,
                  onChanged: (value) => configNotifier.setBinding(value ?? false),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: MBESpacing.lg),

        // Resumen de Costos
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 600),
          child: _PricingSummary(pricing: pricing),
        ),

        const SizedBox(height: MBESpacing.xxxl),
      ],
    );
  }
}

// Widget: Resumen de precios
class _PricingSummary extends StatelessWidget {
  final PriceCalculation pricing;

  const _PricingSummary({required this.pricing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
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
        children: [
          Row(
            children: [
              Icon(
                Iconsax.money_recive,
                size: 24,
                color: colorScheme.onSurface,
              ),
              const SizedBox(width: MBESpacing.md),
              Text(
                'Resumen de Costos',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: MBESpacing.lg),
          
          _CostRow(
            label: 'Impresión (${pricing.totalPages} páginas × ${pricing.copies} ${pricing.copies == 1 ? 'copia' : 'copias'})',
            amount: '\$${pricing.printingCost.toStringAsFixed(2)}',
            detail: '\$${pricing.pricePerPage.toStringAsFixed(2)} por página',
          ),
          
          if (pricing.doubleSidedCost > 0) ...[
            const SizedBox(height: MBESpacing.sm),
            _CostRow(
              label: 'Doble cara',
              amount: '+\$${pricing.doubleSidedCost.toStringAsFixed(2)}',
            ),
          ],
          
          if (pricing.bindingCost > 0) ...[
            const SizedBox(height: MBESpacing.sm),
            _CostRow(
              label: 'Engargolado',
              amount: '+\$${pricing.bindingCost.toStringAsFixed(2)}',
            ),
          ],
          
          const SizedBox(height: MBESpacing.md),
          const Divider(),
          const SizedBox(height: MBESpacing.md),
          
          _CostRow(
            label: 'Subtotal',
            amount: '\$${pricing.subtotal.toStringAsFixed(2)}',
          ),
          
          const SizedBox(height: MBESpacing.sm),
          _CostRow(
            label: 'IVA (13%)',
            amount: '\$${pricing.tax.toStringAsFixed(2)}',
          ),
          
          const SizedBox(height: MBESpacing.md),
          const Divider(),
          const SizedBox(height: MBESpacing.md),
          
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
                '\$${pricing.total.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: MBETheme.brandBlack,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widgets auxiliares existentes...
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(MBESpacing.lg),
      decoration: MBECardDecoration.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: MBESpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: MBEDuration.normal,
        padding: const EdgeInsets.all(MBESpacing.lg),
        decoration: BoxDecoration(
          color: isSelected 
              ? MBETheme.brandBlack 
              : MBETheme.lightGray,
          borderRadius: BorderRadius.circular(MBERadius.large),
          border: Border.all(
            color: isSelected 
                ? MBETheme.brandBlack 
                : MBETheme.neutralGray.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : MBETheme.neutralGray,
            ),
            const SizedBox(height: MBESpacing.sm),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaperSizeSelector extends ConsumerWidget {
  final PaperSize value;
  final Function(PaperSize) onChanged;

  const _PaperSizeSelector({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pricingNotifier = ref.read(printPricingProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tamaño',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: MBESpacing.sm),
        ...PaperSize.values.map((size) {
          final priceRange = pricingNotifier.getPriceRange(size);
          return _RadioOption<PaperSize>(
            value: size,
            groupValue: value,
            onChanged: onChanged,
            label: _getPaperSizeLabel(size),
            description: priceRange,
          );
        }),
      ],
    );
  }

  String _getPaperSizeLabel(PaperSize size) {
    switch (size) {
      case PaperSize.letter:
        return 'Carta (Letter)';
      case PaperSize.legal:
        return 'Legal';
      case PaperSize.doubleLetter:
        return 'Doble Carta';
    }
  }
}

class _PaperTypeSelector extends StatelessWidget {
  final PaperType value;
  final Function(PaperType) onChanged;

  const _PaperTypeSelector({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Papel',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: MBESpacing.sm),
        _RadioOption<PaperType>(
          value: PaperType.bond,
          groupValue: value,
          onChanged: onChanged,
          label: 'Papel Bond',
          description: 'Estándar',
        ),
        _RadioOption<PaperType>(
          value: PaperType.glossy,
          groupValue: value,
          onChanged: onChanged,
          label: 'Papel Brillante',
          description: 'Para imágenes',
        ),
      ],
    );
  }
}

class _RadioOption<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final Function(T) onChanged;
  final String label;
  final String? description;

  const _RadioOption({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.label,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: MBESpacing.sm),
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
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? MBETheme.brandBlack : Colors.transparent,
                border: Border.all(
                  color: isSelected ? MBETheme.brandBlack : MBETheme.neutralGray,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.circle,
                        size: 10,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: MBESpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CopiesSelector extends StatelessWidget {
  final int copies;
  final Function(int) onChanged;

  const _CopiesSelector({
    required this.copies,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(MBESpacing.lg),
      decoration: MBECardDecoration.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Número de Copias',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: MBESpacing.lg),
          Row(
            children: [
              _CounterButton(
                icon: Icons.remove,
                onPressed: copies > 1 ? () => onChanged(copies - 1) : null,
              ),
              const SizedBox(width: MBESpacing.lg),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: MBESpacing.lg),
                  decoration: BoxDecoration(
                    color: MBETheme.lightGray,
                    borderRadius: BorderRadius.circular(MBERadius.large),
                    border: Border.all(
                      color: MBETheme.neutralGray.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '$copies',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: MBESpacing.lg),
              _CounterButton(
                icon: Icons.add,
                onPressed: copies < 100 ? () => onChanged(copies + 1) : null,
              ),
            ],
          ),
          const SizedBox(height: MBESpacing.sm),
          Center(
            child: Text(
              'Máximo 100 copias',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CounterButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isEnabled 
            ? MBETheme.brandBlack 
            : MBETheme.neutralGray.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(MBERadius.large),
        boxShadow: isEnabled ? MBETheme.shadowMd : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(MBERadius.large),
          child: Icon(
            icon,
            color: isEnabled ? Colors.white : MBETheme.neutralGray,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _OptionCheckbox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool value;
  final Function(bool?) onChanged;
  final Widget? badge;

  const _OptionCheckbox({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: MBEDuration.normal,
        padding: const EdgeInsets.all(MBESpacing.md),
        decoration: BoxDecoration(
          color: value 
              ? MBETheme.brandBlack.withValues(alpha: 0.03) 
              : MBETheme.lightGray,
          borderRadius: BorderRadius.circular(MBERadius.medium),
          border: Border.all(
            color: value 
                ? MBETheme.brandBlack 
                : MBETheme.neutralGray.withValues(alpha: 0.2),
            width: value ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: MBEDuration.normal,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? MBETheme.brandBlack : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? MBETheme.brandBlack : MBETheme.neutralGray,
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: MBESpacing.md),
            Icon(icon, size: 20),
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
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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

class _CostRow extends StatelessWidget {
  final String label;
  final String amount;
  final String? detail;

  const _CostRow({
    required this.label,
    required this.amount,
    this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
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
        ),
        if (detail != null) ...[
          const SizedBox(height: 2),
          Text(
            detail!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}