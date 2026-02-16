// lib/features/print_orders/presentation/widgets/steps/step2_configuration.dart
import 'package:flutter/material.dart' hide Orientation;
import 'package:mbe_orders_app/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mbe_orders_app/config/theme/mbe_theme.dart';
import 'package:mbe_orders_app/core/design_system/ds_badges.dart';

// ✅ CAMBIO: Importa el provider centralizado y los helpers
import '../../../providers/create_order_provider.dart';
import '../../../providers/print_configuration_state_provider.dart';
import '../../../providers/print_config_provider.dart';
import '../../../data/helpers/config_converters.dart';

class Step2Configuration extends HookConsumerWidget {
  const Step2Configuration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Depender de la config de precios para que al cargar no se pierdan los precios
    ref.watch(printConfigProvider);
    // ✅ CAMBIO: Lee desde el provider centralizado
    final orderState = ref.watch(createOrderProvider);
    final orderNotifier = ref.read(createOrderProvider.notifier);
    final pricing = orderNotifier.calculatePricing();

    // ✅ CAMBIO: Obtener la config del request (puede ser null)
    final printConfig = orderState.request?.printConfig;
    
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
              AppLocalizations.of(context)!.printOrderNoPagesDetected,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: MBESpacing.sm),
            Text(
              AppLocalizations.of(context)!.printOrderGoBackAndUpload,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // ✅ Convertir strings a enums para el UI (valores por defecto si es null)
    final printType = printConfig != null 
        ? ConfigConverters.printTypeFromString(printConfig.printType)
        : PrintType.blackWhite;
    
    final paperSize = printConfig != null
        ? ConfigConverters.paperSizeFromString(printConfig.paperSize)
        : PaperSize.letter;
    
    final paperType = printConfig != null
        ? ConfigConverters.paperTypeFromString(printConfig.paperType)
        : PaperType.bond;
    
    final orientation = printConfig != null
        ? ConfigConverters.orientationFromString(printConfig.orientation)
        : Orientation.vertical;
    
    final copies = printConfig?.copies ?? 1;
    final doubleSided = printConfig?.doubleSided ?? false;
    final binding = printConfig?.binding ?? false;

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
                        AppLocalizations.of(context)!.printOrderCustomizeOrder(totalPages),
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
                    isSelected: printType == PrintType.blackWhite,
                    onTap: () {
                      // ✅ CAMBIO: Actualiza en el provider centralizado
                      ref.read(createOrderProvider.notifier).setPrintType(
                        ConfigConverters.printTypeToString(PrintType.blackWhite),
                      );
                    },
                  ),
                ),
                const SizedBox(width: MBESpacing.md),
                Expanded(
                  child: _ToggleButton(
                    label: AppLocalizations.of(context)!.printOrderColorLabel,
                    icon: Iconsax.color_swatch,
                    isSelected: printType == PrintType.color,
                    onTap: () {
                      ref.read(createOrderProvider.notifier).setPrintType(
                        ConfigConverters.printTypeToString(PrintType.color),
                      );
                    },
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
                  AppLocalizations.of(context)!.printOrderPaper,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: MBESpacing.lg),
                
                // Tamaño de Papel
                _PaperSizeSelector(
                  value: paperSize,
                  printType: printConfig?.printType ?? 'bw',
                  onChanged: (size) {
                    ref.read(createOrderProvider.notifier).setPaperSize(
                      ConfigConverters.paperSizeToString(size),
                    );
                  },
                ),

                const SizedBox(height: MBESpacing.lg),

                // Tipo de Papel (precios desde config)
                _PaperTypeSelector(
                  value: paperType,
                  onChanged: (type) {
                    ref.read(createOrderProvider.notifier).setPaperType(
                      ConfigConverters.paperTypeToString(type),
                    );
                  },
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
                    isSelected: orientation == Orientation.vertical,
                    onTap: () {
                      ref.read(createOrderProvider.notifier).setOrientation(
                        ConfigConverters.orientationToString(Orientation.vertical),
                      );
                    },
                  ),
                ),
                const SizedBox(width: MBESpacing.md),
                Expanded(
                  child: _ToggleButton(
                    label: AppLocalizations.of(context)!.printOrderOrientationLandscape,
                    icon: Iconsax.row_horizontal,
                    isSelected: orientation == Orientation.horizontal,
                    onTap: () {
                      ref.read(createOrderProvider.notifier).setOrientation(
                        ConfigConverters.orientationToString(Orientation.horizontal),
                      );
                    },
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
            copies: copies,
            onChanged: (value) {
              ref.read(createOrderProvider.notifier).setCopies(value);
            },
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
                  title: AppLocalizations.of(context)!.printOrderDoubleSidedPrint,
                  description: pricing.doubleSidedCost > 0 
                      ? '+\$${pricing.doubleSidedCost.toStringAsFixed(2)}'
                      : AppLocalizations.of(context)!.printOrderSavePaper,
                  value: doubleSided,
                  onChanged: (value) {
                    ref.read(createOrderProvider.notifier).setDoubleSided(value ?? false);
                  },
                  badge: doubleSided ? DSBadge.success(label: AppLocalizations.of(context)!.printOrderEco) : null,
                ),
                
                const SizedBox(height: MBESpacing.md),
                
                // Engargolado
                _OptionCheckbox(
                  icon: Iconsax.note_21,
                  title: AppLocalizations.of(context)!.printOrderBinding,
                  description: pricing.bindingCost > 0
                      ? '+\$${pricing.bindingCost.toStringAsFixed(2)}'
                      : AppLocalizations.of(context)!.printOrderProfessionalPresentation,
                  value: binding,
                  onChanged: (value) {
                    ref.read(createOrderProvider.notifier).setBinding(value ?? false);
                  },
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

// ====== WIDGETS AUXILIARES (sin cambios) ======

class _PricingSummary extends StatelessWidget {
  final PriceBreakdown pricing;

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
                AppLocalizations.of(context)!.printOrderCostSummary,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: MBESpacing.lg),
          
          _CostRow(
            label: '${AppLocalizations.of(context)!.printOrderPrintingLabel} (${pricing.totalPages} ${AppLocalizations.of(context)!.printOrderPages} × ${pricing.copies} ${pricing.copies == 1 ? AppLocalizations.of(context)!.printOrderCopy : AppLocalizations.of(context)!.printOrderCopies})',
            amount: '\$${pricing.printingCost.toStringAsFixed(2)}',
            detail: '\$${pricing.pricePerPage.toStringAsFixed(2)} ${AppLocalizations.of(context)!.printOrderPerPage}',
          ),

          if (pricing.paperTypeCost > 0) ...[
            const SizedBox(height: MBESpacing.sm),
            _CostRow(
              label: AppLocalizations.of(context)!.printOrderPaperType,
              amount: '+\$${pricing.paperTypeCost.toStringAsFixed(2)}',
            ),
          ],
          
          if (pricing.doubleSidedCost > 0) ...[
            const SizedBox(height: MBESpacing.sm),
            _CostRow(
              label: AppLocalizations.of(context)!.printOrderDoubleSided,
              amount: '+\$${pricing.doubleSidedCost.toStringAsFixed(2)}',
            ),
          ],
          
          if (pricing.bindingCost > 0) ...[
            const SizedBox(height: MBESpacing.sm),
            _CostRow(
              label: AppLocalizations.of(context)!.printOrderBinding,
              amount: '+\$${pricing.bindingCost.toStringAsFixed(2)}',
            ),
          ],
          
          const SizedBox(height: MBESpacing.md),
          const Divider(),
          const SizedBox(height: MBESpacing.md),
          
          _CostRow(
            label: AppLocalizations.of(context)!.printOrderSubtotal,
            amount: '\$${pricing.printSubtotal.toStringAsFixed(2)}',
          ),
          
          // const SizedBox(height: MBESpacing.sm),
          // _CostRow(
          //   label: 'IVA (13%)',
          //   amount: '\$${pricing.tax.toStringAsFixed(2)}',
          // ),
          
          const SizedBox(height: MBESpacing.md),
          const Divider(),
          const SizedBox(height: MBESpacing.md),
          
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
                '\$${pricing.printTotal.toStringAsFixed(2)}',
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
  final String printType;
  final Function(PaperSize) onChanged;

  const _PaperSizeSelector({
    required this.value,
    required this.printType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderNotifier = ref.read(createOrderProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.printOrderSizeLabel,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: MBESpacing.sm),
        ...PaperSize.values.map((size) {
          final priceRange = orderNotifier.getPriceRange(size, printType: printType);
          return _RadioOption<PaperSize>(
            value: size,
            groupValue: value,
            onChanged: onChanged,
            label: _getPaperSizeLabel(context, size),
            description: priceRange,
          );
        }),
      ],
    );
  }

  String _getPaperSizeLabel(BuildContext context, PaperSize size) {
    final l10n = AppLocalizations.of(context)!;
    switch (size) {
      case PaperSize.letter:
        return '${l10n.printOrderLetter} (Letter)';
      case PaperSize.legal:
        return l10n.printOrderLegal;
      case PaperSize.doubleLetter:
        return l10n.printOrderDoubleLetter;
    }
  }
}

class _PaperTypeSelector extends ConsumerWidget {
  final PaperType value;
  final Function(PaperType) onChanged;

  const _PaperTypeSelector({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderNotifier = ref.read(createOrderProvider.notifier);
    final bondLabel = orderNotifier.getPaperTypePriceLabel('bond');
    final glossyLabel = orderNotifier.getPaperTypePriceLabel('photo_glossy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.printOrderPaperType,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: MBESpacing.sm),
        _RadioOption<PaperType>(
          value: PaperType.bond,
          groupValue: value,
          onChanged: onChanged,
          label: 'Papel Bond',
          description: bondLabel.isNotEmpty ? bondLabel : 'Estándar',
        ),
        _RadioOption<PaperType>(
          value: PaperType.glossy,
          groupValue: value,
          onChanged: onChanged,
          label: 'Papel Brillante',
          description: glossyLabel.isNotEmpty ? glossyLabel : 'Para imágenes',
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
            AppLocalizations.of(context)!.printOrderNumberOfCopies,
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
              AppLocalizations.of(context)!.printOrderMaxCopies,
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