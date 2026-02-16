import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mbe_orders_app/l10n/app_localizations.dart';

import '../../../data/constants/print_order_steps.dart';
import '../../../data/models/step_model.dart';

class MbeStepper extends StatelessWidget {
  final int currentStep;

  const MbeStepper({
    Key? key,
    required this.currentStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final steps = PrintOrderSteps.getSteps(AppLocalizations.of(context)!);

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
  final List<StepModel> steps;
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentStep();
    });
  }

  @override
  void didUpdateWidget(_ScrollableStepperContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      _scrollToCurrentStep();
    }
  }

  void _scrollToCurrentStep() {
    if (!_scrollController.hasClients) return;
    final stepWidth = 70.0; // MÁS COMPACTO: era 120
    final targetOffset = (widget.currentStep - 1) * stepWidth - 30;

    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12), // MENOS PADDING
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (int i = 0; i < widget.steps.length; i++) ...[
              _StepIndicator(
                step: widget.steps[i],
                currentStep: widget.currentStep,
                index: i,
              ),
              if (i < widget.steps.length - 1)
                _ProgressLine(
                  isCompleted: widget.currentStep > widget.steps[i].id,
                  width: 24, // LÍNEA MÁS CORTA: era 60
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final StepModel step;
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

    return SizedBox(
      width: 56, // MÁS COMPACTO: era 100
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Círculo
          ZoomIn(
            duration: const Duration(milliseconds: 250),
            delay: Duration(milliseconds: index * 50),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 36, // MÁS PEQUEÑO: era 40
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? colorScheme.primary
                    : isCompleted
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                isCompleted ? Iconsax.tick_circle5 : step.icon,
                size: 18, // ICONO MÁS PEQUEÑO: era 20
                color: isActive || isCompleted
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(height: 6), // MENOS ESPACIO: era 8

          // Label
          FadeIn(
            duration: const Duration(milliseconds: 250),
            delay: Duration(milliseconds: index * 50 + 50),
            child: Text(
              step.label,
              style: theme.textTheme.labelSmall?.copyWith( // labelSmall en vez de labelMedium
                color: isActive
                    ? colorScheme.onSurface
                    : isCompleted
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Línea de progreso - MÁS DELGADA
class _ProgressLine extends StatelessWidget {
  final bool isCompleted;
  final double width;

  const _ProgressLine({
    required this.isCompleted,
    this.width = 24,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: 2, // MÁS DELGADA: era 4
      margin: const EdgeInsets.only(bottom: 30), // AJUSTADO
      decoration: BoxDecoration(
        color: isCompleted
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}