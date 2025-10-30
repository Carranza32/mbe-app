// lib/features/print_orders/providers/order_processor_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/create_order_request.dart';
import '../data/repositories/print_order_repository.dart';
import 'create_order_provider.dart'; // ✅ CAMBIO: Usa el provider centralizado
import 'confirmation_state_provider.dart'; // Solo para método de pago

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

      // ✅ CAMBIO: Obtener el request del provider centralizado
      final orderState = ref.read(createOrderProvider);
      final request = orderState.request;

      // Validaciones
      if (request == null) {
        state = OrderProcessingState(
          status: OrderProcessingStatus.error,
          errorMessage: 'Faltan datos del pedido',
        );
        return false;
      }

      if (orderState.uploadedFiles.isEmpty) {
        state = OrderProcessingState(
          status: OrderProcessingStatus.error,
          errorMessage: 'No hay archivos para imprimir',
        );
        return false;
      }

      // Validar información del cliente
      if (!_isCustomerValid(request.customerInfo)) {
        state = OrderProcessingState(
          status: OrderProcessingStatus.error,
          errorMessage: 'Información de contacto incompleta',
        );
        return false;
      }

      // Validar información de entrega
      if (!_isDeliveryValid(request.deliveryInfo)) {
        state = OrderProcessingState(
          status: OrderProcessingStatus.error,
          errorMessage: 'Información de entrega incompleta',
        );
        return false;
      }

      // Validar método de pago con tarjeta
      final confirmationState = ref.read(confirmationStateProvider);
      if (confirmationState.paymentMethod == PaymentMethod.card) {
        if (cardNumber == null || cardNumber.isEmpty ||
            cardHolder == null || cardHolder.isEmpty ||
            expiryDate == null || expiryDate.isEmpty ||
            cvv == null || cvv.isEmpty) {
          state = OrderProcessingState(
            status: OrderProcessingStatus.error,
            errorMessage: 'Completa la información de la tarjeta',
          );
          return false;
        }
      }

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

  /// Validar información del cliente
  bool _isCustomerValid(CustomerInfo customer) {
    return customer.name.isNotEmpty && 
           customer.email.isNotEmpty &&
           RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(customer.email);
  }

  /// Validar información de entrega
  bool _isDeliveryValid(DeliveryInfo delivery) {
    if (delivery.method == 'pickup') {
      return delivery.pickupLocation != null;
    } else {
      return delivery.address != null && 
             delivery.address!.isNotEmpty &&
             delivery.phone != null &&
             delivery.phone!.isNotEmpty;
    }
  }

  /// Resetear el estado
  void reset() {
    state = OrderProcessingState.idle();
  }
}