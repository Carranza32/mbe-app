import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mbe_orders_app/config/theme/mbe_theme.dart';
import 'package:mbe_orders_app/features/print_orders/providers/stepper_provider.dart';

import '../../providers/print_order_provider.dart';
import '../widgets/stepper/mbe_stepper.dart';
import '../widgets/steps/step1_upload_files.dart';
import '../widgets/steps/step2_configuration.dart';
import '../widgets/steps/step3_delivery_method.dart';
import '../widgets/steps/step4_confirmation.dart';
import '../widgets/steps/step5_payment.dart';

class PrintOrderScreen extends HookConsumerWidget {
  const PrintOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(currentStepProvider);
    final totalSteps = 5;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = (currentStep - 1) / (totalSteps - 1);

    return Scaffold(
      // Background gris claro estilo Grab
      backgroundColor: MBETheme.lightGray,
      
      // App Bar blanco estilo Grab
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
              'Crear pedido',
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
            icon: const Icon(Iconsax.more),
            onPressed: () => _showOptionsMenu(context),
          ),
          const SizedBox(width: MBESpacing.sm),
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
            child: MbeStepper(
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
                ? () => ref.read(currentStepProvider.notifier).previous()
                : null,
            onContinue: currentStep < totalSteps
              ? () async {
                  if (currentStep == 1) {
                    // Analizar archivos antes de continuar
                    final success = await ref.read(printOrderProvider.notifier).analyzeFiles();
                    if (success) {
                      ref.read(currentStepProvider.notifier).next();
                    }
                  } else {
                    ref.read(currentStepProvider.notifier).next();
                  }
                }
              : () => _finishOrder(context),
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
        return const Step1UploadFiles();
      case 2:
        return const Step2Configuration();
      case 3:
        return const Step3DeliveryMethod();
      case 4:
        return const Step4Confirmation();
      case 5:
        return const Step5Payment();
      default:
        return const SizedBox.shrink();
    }
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MBERadius.xl),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: MBESpacing.md),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: MBETheme.neutralGray.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(MBERadius.small),
              ),
            ),
            const SizedBox(height: MBESpacing.sm),
            ListTile(
              leading: const Icon(Iconsax.save_2),
              title: const Text('Guardar borrador'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Iconsax.refresh),
              title: const Text('Reiniciar pedido'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Iconsax.info_circle),
              title: const Text('Ayuda'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: MBESpacing.md),
          ],
        ),
      ),
    );
  }

  void _finishOrder(BuildContext context) {
    // Lógica para finalizar pedido
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pedido finalizado')),
    );
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