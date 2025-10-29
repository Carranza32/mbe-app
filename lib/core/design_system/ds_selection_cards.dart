import 'package:flutter/material.dart';
import '../../config/theme/mbe_theme.dart';

/// Cards seleccionables reutilizables (radio buttons mejorados)
/// Uso: DSSelectionCard(isSelected: true, onTap: () {}, child: ...)

class DSSelectionCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;
  final bool showCheckmark;
  final EdgeInsets? padding;

  const DSSelectionCard({
    Key? key,
    required this.isSelected,
    required this.onTap,
    required this.child,
    this.showCheckmark = true,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: MBEDuration.normal,
        curve: MBECurve.standard,
        padding: padding ?? const EdgeInsets.all(MBESpacing.lg),
        decoration: BoxDecoration(
          color: isSelected 
              ? MBETheme.brandBlack.withValues(alpha: 0.03)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(MBERadius.large),
          border: Border.all(
            color: isSelected
                ? MBETheme.brandBlack
                : MBETheme.neutralGray.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected ? MBETheme.shadowMd : MBETheme.shadowSm,
        ),
        child: Stack(
          children: [
            child,
            if (showCheckmark && isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: MBETheme.brandBlack,
                          shape: BoxShape.circle,
                          boxShadow: MBETheme.shadowMd,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Card con icono, título y descripción (para método de entrega)
class DSOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? badge;
  final Color? iconColor;

  const DSOptionCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.badge,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DSSelectionCard(
      isSelected: isSelected,
      onTap: onTap,
      child: Row(
        children: [
          // Icono - Estilo Grab con fondo suave
          AnimatedContainer(
            duration: MBEDuration.normal,
            curve: MBECurve.standard,
            padding: const EdgeInsets.all(MBESpacing.md),
            decoration: BoxDecoration(
              color: isSelected 
                  ? MBETheme.brandBlack
                  : MBETheme.lightGray,
              borderRadius: BorderRadius.circular(MBERadius.medium),
              boxShadow: isSelected ? MBETheme.shadowSm : [],
            ),
            child: Icon(
              icon,
              size: 28,
              color: isSelected 
                  ? Colors.white 
                  : (iconColor ?? colorScheme.onSurfaceVariant),
            ),
          ),

          const SizedBox(width: MBESpacing.lg),

          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: MBESpacing.xs),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(height: MBESpacing.sm),
                  badge!,
                ],
              ],
            ),
          ),

          const SizedBox(width: MBESpacing.xxxl), // Space for checkmark
        ],
      ),
    );
  }
}

/// Toggle buttons horizontales (para orientación, tipo de impresión, etc)
class DSToggleButtons<T> extends StatelessWidget {
  final T value;
  final List<DSToggleOption<T>> options;
  final Function(T) onChanged;

  const DSToggleButtons({
    Key? key,
    required this.value,
    required this.options,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.asMap().entries.map((entry) {
        final option = entry.value;
        final isSelected = value == option.value;
        final isLast = entry.key == options.length - 1;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: isLast ? 0 : MBESpacing.sm,
            ),
            child: _ToggleButton<T>(
              option: option,
              isSelected: isSelected,
              onTap: () => onChanged(option.value),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class DSToggleOption<T> {
  final T value;
  final String label;
  final IconData icon;

  const DSToggleOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}

class _ToggleButton<T> extends StatelessWidget {
  final DSToggleOption<T> option;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: MBEDuration.normal,
        curve: MBECurve.standard,
        padding: const EdgeInsets.symmetric(
          vertical: MBESpacing.lg,
          horizontal: MBESpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? MBETheme.brandBlack
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(MBERadius.large),
          border: Border.all(
            color: isSelected
                ? MBETheme.brandBlack
                : MBETheme.neutralGray.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected ? MBETheme.shadowMd : MBETheme.shadowSm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              option.icon,
              size: 32,
              color: isSelected ? Colors.white : colorScheme.onSurface,
            ),
            const SizedBox(height: MBESpacing.sm),
            Text(
              option.label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? Colors.white : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Radio buttons compactos (sin card) - Estilo Grab
class DSRadioButtons<T> extends StatelessWidget {
  final T value;
  final List<DSRadioOption<T>> options;
  final Function(T) onChanged;

  const DSRadioButtons({
    Key? key,
    required this.value,
    required this.options,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((option) {
        final isSelected = value == option.value;

        return _RadioButton<T>(
          option: option,
          isSelected: isSelected,
          onTap: () => onChanged(option.value),
        );
      }).toList(),
    );
  }
}

class DSRadioOption<T> {
  final T value;
  final String label;
  final String? description;

  const DSRadioOption({
    required this.value,
    required this.label,
    this.description,
  });
}

class _RadioButton<T> extends StatelessWidget {
  final DSRadioOption<T> option;
  final bool isSelected;
  final VoidCallback onTap;

  const _RadioButton({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: MBESpacing.sm),
        child: Row(
          children: [
            // Radio circle - Estilo Grab
            AnimatedContainer(
              duration: MBEDuration.normal,
              curve: MBECurve.standard,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? MBETheme.brandBlack
                      : MBETheme.neutralGray.withValues(alpha: 0.3),
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

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (option.description != null) ...[
                    const SizedBox(height: MBESpacing.xs),
                    Text(
                      option.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
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