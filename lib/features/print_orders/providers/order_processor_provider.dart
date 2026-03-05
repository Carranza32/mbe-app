// lib/features/print_orders/providers/order_processor_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mbe_orders_app/l10n/app_localizations.dart';
import '../data/models/create_order_request.dart';
import '../data/repositories/print_order_repository.dart';
import 'create_order_provider.dart'; // ✅ CAMBIO: Usa el provider centralizado

part 'order_processor_provider.g.dart';

/// Estado del procesamiento de orden
enum OrderProcessingStatus { idle, processing, success, error }

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
  /// [l10n] para mensajes de error traducidos (ej: AppLocalizations.of(context)!)
  Future<bool> processOrder({
    String? cardNumber,
    String? cardHolder,
    String? expiryDate,
    String? cvv,
    required AppLocalizations l10n,
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
          errorMessage: l10n.printOrderMissingOrderData,
        );
        return false;
      }

      if (orderState.uploadedFiles.isEmpty) {
        state = OrderProcessingState(
          status: OrderProcessingStatus.error,
          errorMessage: l10n.printOrderNoFilesToPrint,
        );
        return false;
      }

      // Validar información del cliente
      if (!_isCustomerValid(request.customerInfo)) {
        state = OrderProcessingState(
          status: OrderProcessingStatus.error,
          errorMessage: l10n.printOrderContactInfoIncomplete,
        );
        return false;
      }

      // Validar información de entrega
      if (!_isDeliveryValid(request.deliveryInfo)) {
        state = OrderProcessingState(
          status: OrderProcessingStatus.error,
          errorMessage: l10n.printOrderDeliveryInfoIncomplete,
        );
        return false;
      }

      // Validar método de pago: transferencia exige comprobante; tarjeta se paga en WebView después de crear la orden
      final paymentInfo = orderState.paymentInfo;
      if (paymentInfo.method == PaymentMethod.transfer) {
        if (paymentInfo.transferProofPath == null ||
            paymentInfo.transferProofPath!.isEmpty) {
          state = OrderProcessingState(
            status: OrderProcessingStatus.error,
            errorMessage: l10n.preAlertUploadTransferProof,
          );
          return false;
        }
      }

      // Crear orden (para tarjeta no enviamos comprobante; el pago se inicia después con redirect_url)
      final repository = ref.read(printOrderRepositoryProvider);
      final response = await repository.createOrder(
        request,
        transferProofPath: paymentInfo.method == PaymentMethod.transfer
            ? paymentInfo.transferProofPath
            : null,
      );

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
        errorMessage: '${l10n.printOrderErrorProcessing}: $e',
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
