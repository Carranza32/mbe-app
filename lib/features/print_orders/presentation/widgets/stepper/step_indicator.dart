import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mbe_orders_app/features/print_orders/data/models/step_model.dart';

class StepIndicator extends StatelessWidget {
  final StepModel step;
  final int currentStep;
  final bool isFirst;
  final bool isLast;

  const StepIndicator({
    Key? key,
    required this.step,
    required this.currentStep,
    this.isFirst = false,
    this.isLast = false,
  }) : super(key: key);

  bool get isActive => currentStep == step.id;
  bool get isCompleted => currentStep > step.id;
  bool get isPending => currentStep < step.id;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: 100, // Ancho fijo para consistencia
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador circular
          ZoomIn(
            duration: const Duration(milliseconds: 300),
            delay: Duration(milliseconds: step.id * 100),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? colorScheme.primary
                    : isCompleted
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                border: isActive
                    ? Border.all(
                        color: colorScheme.primary.withOpacity(0.3),
                        width: 4,
                      )
                    : null,
              ),
              child: Icon(
                isCompleted ? Iconsax.tick_circle5 : step.icon,
                size: 20,
                color: isActive
                    ? colorScheme.onPrimary
                    : isCompleted
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Label
          FadeIn(
            duration: const Duration(milliseconds: 300),
            delay: Duration(milliseconds: step.id * 100 + 100),
            child: Column(
              children: [
                Text(
                  step.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isActive
                        ? colorScheme.onSurface
                        : isCompleted
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Description (oculta en móvil pequeño)
                if (MediaQuery.of(context).size.width >= 600)
                  Text(
                    step.description,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}