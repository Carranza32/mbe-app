import 'package:iconsax/iconsax.dart';
import 'package:mbe_orders_app/l10n/app_localizations.dart';
import '../models/step_model.dart';

/// Pasos del formulario de pedido de impresión
class PrintOrderSteps {
  PrintOrderSteps._();

  static List<StepModel> getSteps(AppLocalizations l10n) => [
    StepModel(
      id: 1,
      label: l10n.printOrderStepFiles,
      icon: Iconsax.document_text,
      description: l10n.printOrderStepFilesDesc,
    ),
    StepModel(
      id: 2,
      label: l10n.printOrderStepConfig,
      icon: Iconsax.setting_2,
      description: l10n.printOrderStepConfigDesc,
    ),
    StepModel(
      id: 3,
      label: l10n.preAlertDelivery,
      icon: Iconsax.truck,
      description: l10n.preAlertDeliveryMethod,
    ),
    StepModel(
      id: 4,
      label: l10n.printOrderStepConfirm,
      icon: Iconsax.tick_circle,
      description: l10n.printOrderStepConfirmDesc,
    ),
    StepModel(
      id: 5,
      label: l10n.preAlertPayment,
      icon: Iconsax.dollar_circle,
      description: l10n.preAlertCompletePayment,
    ),
  ];
}