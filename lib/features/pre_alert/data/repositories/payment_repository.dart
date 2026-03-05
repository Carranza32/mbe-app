import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../models/payment_models.dart';

part 'payment_repository.g.dart';

@riverpod
PaymentRepository paymentRepository(Ref ref) {
  return PaymentRepository(ref.read(apiServiceProvider));
}

class PaymentRepository {
  final ApiService _apiService;

  PaymentRepository(this._apiService);

  static PaymentInitResponse _parseInitResponse(dynamic json) {
    if (json == null) throw Exception('Respuesta vacía del servidor');
    if (json is Map<String, dynamic>) {
      return PaymentInitResponse.fromJson(json);
    }
    throw Exception('Formato de respuesta inesperado');
  }

  /// Iniciar pago en efectivo (contra entrega). Body: gateway + total (obligatorio).
  Future<PaymentInitResponse> initiatePaymentCash(
    String preAlertId, {
    required double total,
  }) async {
    final data = <String, dynamic>{
      'gateway': 'cash',
      'total': total,
    };
    return await _apiService.post<PaymentInitResponse>(
      endpoint: ApiEndpoints.initiatePreAlertPayment(preAlertId),
      data: data,
      fromJson: _parseInitResponse,
    );
  }

  /// Iniciar pago por transferencia. Body multipart: gateway, transfer_proof (archivo), opcional total/reference/notes.
  Future<PaymentInitResponse> initiatePaymentTransfer(
    String preAlertId, {
    required String transferProofFilePath,
    double? total,
    String? transferReference,
    String? transferNotes,
  }) async {
    final files = <String, String>{
      'transfer_proof': transferProofFilePath,
    };
    final data = <String, dynamic>{
      'gateway': 'transfer',
      if (total != null) 'total': total,
      if (transferReference != null && transferReference.isNotEmpty)
        'transfer_reference': transferReference,
      if (transferNotes != null && transferNotes.isNotEmpty)
        'transfer_notes': transferNotes,
    };
    return await _apiService.uploadFiles<PaymentInitResponse>(
      endpoint: ApiEndpoints.initiatePreAlertPayment(preAlertId),
      files: files,
      data: data,
      fromJson: _parseInitResponse,
    );
  }

  /// Iniciar pago con tarjeta (CyberSource). API acepta gateway "card" como alias de "cybersource".
  /// Obligatorios: total. Opcionales: subtotal_pre_alerta, costo_envio, calculation.
  /// Devuelve redirect_url para abrir en WebView; si no viene, no abrir checkout externo.
  Future<PaymentInitResponse> initiatePaymentCard(
    String preAlertId, {
    required double total,
    double? subtotalPreAlerta,
    double? costoEnvio,
    Map<String, dynamic>? calculation,
  }) async {
    final data = <String, dynamic>{
      'gateway': 'card',
      'total': total,
      if (subtotalPreAlerta != null) 'subtotal_pre_alerta': subtotalPreAlerta,
      if (costoEnvio != null) 'costo_envio': costoEnvio,
      if (calculation != null && calculation.isNotEmpty) 'calculation': calculation,
    };
    return await _apiService.post<PaymentInitResponse>(
      endpoint: ApiEndpoints.initiatePreAlertPayment(preAlertId),
      data: data,
      fromJson: _parseInitResponse,
    );
  }

  /// Alias de [initiatePaymentCard] para compatibilidad. Preferir [initiatePaymentCard].
  Future<PaymentInitResponse> initiatePayment(String preAlertId, {required double total}) {
    return initiatePaymentCard(preAlertId, total: total);
  }

  /// Obtener el estado actual de un pago (polling para transfer: hasta que admin confirme).
  Future<PaymentStatusResponse> getPaymentStatus(String paymentId) async {
    return await _apiService.get<PaymentStatusResponse>(
      endpoint: ApiEndpoints.paymentStatus(paymentId),
      fromJson: (json) {
        if (json == null) throw Exception('Respuesta vacía del servidor');
        if (json is Map<String, dynamic>) {
          return PaymentStatusResponse.fromJson(json);
        }
        throw Exception('Formato de respuesta inesperado');
      },
    );
  }

  /// Obtener la URL de redirección de un pago (opcional).
  /// GET /api/v1/payments/{payment_id}/redirect-url.
  /// Si ya tienes redirect_url del paso 1 (iniciar pago), no hace falta llamar esto.
  Future<PaymentRedirectUrlResponse> getPaymentRedirectUrl(String paymentId) async {
    return await _apiService.get<PaymentRedirectUrlResponse>(
      endpoint: ApiEndpoints.paymentRedirectUrl(paymentId),
      fromJson: (json) {
        if (json == null) throw Exception('Respuesta vacía del servidor');
        if (json is Map<String, dynamic>) {
          return PaymentRedirectUrlResponse.fromJson(json);
        }
        throw Exception('Formato de respuesta inesperado');
      },
    );
  }
}
