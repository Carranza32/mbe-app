import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mbe_orders_app/config/theme/mbe_theme.dart';
import 'package:mbe_orders_app/core/design_system/ds_stepper.dart';
import '../../data/models/pre_alert_model.dart';
import '../../data/repositories/pre_alerts_repository.dart';
import '../../providers/pre_alerts_provider.dart';
import '../../providers/pre_alert_stepper_provider.dart';
import '../../providers/pre_alert_complete_provider.dart';
import '../widgets/steps/step1_delivery.dart';
import '../widgets/steps/step2_contact.dart';
import '../widgets/steps/step3_payment.dart';
import '../widgets/promotion_modal.dart';

class PreAlertCompleteInformationScreen extends HookConsumerWidget {
  final PreAlert preAlert;

  const PreAlertCompleteInformationScreen({
    Key? key,
    required this.preAlert,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(preAlertCurrentStepProvider);
    final totalSteps = 3;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = (currentStep - 1) / (totalSteps - 1);

    // Definir los pasos del stepper
    const steps = [
      StepperStep(
        id: 1,
        label: 'Entrega',
        icon: Iconsax.truck,
        description: 'Método de entrega',
      ),
      StepperStep(
        id: 2,
        label: 'Contacto',
        icon: Iconsax.profile_circle,
        description: 'Información de contacto',
      ),
      StepperStep(
        id: 3,
        label: 'Pago',
        icon: Iconsax.dollar_circle,
        description: 'Completa tu pago',
      ),
    ];

    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completar Pre-alerta',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Paso $currentStep de $totalSteps',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.discount_shape),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => PromotionModal(preAlert: preAlert),
              );
            },
            tooltip: 'Ver promociones',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: MBETheme.lightGray,
            valueColor: const AlwaysStoppedAnimation<Color>(MBETheme.brandBlack),
          ),
        ),
      ),
      body: Column(
        children: [
          // Stepper compacto
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(
              MBESpacing.lg,
              MBESpacing.lg,
              MBESpacing.lg,
              MBESpacing.xl,
            ),
            child: DsStepper(
              steps: steps,
              currentStep: currentStep,
            ),
          ),

          // Contenido del paso
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(MBESpacing.lg),
              child: AnimatedSwitcher(
                duration: MBEDuration.normal,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: MBECurve.emphasized,
                      )),
                      child: child,
                    ),
                  );
                },
                child: _buildStepContent(currentStep, ref),
              ),
            ),
          ),

          // Botones de navegación
          _NavigationButtons(
            currentStep: currentStep,
            totalSteps: totalSteps,
            onBack: currentStep > 1
                ? () => ref.read(preAlertCurrentStepProvider.notifier).previous()
                : null,
            onContinue: () {
              final completeState = ref.read(preAlertCompleteProvider(preAlert));
              
              // Validar paso actual antes de continuar
              bool canContinue = false;
              switch (currentStep) {
                case 1:
                  canContinue = completeState.isStep1Valid;
                  break;
                case 2:
                  canContinue = completeState.isStep2Valid;
                  break;
                case 3:
                  canContinue = completeState.isStep3Valid;
                  break;
              }
              
              if (!canContinue) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      currentStep == 1
                          ? 'Por favor selecciona un método de entrega'
                          : currentStep == 2
                              ? 'Por favor completa todos los campos requeridos'
                              : 'Por favor completa la información de pago',
                    ),
                    backgroundColor: MBETheme.brandRed,
                  ),
                );
                return;
              }
              
              if (currentStep < totalSteps) {
                ref.read(preAlertCurrentStepProvider.notifier).next();
              } else {
                _finishPreAlert(context, ref);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(int step, WidgetRef ref) {
    return KeyedSubtree(
      key: ValueKey(step),
      child: _getStepWidget(step),
    );
  }

  Widget _getStepWidget(int step) {
    switch (step) {
      case 1:
        return Step1Delivery(preAlert: preAlert);
      case 2:
        return Step2Contact(preAlert: preAlert);
      case 3:
        return Step3Payment(preAlert: preAlert);
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _finishPreAlert(BuildContext context, WidgetRef ref) async {
    final completeState = ref.read(preAlertCompleteProvider(preAlert));
    
    // Validar que todos los pasos estén completos
    if (!completeState.isStep1Valid || !completeState.isStep2Valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor completa todos los pasos antes de finalizar'),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final repository = ref.read(preAlertsRepositoryProvider);
      final completeNotifier = ref.read(preAlertCompleteProvider(preAlert).notifier);
      final payload = completeNotifier.toJson();
      
      await repository.completePreAlertInfo(
        preAlertId: preAlert.id,
        data: payload,
      );

      if (!context.mounted) return;

      // Cerrar loading
      Navigator.pop(context);

      // Invalidar el provider de pre-alertas para refrescar la lista
      ref.invalidate(preAlertsProvider);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(
            Iconsax.tick_circle,
            size: 64,
            color: Color(0xFF10B981),
          ),
          title: const Text('¡Pre-alerta completada!'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tu pre-alerta ha sido completada exitosamente',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                ref.read(preAlertCurrentStepProvider.notifier).reset();
                ref.read(preAlertCompleteProvider(preAlert).notifier).reset();
                Navigator.pop(context); // Cerrar dialog
                Navigator.pop(context); // Volver a lista
              },
              style: FilledButton.styleFrom(
                backgroundColor: MBETheme.brandBlack,
              ),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al completar la pre-alerta: $e'),
          backgroundColor: MBETheme.brandRed,
        ),
      );
    }
  }
}

/// Botones de navegación estilo Grab
class _NavigationButtons extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  const _NavigationButtons({
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MBESpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: MBETheme.shadowTop,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Botón Atrás
            if (onBack != null) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: MBESpacing.lg,
                    ),
                    side: BorderSide(
                      color: MBETheme.neutralGray.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(MBERadius.large),
                    ),
                  ),
                  icon: const Icon(Iconsax.arrow_left_2, size: 20),
                  label: const Text('Atrás'),
                ),
              ),
              const SizedBox(width: MBESpacing.lg),
            ],

            // Botón Continuar/Finalizar
            Expanded(
              flex: onBack != null ? 1 : 2,
              child: FilledButton.icon(
                onPressed: onContinue,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: MBESpacing.lg,
                  ),
                  backgroundColor: MBETheme.brandBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MBERadius.large),
                  ),
                ),
                icon: Icon(
                  currentStep < totalSteps
                      ? Iconsax.arrow_right_3
                      : Iconsax.tick_circle,
                  size: 20,
                ),
                label: Text(
                  currentStep < totalSteps ? 'Continuar' : 'Finalizar',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
