import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mbe_orders_app/config/theme/mbe_theme.dart';
import 'package:mbe_orders_app/core/design_system/ds_badges.dart';
import 'package:mbe_orders_app/core/design_system/ds_inputs.dart';
import 'package:mbe_orders_app/core/design_system/ds_selection_cards.dart';
import '../../../providers/print_order_provider.dart';


// Enums para las opciones
enum PrintType { blackWhite, color }
enum PaperSize { letter, legal, a4, a3 }
enum PaperType { bond, glossy, cardstock }
enum Orientation { vertical, horizontal }

class Step2Configuration extends HookConsumerWidget {
  const Step2Configuration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // States locales
    final printType = useState(PrintType.blackWhite);
    final paperSize = useState(PaperSize.letter);
    final paperType = useState(PaperType.bond);
    final orientation = useState(Orientation.vertical);
    final copies = useState(1);
    final doubleSided = useState(false);
    final stapled = useState(false);

    // Cálculo de precio
    final pricePerPage = printType.value == PrintType.blackWhite ? 0.10 : 1.30;
    final totalPages = 116; // Temporal - obtener del provider
    final subtotal = (pricePerPage * totalPages * copies.value).toStringAsFixed(2);

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
                        'Personaliza tu pedido • 116 páginas',
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
            child: DSToggleButtons<PrintType>(
              value: printType.value,
              options: const [
                DSToggleOption(
                  value: PrintType.blackWhite,
                  label: 'Blanco y Negro',
                  icon: Iconsax.document_text,
                ),
                DSToggleOption(
                  value: PrintType.color,
                  label: 'Color',
                  icon: Iconsax.color_swatch,
                ),
              ],
              onChanged: (value) => printType.value = value,
            ),
          ),
        ),

        const SizedBox(height: MBESpacing.lg),

        // Tamaño y Tipo de Papel (en 2 columnas)
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
                DSDropdown<PaperSize>(
                  label: 'Tamaño',
                  value: paperSize.value,
                  items: const [
                    DSDropdownItem(
                      value: PaperSize.letter,
                      label: 'Carta (Letter) - Desde \$0.10',
                    ),
                    DSDropdownItem(
                      value: PaperSize.legal,
                      label: 'Legal - Desde \$0.15',
                    ),
                    DSDropdownItem(
                      value: PaperSize.a4,
                      label: 'A4 - Desde \$0.12',
                    ),
                    DSDropdownItem(
                      value: PaperSize.a3,
                      label: 'A3 - Desde \$0.50',
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) paperSize.value = value;
                  },
                ),

                const SizedBox(height: MBESpacing.lg),

                // Tipo de Papel
                DSDropdown<PaperType>(
                  label: 'Tipo de Papel',
                  value: paperType.value,
                  items: const [
                    DSDropdownItem(
                      value: PaperType.bond,
                      label: 'Papel Bond',
                    ),
                    DSDropdownItem(
                      value: PaperType.glossy,
                      label: 'Papel Brillante',
                    ),
                    DSDropdownItem(
                      value: PaperType.cardstock,
                      label: 'Cartulina',
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) paperType.value = value;
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
            child: DSToggleButtons<Orientation>(
              value: orientation.value,
              options: const [
                DSToggleOption(
                  value: Orientation.vertical,
                  label: 'Vertical',
                  icon: Iconsax.menu,
                ),
                DSToggleOption(
                  value: Orientation.horizontal,
                  label: 'Horizontal',
                  icon: Iconsax.row_horizontal,
                ),
              ],
              onChanged: (value) => orientation.value = value,
            ),
          ),
        ),

        const SizedBox(height: MBESpacing.lg),

        // Número de Copias
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 400),
          child: Container(
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
                    // Botón -
                    _CounterButton(
                      icon: Icons.remove,
                      onPressed: copies.value > 1
                          ? () => copies.value--
                          : null,
                    ),
                    
                    const SizedBox(width: MBESpacing.lg),
                    
                    // Número
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: MBESpacing.lg,
                        ),
                        decoration: BoxDecoration(
                          color: MBETheme.lightGray,
                          borderRadius: BorderRadius.circular(MBERadius.large),
                          border: Border.all(
                            color: MBETheme.neutralGray.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          '${copies.value}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: MBESpacing.lg),
                    
                    // Botón +
                    _CounterButton(
                      icon: Icons.add,
                      onPressed: copies.value < 100
                          ? () => copies.value++
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: MBESpacing.sm),
                Center(
                  child: Text(
                    'Máximo 100 copias',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
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
                  description: 'Ahorra papel (\$0.20 por página)',
                  value: doubleSided.value,
                  onChanged: (value) => doubleSided.value = value ?? false,
                  badge: DSBadge.success(label: 'Ahorra papel'),
                ),
                
                const SizedBox(height: MBESpacing.md),
                
                // Engargolado
                _OptionCheckbox(
                  icon: Iconsax.note_21,
                  title: 'Engargolado',
                  description: 'Presentación profesional y duradera',
                  value: stapled.value,
                  onChanged: (value) => stapled.value = value ?? false,
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
                  label: 'Impresión ($totalPages páginas totales)',
                  amount: '\$$subtotal',
                ),
                
                if (doubleSided.value) ...[
                  const SizedBox(height: MBESpacing.sm),
                  _CostRow(
                    label: 'Doble cara',
                    amount: '\$${(totalPages * 0.20 * copies.value).toStringAsFixed(2)}',
                  ),
                ],
                
                if (stapled.value) ...[
                  const SizedBox(height: MBESpacing.sm),
                  _CostRow(
                    label: 'Engargolado',
                    amount: '\$5.00',
                  ),
                ],
                
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
                      '\$$subtotal',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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

// Widget auxiliar: Card de sección
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
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

// Widget auxiliar: Botón de contador
class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CounterButton({
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isEnabled ? MBETheme.brandBlack : MBETheme.neutralGray.withValues(alpha: 0.2),
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

// Widget auxiliar: Checkbox de opción
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
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: MBEDuration.normal,
        padding: const EdgeInsets.all(MBESpacing.md),
        decoration: BoxDecoration(
          color: value ? MBETheme.brandBlack.withValues(alpha: 0.03) : MBETheme.lightGray,
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
            // Checkbox
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
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            
            const SizedBox(width: MBESpacing.md),
            
            // Icono
            Icon(
              icon,
              size: 20,
              color: colorScheme.onSurface,
            ),
            
            const SizedBox(width: MBESpacing.md),
            
            // Texto
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

// Widget auxiliar: Fila de costo
class _CostRow extends StatelessWidget {
  final String label;
  final String amount;

  const _CostRow({
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
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