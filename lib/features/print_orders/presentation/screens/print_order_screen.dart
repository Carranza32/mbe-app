import 'package:flutter/material.dart';
import 'package:mbe_orders_app/l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mbe_orders_app/config/theme/mbe_theme.dart';
import 'package:mbe_orders_app/core/network/api_endpoints.dart';
import 'package:mbe_orders_app/core/payment/hosted_checkout.dart';
import 'package:mbe_orders_app/features/pre_alert/data/repositories/payment_repository.dart';
import 'package:mbe_orders_app/features/print_orders/providers/stepper_provider.dart';

import '../../../auth/presentation/widgets/verification_pending_modal.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/repositories/print_order_repository.dart';
import '../../providers/create_order_provider.dart';
import '../../providers/order_processor_provider.dart';
import '../../providers/print_config_provider.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = theme.colorScheme;
    final progress = (currentStep - 1) / (totalSteps - 1);
    final authState = ref.watch(authProvider);
    final user = authState.value;
    final hasShownModal = useState(false);

    // Verificar si el customer está verificado después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Evitar mostrar el modal múltiples veces
      if (hasShownModal.value) return;

      if (user != null &&
          !user.isAdmin &&
          user.customer != null &&
          user.customer!.verifiedAt == null) {
        hasShownModal.value = true;
        // Mostrar modal de verificación pendiente y volver atrás
        Future.microtask(() {
          if (context.mounted) {
            context.pop();
            showDialog(
              context: context,
              builder: (context) => const VerificationPendingModal(),
            );
          }
        });
      }
    });

    // Datos del usuario logueado (auth) para prellenar información de contacto en paso 4
    final name = user?.name ?? user?.customer?.name ?? '';
    final email = user?.email ?? user?.customer?.email ?? '';
    final phone =
        user?.customer?.phone ??
        user?.customer?.homePhone ??
        user?.customer?.officePhone ??
        '';

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
              l10n.printOrderCreateTitle,
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
        // actions: [
        //   IconButton(
        //     icon: const Icon(Iconsax.more),
        //     onPressed: () => _showOptionsMenu(context),
        //   ),
        //   const SizedBox(width: MBESpacing.sm),
        // ],
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
            child: MbeStepper(currentStep: currentStep),
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
                child: _buildStepContent(
                  currentStep,
                  ref,
                  name: name,
                  email: email,
                  phone: phone,
                ),
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
                      // ✅ CAMBIO: Analizar archivos con el nuevo provider
                      final success = await ref
                          .read(createOrderProvider.notifier)
                          .analyzeFiles(l10n: AppLocalizations.of(context)!);
                      if (success) {
                        ref.read(currentStepProvider.notifier).next();
                      }
                    } else {
                      ref.read(currentStepProvider.notifier).next();
                    }
                  }
                : () => _finishOrder(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(
    int step,
    WidgetRef ref, {
    String name = '',
    String email = '',
    String phone = '',
  }) {
    return KeyedSubtree(
      key: ValueKey(step),
      child: _getStepWidget(step, name, email, phone),
    );
  }

  Widget _getStepWidget(int step, String name, String email, String phone) {
    switch (step) {
      case 1:
        return const Step1UploadFiles();
      case 2:
        return const Step2Configuration();
      case 3:
        return const Step3DeliveryMethod();
      case 4:
        return Step4Confirmation(
          userName: name,
          userEmail: email,
          userPhone: phone,
        );
      case 5:
        return const Step5Payment();
      default:
        return const SizedBox.shrink();
    }
  }

  void _showOptionsMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(MBERadius.xl)),
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
              title: Text(l10n.printOrderSaveDraft),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Iconsax.refresh),
              title: Text(l10n.printOrderResetOrder),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Iconsax.info_circle),
              title: Text(l10n.printOrderHelp),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: MBESpacing.md),
          ],
        ),
      ),
    );
  }

  Future<void> _finishOrder(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // ✅ CAMBIO: Obtener datos del provider centralizado
      final orderState = ref.read(createOrderProvider);
      final paymentInfo = orderState.paymentInfo;

      // Procesar la orden con el processor
      final success = await ref
          .read(orderProcessorProvider.notifier)
          .processOrder(
            cardNumber: paymentInfo.method == PaymentMethod.card
                ? paymentInfo.cardNumber
                : null,
            cardHolder: paymentInfo.method == PaymentMethod.card
                ? paymentInfo.cardHolder
                : null,
            expiryDate: paymentInfo.method == PaymentMethod.card
                ? paymentInfo.expiryDate
                : null,
            cvv: paymentInfo.method == PaymentMethod.card
                ? paymentInfo.cvv
                : null,
            l10n: AppLocalizations.of(context)!,
          );

      if (!context.mounted) return;

      // Cerrar loading
      Navigator.pop(context);

      if (success) {
        final processorState = ref.read(orderProcessorProvider);
        final orderId = processorState.orderId ?? '';

        if (paymentInfo.method == PaymentMethod.card) {
          try {
            ref.read(printConfigProvider);
            final orderNotifier = ref.read(createOrderProvider.notifier);
            final pricing = orderNotifier.calculatePricing();
            final paymentInit = await ref
                .read(printOrderRepositoryProvider)
                .initiatePaymentCard(orderId, total: pricing.grandTotal);
            if (!context.mounted) return;
            if (!paymentInit.hasRedirectUrl) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.preAlertPaymentInitError(
                      'No se recibió URL de pago. Intenta de nuevo.',
                    ),
                  ),
                  backgroundColor: MBETheme.brandRed,
                ),
              );
              return;
            }
            final result = await Navigator.of(context).push<HostedCheckoutResult>(
              MaterialPageRoute(
                builder: (ctx) => HostedCheckoutWebView(
                  redirectUrl: paymentInit.redirectUrl!,
                  paymentId: paymentInit.paymentId.toString(),
                  appBaseUrl: ApiEndpoints.baseUrl,
                  title: l10n.preAlertProcessingPayment,
                  onComplete: (r) => Navigator.of(ctx).pop(r),
                ),
              ),
            );
            if (result == null || result.cancelled) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.preAlertPaymentCancelledMessage),
                  backgroundColor: MBETheme.brandRed,
                ),
              );
              return;
            }
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(l10n.preAlertProcessingPayment),
                      ],
                    ),
                  ),
                ),
              ),
            );
            final statusResponse = await ref
                .read(paymentRepositoryProvider)
                .getPaymentStatus(result.paymentId);
            if (!context.mounted) return;
            Navigator.of(context).pop();
            if (statusResponse.isCompleted ||
                (!statusResponse.isFailed && result.success)) {
              _showPrintOrderSuccessDialog(context, ref);
            } else if (statusResponse.isFailed) {
              _showPrintOrderErrorDialog(
                context,
                statusResponse.payment.reasonMessage?.isNotEmpty == true
                    ? statusResponse.payment.reasonMessage!
                    : l10n.preAlertPaymentFailedMessage,
              );
            } else {
              _showPrintOrderSuccessDialog(context, ref);
            }
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.preAlertPaymentInitError(e.toString())),
                backgroundColor: MBETheme.brandRed,
              ),
            );
          }
          return;
        }

        _showPrintOrderSuccessDialog(context, ref);
      } else {
        final processorState = ref.read(orderProcessorProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              processorState.errorMessage ?? l10n.printOrderCreateError,
            ),
            backgroundColor: MBETheme.brandRed,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.printOrderUnexpectedError(e.toString())),
          backgroundColor: MBETheme.brandRed,
        ),
      );
    }
  }

  void _showPrintOrderSuccessDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final l10nDialog = AppLocalizations.of(ctx)!;
        return AlertDialog(
          icon: const Icon(
            Iconsax.tick_circle,
            size: 64,
            color: Color(0xFF10B981),
          ),
          title: Text(l10nDialog.printOrderCreatedSuccess),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10nDialog.printOrderCreatedMessage,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                ref.read(createOrderProvider.notifier).reset();
                ref.read(orderProcessorProvider.notifier).reset();
                Navigator.pop(ctx);
                context.pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: MBETheme.brandBlack,
              ),
              child: Text(l10nDialog.preAlertAccept),
            ),
          ],
        );
      },
    );
  }

  void _showPrintOrderErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        final l10nDialog = AppLocalizations.of(ctx)!;
        return AlertDialog(
          icon: const Icon(
            Iconsax.close_circle,
            size: 64,
            color: MBETheme.brandRed,
          ),
          title: Text(l10nDialog.preAlertPaymentErrorTitle),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              style: FilledButton.styleFrom(
                backgroundColor: MBETheme.brandBlack,
              ),
              child: Text(l10nDialog.preAlertAccept),
            ),
          ],
        );
      },
    );
  }
}

