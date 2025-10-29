import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/create_order_request.dart';
import '../data/repositories/print_order_repository.dart';
import 'print_order_provider.dart';
import 'print_configuration_state_provider.dart';
import 'delivery_state_provider.dart';
import 'confirmation_state_provider.dart';

part 'order_processor_provider.g.dart';

/// Estado del procesamiento de orden
enum OrderProcessingStatus {
  idle,
  processing,
  success,
  error,
}

class OrderProcessingState {
  final OrderProcessingStatus status;
  final String? orderId;
  final String? errorMessage;
  final String? paymentUrl;

  OrderProcessingState({
    required this.status,
    this.orderId,
    this.errorMessage,
    this.paymentUrl,
  });

  OrderProcessingState.idle()
      : status = OrderProcessingStatus.idle,
        orderId = null,
        errorMessage = null,
        paymentUrl = null;

  bool get isProcessing => status == OrderProcessingStatus.processing;
  bool get isSuccess => status == OrderProcessingStatus.success;
  bool get isError => status == OrderProcessingStatus.error;
}

@riverpod
class OrderProcessor extends _$OrderProcessor {
  @override
  OrderProcessingState build() {
    return OrderProcessingState.idle();
  }

  /// Procesar y enviar la orden
  Future<bool> processOrder({
    String? cardNumber,
    String? cardHolder,
    String? expiryDate,
    String? cvv,
  }) async {
    try {
      // Cambiar estado a procesando
      state = OrderProcessingState(status: OrderProcessingStatus.processing);

      // Obtener todos los estados necesarios
      final orderState = ref.read(printOrderProvider);
      final printConfig = ref.read(printConfigurationStateProvider);
      final deliveryState = ref.read(deliveryStateProvider);
      final confirmationState = ref.read(confirmationStateProvider);

      // Validar que tenemos todos los datos necesarios
      if (orderState.files.isEmpty) {
        state = OrderProcessingState(
          status: OrderProcessingStatus.error,
          errorMessage: 'No hay archivos para imprimir',
        );
        return false;
      }

      if (!confirmationState.isValid) {
        state = OrderProcessingState(
          status: OrderProcessingStatus.error,
          errorMessage: 'Información de contacto incompleta',
        );
        return false;
      }

      if (!deliveryState.isValid) {
        state = OrderProcessingState(
          status: OrderProcessingStatus.error,
          errorMessage: 'Información de entrega incompleta',
        );
        return false;
      }

      // Construir el request
      final request = CreateOrderRequest(
        customerInfo: CustomerInfo(
          name: confirmationState.fullName,
          email: confirmationState.email,
          phone: confirmationState.phone.isNotEmpty ? confirmationState.phone : null,
          notes: confirmationState.notes.isNotEmpty ? confirmationState.notes : null,
        ),
        printConfig: PrintConfig(
          printType: printConfig.printType == PrintType.blackWhite ? 'bw' : 'color',
          paperSize: _getPaperSizeString(printConfig.paperSize),
          paperType: printConfig.paperType == PaperType.bond ? 'bond' : 'photo_glossy',
          orientation: printConfig.orientation == Orientation.vertical 
              ? 'portrait'  // ← Cambio
              : 'landscape', // ← Cambio
          copies: printConfig.copies,
          doubleSided: printConfig.doubleSided,
          binding: printConfig.binding,
        ),
        deliveryInfo: DeliveryInfo(
          method: deliveryState.isPickup ? 'pickup' : 'delivery',
          pickupLocation: deliveryState.isPickup 
              ? int.tryParse(deliveryState.selectedLocationId ?? '')
              : null,
          address: deliveryState.isDelivery ? deliveryState.deliveryAddress : null,
          phone: deliveryState.isDelivery ? deliveryState.deliveryPhone : null,
          notes: deliveryState.isDelivery ? deliveryState.deliveryNotes : null,
        ),
        files: orderState.files.map((f) => f.file.path).toList(),
      );

      // Enviar al backend
      final repository = ref.read(printOrderRepositoryProvider);
      final response = await repository.createOrder(request);

      // Actualizar estado con éxito
      state = OrderProcessingState(
        status: OrderProcessingStatus.success,
        orderId: response.orderId,
      );

      return true;
    } catch (e) {
      // Manejar error
      state = OrderProcessingState(
        status: OrderProcessingStatus.error,
        errorMessage: 'Error al procesar el pedido: $e',
      );
      return false;
    }
  }

  String _getPaperSizeString(PaperSize size) {
    switch (size) {
      case PaperSize.letter:
        return 'letter';
      case PaperSize.legal:
        return 'legal';
      case PaperSize.doubleLetter:
        return 'double_letter';
    }
  }

  String _getPaymentMethodString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.card:
        return 'card';
      case PaymentMethod.transfer:
        return 'transfer';
    }
  }

  void reset() {
    state = OrderProcessingState.idle();
  }
}