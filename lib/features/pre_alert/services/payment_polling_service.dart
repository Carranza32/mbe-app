import 'dart:async';
import '../data/repositories/payment_repository.dart';
import '../data/models/payment_models.dart';

/// Servicio para hacer polling del estado de un pago
class PaymentPollingService {
  final PaymentRepository _paymentRepository;
  Timer? _timer;
  final int _pollIntervalSeconds = 3; // Poll cada 3 segundos
  final int _maxPolls = 60; // Máximo 3 minutos (60 * 3 segundos)
  
  int _currentPollCount = 0;
  final StreamController<PaymentStatus> _statusController =
      StreamController<PaymentStatus>.broadcast();

  Stream<PaymentStatus> get statusStream => _statusController.stream;

  PaymentPollingService(this._paymentRepository);

  /// Iniciar el polling del estado del pago
  void startPolling(int paymentId) {
    _currentPollCount = 0;
    _timer?.cancel();
    
    _timer = Timer.periodic(
      Duration(seconds: _pollIntervalSeconds),
      (timer) async {
        if (_currentPollCount >= _maxPolls) {
          stopPolling();
          _statusController.addError('Tiempo de espera agotado');
          return;
        }

        try {
          final statusResponse =
              await _paymentRepository.getPaymentStatus(paymentId.toString());
          _statusController.add(statusResponse.payment);
          
          // Si el pago está completo o fallido, dejar de hacer polling
          if (statusResponse.payment.isCompleted ||
              statusResponse.payment.isFailed) {
            stopPolling();
          }
          
          _currentPollCount++;
        } catch (e) {
          _statusController.addError(e);
          stopPolling();
        }
      },
    );
    
    // Primera verificación inmediata
    _checkStatus(paymentId);
  }

  Future<void> _checkStatus(int paymentId) async {
    try {
      final statusResponse =
          await _paymentRepository.getPaymentStatus(paymentId.toString());
      _statusController.add(statusResponse.payment);
    } catch (e) {
      _statusController.addError(e);
    }
  }

  /// Detener el polling
  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  /// Liberar recursos
  void dispose() {
    stopPolling();
    _statusController.close();
  }
}