/// Botones de navegación estilo Grab
class _NavigationButtons extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final orderState = ref.watch(createOrderProvider);

    // Validar si puede continuar según el paso actual
    final canContinue = _canContinueFromStep(currentStep, orderState);

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
                onPressed: canContinue ? onContinue : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: MBESpacing.lg),
                  backgroundColor: MBETheme.brandBlack,
                  disabledBackgroundColor: MBETheme.neutralGray.withValues(alpha: 0.3),
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
                  currentStep < totalSteps
                      ? l10n.preAlertContinue
                      : l10n.preAlertFinish,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Determina si el usuario puede continuar desde el paso actual
  bool _canContinueFromStep(int step, CreateOrderState state) {
    switch (step) {
      case 1:
        // Paso 1: debe haber al menos un archivo subido
        return state.uploadedFiles.isNotEmpty && !state.hasFileErrors;
      case 3:
        // Paso 3: debe haber seleccionado método de entrega válido
        final delivery = state.request?.deliveryInfo;
        if (delivery == null) return false;
        if (delivery.method == 'pickup') {
          return delivery.pickupLocation != null;
        } else if (delivery.method == 'delivery') {
          return delivery.address != null &&
              delivery.address!.isNotEmpty &&
              delivery.phone != null &&
              delivery.phone!.isNotEmpty;
        }
        return false;
      default:
        // Otros pasos: siempre puede continuar
        return true;
    }
  }
}
