/// Modelos para el sistema de pago (transferencia, efectivo, tarjeta CyberSource)

class PaymentInitResponse {
  final bool success;
  final int paymentId;
  final String referenceNumber;
  /// URL para abrir en WebView (tarjeta). Null en efectivo.
  final String? redirectUrl;
  final double amount;
  final String currency;
  final String status;
  final String gateway; // 'transfer' | 'cash' | 'cybersource' | 'card'
  final String? cybersourceUrl;
  final Map<String, dynamic>? cybersourceParams;

  PaymentInitResponse({
    required this.success,
    required this.paymentId,
    required this.referenceNumber,
    this.redirectUrl,
    this.amount = 0.0,
    this.currency = 'USD',
    this.status = 'pending',
    this.gateway = 'cash',
    this.cybersourceUrl,
    this.cybersourceParams,
  });

  factory PaymentInitResponse.fromJson(Map<String, dynamic> json) {
    final id = (json['payment_id'] as num?)?.toInt() ?? 0;
    return PaymentInitResponse(
      success: id > 0,
      paymentId: id,
      referenceNumber: json['reference_number']?.toString() ?? '',
      redirectUrl: json['redirect_url']?.toString(),
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency']?.toString() ?? 'USD',
      status: json['status']?.toString() ?? 'pending',
      gateway: json['gateway']?.toString() ?? 'cash',
      cybersourceUrl: json['cybersource_url']?.toString(),
      cybersourceParams: json['cybersource_params'] as Map<String, dynamic>?,
    );
  }

  /// True si hay URL para abrir el hosted checkout (tarjeta).
  bool get hasRedirectUrl =>
      redirectUrl != null && redirectUrl!.trim().isNotEmpty;
}

class PaymentStatusResponse {
  final bool success;
  final PaymentStatus payment;
  final PayableInfo? payable;

  PaymentStatusResponse({
    required this.success,
    required this.payment,
    this.payable,
  });

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    final payment = json['payment'];
    return PaymentStatusResponse(
      success: payment != null,
      payment: PaymentStatus.fromJson(
        payment is Map<String, dynamic> ? payment : {},
      ),
      payable: json['payable'] != null
          ? PayableInfo.fromJson(json['payable'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Atajo: pago completado con éxito.
  bool get isCompleted => payment.isCompleted;
  /// Atajo: pago fallido o rechazado.
  bool get isFailed => payment.isFailed;
}

class PaymentStatus {
  final int id;
  final String status;
  final String referenceNumber;
  final double amount;
  final String currency;
  final bool isCompleted;
  final bool isFailed;
  final bool isPending;
  final String? transactionId;
  final String? reasonMessage;
  final DateTime? completedAt;

  PaymentStatus({
    required this.id,
    required this.status,
    required this.referenceNumber,
    required this.amount,
    required this.currency,
    required this.isCompleted,
    required this.isFailed,
    required this.isPending,
    this.transactionId,
    this.reasonMessage,
    this.completedAt,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      id: (json['id'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? '',
      referenceNumber: json['reference_number']?.toString() ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency']?.toString() ?? 'USD',
      isCompleted: json['is_completed'] == true,
      isFailed: json['is_failed'] == true,
      isPending: json['is_pending'] == true,
      transactionId: json['transaction_id']?.toString(),
      reasonMessage: json['reason_message']?.toString(),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
    );
  }
}

class PayableInfo {
  final int id;
  final String type;

  PayableInfo({
    required this.id,
    required this.type,
  });

  factory PayableInfo.fromJson(Map<String, dynamic> json) {
    return PayableInfo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type']?.toString() ?? '',
    );
  }
}

/// Respuesta de GET /api/v1/payments/{id}/redirect-url (opcional).
class PaymentRedirectUrlResponse {
  final String redirectUrl;
  final String method;

  PaymentRedirectUrlResponse({
    required this.redirectUrl,
    this.method = 'GET',
  });

  factory PaymentRedirectUrlResponse.fromJson(Map<String, dynamic> json) {
    return PaymentRedirectUrlResponse(
      redirectUrl: json['redirect_url']?.toString() ?? '',
      method: json['method']?.toString() ?? 'GET',
    );
  }
}

class PaymentResult {
  final bool success;
  final int paymentId;
  final bool cancelled;

  PaymentResult({
    required this.success,
    required this.paymentId,
    this.cancelled = false,
  });
}
