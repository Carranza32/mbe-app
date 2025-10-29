import 'package:iconsax/iconsax.dart';
import '../models/step_model.dart';

/// Pasos del formulario de pedido de impresión
class PrintOrderSteps {
  PrintOrderSteps._();

  static const List<StepModel> steps = [
    StepModel(
      id: 1,
      label: 'Archivos',
      icon: Iconsax.document_text,
      description: 'Sube tus documentos',
    ),
    StepModel(
      id: 2,
      label: 'Configurar',
      icon: Iconsax.setting_2,
      description: 'Opciones de impresión',
    ),
    StepModel(
      id: 3,
      label: 'Entrega',
      icon: Iconsax.truck,
      description: 'Método de entrega',
    ),
    StepModel(
      id: 4,
      label: 'Confirmar',
      icon: Iconsax.tick_circle,
      description: 'Revisar pedido',
    ),
    StepModel(
      id: 5,
      label: 'Pago',
      icon: Iconsax.dollar_circle,
      description: 'Completa tu pago',
    ),
  ];
}