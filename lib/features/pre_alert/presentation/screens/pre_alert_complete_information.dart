import 'package:flutter/material.dart';
import 'package:mbe_orders_app/l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mbe_orders_app/config/theme/mbe_theme.dart';
import 'package:mbe_orders_app/core/design_system/ds_stepper.dart';
import '../../data/models/pre_alert_model.dart';
import '../../data/models/promotion_model.dart';
import '../../data/repositories/pre_alerts_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/models/payment_models.dart';
import '../../providers/pre_alerts_provider.dart';
import '../../providers/pre_alert_stepper_provider.dart';
import '../../providers/pre_alert_complete_provider.dart';
import '../widgets/steps/step1_delivery.dart';
import '../widgets/steps/step2_contact.dart';
import '../widgets/steps/step3_payment.dart';
import '../widgets/promotion_modal.dart';
import '../widgets/payment_webview.dart';

class PreAlertCompleteInformationScreen extends HookConsumerWidget {
  final PreAlert preAlert;

  const PreAlertCompleteInformationScreen({Key? key, required this.preAlert})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cargar mejor promoción para delivery al abrir la pantalla (para mostrar en la tarjeta antes de elegir método)
    useEffect(() {
      Future<void> loadBestPromotion() async {
        try {
          final repository = ref.read(preAlertsRepositoryProvider);
          final request = BestPromotionRequest(
            storeId: 1,
            serviceType: 'pre_alert',
            subtotal: preAlert.totalValue,
            deliveryCost: 2.0,
            appliesTo: 'delivery',
          );
          final response = await repository.getBestPromotion(request: request);
          if (response?.data != null) {
            ref
                .read(preAlertCompleteProvider(preAlert).notifier)
                .setBestPromotionForDelivery(response!.data);
          }
        } catch (_) {}
      }
      loadBestPromotion();
      return null;
    }, const []);

    final currentStep = ref.watch(preAlertCurrentStepProvider);
    final totalSteps = 3;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = theme.colorScheme;
    final progress = (currentStep - 1) / (totalSteps - 1);

    // Definir los pasos del stepper
    final steps = [
      StepperStep(
        id: 1,
        label: l10n.preAlertDelivery,
        icon: Iconsax.truck,
        description: l10n.preAlertDeliveryMethod,
      ),
      StepperStep(
        id: 2,
        label: l10n.preAlertContact,
        icon: Iconsax.profile_circle,
        description: l10n.preAlertContactInfo,
      ),
      StepperStep(
        id: 3,
        label: l10n.preAlertPayment,
        icon: Iconsax.dollar_circle,
        description: l10n.preAlertCompletePayment,
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
              l10n.preAlertCompleteTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              l10n.preAlertStepOf(currentStep, totalSteps),
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
            tooltip: l10n.preAlertViewPromotions,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: MBETheme.lightGray,
            valueColor: const AlwaysStoppedAnimation<Color>(
              MBETheme.brandBlack,
            ),
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
            child: DsStepper(steps: steps, currentStep: currentStep),
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
                      position:
                          Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: MBECurve.emphasized,
                            ),
                          ),
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
                ? () =>
                      ref.read(preAlertCurrentStepProvider.notifier).previous()
                : null,
            onContinue: () {
              final completeState = ref.read(
                preAlertCompleteProvider(preAlert),
              );

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
                final msgL10n = AppLocalizations.of(context)!;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      currentStep == 1
                          ? msgL10n.preAlertSelectDeliveryMethod
                          : currentStep == 2
                          ? msgL10n.preAlertCompleteRequiredFields
                          : msgL10n.preAlertCompletePaymentInfo,
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
    return KeyedSubtree(key: ValueKey(step), child: _getStepWidget(step));
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
          content: Text(
            AppLocalizations.of(context)!.preAlertCompleteAllSteps,
          ),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }

    // Validar método de pago
    if (completeState.paymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.preAlertSelectPaymentMethod),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repository = ref.read(preAlertsRepositoryProvider);
      final completeNotifier = ref.read(
        preAlertCompleteProvider(preAlert).notifier,
      );
      final payload = completeNotifier.toJson();

      // 1. Completar información de entrega y contacto
      await repository.completePreAlertInfo(
        preAlertId: preAlert.id,
        data: payload,
      );

      if (!context.mounted) return;

      // Cerrar loading
      Navigator.pop(context);

      // 2. Efectivo: registrar pago con gateway "cash" en el backend
      if (completeState.paymentMethod == 'cash') {
        await _processCashPayment(context, ref);
        return;
      }

      // 3. Transferencia: subir comprobante y registrar pago
      if (completeState.paymentMethod == 'transfer') {
        await _processTransferPayment(context, ref);
        return;
      }

