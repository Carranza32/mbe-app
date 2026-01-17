import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mbe_orders_app/config/theme/mbe_theme.dart';

/// Modelo para cada paso del stepper
class StepperStep {
  final int id;
  final String label;
  final IconData icon;
  final String description;

  const StepperStep({
    required this.id,
    required this.label,
    required this.icon,
    required this.description,
  });
}

/// Stepper reutilizable del design system
class DsStepper extends StatelessWidget {
  final List<StepperStep> steps;
  final int currentStep;

  const DsStepper({
    Key? key,
    required this.steps,
    required this.currentStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeInDown(
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _ScrollableStepperContent(
          steps: steps,
          currentStep: currentStep,
        ),
      ),
    );
  }
}

class _ScrollableStepperContent extends StatefulWidget {
  final List<StepperStep> steps;
  final int currentStep;

  const _ScrollableStepperContent({
    required this.steps,
    required this.currentStep,
  });

  @override
  State<_ScrollableStepperContent> createState() =>
      _ScrollableStepperContentState();
}

class _ScrollableStepperContentState extends State<_ScrollableStepperContent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < widget.steps.length; i++) ...[
            Expanded(
              child: _StepIndicator(
                step: widget.steps[i],
                currentStep: widget.currentStep,
                index: i,
              ),
            ),
            if (i < widget.steps.length - 1)
              Expanded(
                child: _ProgressLine(
                  isCompleted: widget.currentStep > widget.steps[i].id,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final StepperStep step;
  final int currentStep;
  final int index;

  const _StepIndicator({
    required this.step,
    required this.currentStep,
    required this.index,
  });

  bool get isActive => currentStep == step.id;
  bool get isCompleted => currentStep > step.id;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Círculo
        ZoomIn(
          duration: const Duration(milliseconds: 250),
          delay: Duration(milliseconds: index * 50),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? MBETheme.brandBlack
                  : isCompleted
                      ? MBETheme.brandBlack
                      : colorScheme.surfaceContainerHighest,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: MBETheme.brandBlack.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              isCompleted ? Iconsax.tick_circle5 : step.icon,
              size: 18,
              color: isActive || isCompleted
                  ? Colors.white
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Label
        FadeIn(
          duration: const Duration(milliseconds: 250),
          delay: Duration(milliseconds: index * 50 + 50),
          child: Text(
            step.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isActive
                  ? colorScheme.onSurface
                  : isCompleted
                      ? MBETheme.brandBlack
                      : colorScheme.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Línea de progreso
class _ProgressLine extends StatelessWidget {
  final bool isCompleted;

  const _ProgressLine({
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: isCompleted
            ? MBETheme.brandBlack
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
