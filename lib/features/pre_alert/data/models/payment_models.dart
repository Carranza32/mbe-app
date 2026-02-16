/// Modelos para el sistema de pago (transferencia, efectivo, futuro Cybersource)

class PaymentInitResponse {
  final bool success;
  final int paymentId;
  final String referenceNumber;
  final String redirectUrl;
  final double amount;
  final String currency;
  final String status;
  final String gateway; // 'transfer' | 'cash' | 'cybersource'
  final String? cybersourceUrl;
  final Map<String, dynamic>? cybersourceParams;

  PaymentInitResponse({
    required this.success,
    required this.paymentId,
    required this.referenceNumber,
    required this.redirectUrl,
    this.amount = 0.0,
    this.currency = 'USD',
    this.status = 'pending',
    this.gateway = 'cash',
    this.cybersourceUrl,
    this.cybersourceParams,
  });

  factory PaymentInitResponse.fromJson(Map<String, dynamic> json) {
    return PaymentInitResponse(
      success: json['success'] ?? false,
      paymentId: json['payment_id'] ?? 0,
      referenceNumber: json['reference_number'] ?? '',
      redirectUrl: json['redirect_url'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      status: json['status'] ?? 'pending',
      gateway: json['gateway'] ?? 'cash',
      cybersourceUrl: json['cybersource_url'],
      cybersourceParams: json['cybersource_params'],
    );
  }
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
    return PaymentStatusResponse(
      success: json['success'] ?? false,
      payment: PaymentStatus.fromJson(json['payment'] ?? {}),
      payable: json['payable'] != null
          ? PayableInfo.fromJson(json['payable'])
          : null,
    );
  }
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
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      referenceNumber: json['reference_number'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      isCompleted: json['is_completed'] ?? false,
      isFailed: json['is_failed'] ?? false,
      isPending: json['is_pending'] ?? false,
      transactionId: json['transaction_id'],
      reasonMessage: json['reason_message'],
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
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
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
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