      // 4. Tarjeta (Cybersource) - reservado para uso futuro
      if (completeState.paymentMethod == 'card') {
        await _processCardPayment(context, ref);
      }
    } catch (e) {
      if (!context.mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.preAlertCompleteError(e.toString())),
          backgroundColor: MBETheme.brandRed,
        ),
      );
    }
  }

  Future<void> _processCashPayment(
      BuildContext context, WidgetRef ref) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final paymentRepository = ref.read(paymentRepositoryProvider);
      await paymentRepository.initiatePaymentCash(
        preAlert.id,
        total: preAlert.totalValue,
      );

      if (!context.mounted) return;
      Navigator.pop(context);
      _showSuccessDialog(
        context,
        ref,
        AppLocalizations.of(context)!.preAlertCashSuccessMessage,
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.preAlertPaymentRegisterError(e.toString())),
          backgroundColor: MBETheme.brandRed,
        ),
      );
    }
  }

  Future<void> _processTransferPayment(
      BuildContext context, WidgetRef ref) async {
    final paymentData = ref.read(preAlertCompleteProvider(preAlert)).paymentData;
    final filePath = paymentData?['filePath'] as String?;
    if (filePath == null || filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.preAlertUploadTransferProof),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final paymentRepository = ref.read(paymentRepositoryProvider);
      final init = await paymentRepository.initiatePaymentTransfer(
        preAlert.id,
        transferProofFilePath: filePath,
        total: preAlert.totalValue,
        transferReference:
            paymentData?['transferReference'] as String?,
        transferNotes: paymentData?['transferNotes'] as String?,
      );

      if (!context.mounted) return;
      Navigator.pop(context);

      _showSuccessDialog(
        context,
        ref,
        AppLocalizations.of(context)!.preAlertTransferReceivedMessage(init.referenceNumber),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.preAlertTransferSendError(e.toString())),
          backgroundColor: MBETheme.brandRed,
        ),
      );
    }
  }

  Future<void> _processCardPayment(BuildContext context, WidgetRef ref) async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final paymentRepository = ref.read(paymentRepositoryProvider);

      // Iniciar el pago
      final paymentInit = await paymentRepository.initiatePayment(preAlert.id);

      if (!context.mounted) return;

      // Cerrar loading
      Navigator.pop(context);

      // Abrir WebView con el formulario de pago
      final result = await Navigator.of(context).push<PaymentResult>(
        MaterialPageRoute(
          builder: (context) => PaymentWebView(
            redirectUrl: paymentInit.redirectUrl,
            paymentId: paymentInit.paymentId,
            onPaymentComplete: (result) {
              Navigator.of(context).pop(result);
            },
          ),
        ),
      );

      // Cuando se cierra el WebView, usar el resultado que devuelve el WebView
      if (result != null && !result.cancelled) {
        _handlePaymentResultFromWebView(context, ref, result);
      } else if (result != null && result.cancelled) {
        _showCancelDialog(context);
      }
    } catch (e) {
      if (!context.mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.preAlertPaymentInitError(e.toString())),
          backgroundColor: MBETheme.brandRed,
        ),
      );
    }
  }

  /// Usado cuando el WebView se cierra con un resultado (sin polling al backend).
  void _handlePaymentResultFromWebView(
    BuildContext context,
    WidgetRef ref,
    PaymentResult result,
  ) {
    if (result.success) {
      _showSuccessDialog(
        context,
        ref,
        AppLocalizations.of(context)!.preAlertPaymentSuccessMessage,
      );
    } else {
      _showErrorDialog(
        context,
        AppLocalizations.of(context)!.preAlertPaymentFailedMessage,
      );
    }
  }

  void _showSuccessDialog(BuildContext context, WidgetRef ref, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          icon: const Icon(
            Iconsax.tick_circle,
            size: 64,
            color: Color(0xFF10B981),
          ),
          title: Text(l10n.preAlertPaymentSuccessTitle),
          content: Text(message),
          actions: [
            FilledButton(
            onPressed: () {
              ref.read(preAlertCurrentStepProvider.notifier).reset();
              ref.read(preAlertCompleteProvider(preAlert).notifier).reset();
              ref.invalidate(preAlertsProvider);
              Navigator.pop(ctx); // Cerrar dialog
              Navigator.pop(ctx); // Volver a lista
            },
            style: FilledButton.styleFrom(backgroundColor: MBETheme.brandBlack),
            child: Text(l10n.preAlertAccept),
          ),
        ],
      );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          icon: const Icon(
            Iconsax.close_circle,
            size: 64,
            color: MBETheme.brandRed,
          ),
          title: Text(l10n.preAlertPaymentErrorTitle),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.preAlertAccept),
            ),
          ],
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          icon: const Icon(
            Iconsax.info_circle,
            size: 64,
            color: MBETheme.brandBlack,
          ),
          title: Text(l10n.preAlertPaymentCancelled),
          content: Text(l10n.preAlertPaymentCancelledMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.preAlertAccept),
            ),
          ],
        );
      },
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
    final l10n = AppLocalizations.of(context)!;
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
                  label: Text(l10n.preAlertBack),
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
                  padding: const EdgeInsets.symmetric(vertical: MBESpacing.lg),
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
                  currentStep < totalSteps ? l10n.preAlertContinue : l10n.preAlertFinish,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
