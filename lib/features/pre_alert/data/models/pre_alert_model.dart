// lib/features/pre_alert/data/models/pre_alert_model.dart

class PreAlert {
  final String id;
  final String trackingNumber;
  final String mailboxNumber;
  final String store;
  final double totalValue;
  final String status;
  final DateTime createdAt;
  final int productCount;

  PreAlert({
    required this.id,
    required this.trackingNumber,
    required this.mailboxNumber,
    required this.store,
    required this.totalValue,
    required this.status,
    required this.createdAt,
    required this.productCount,
  });

  factory PreAlert.fromJson(Map<String, dynamic> json) {
    return PreAlert(
      id: json['id'].toString(),
      trackingNumber: json['tracking_number'] as String,
      mailboxNumber: json['mailbox_number'] as String,
      store: json['store'] as String,
      totalValue: (json['total_value'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      productCount: json['product_count'] as int,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'received':
        return 'Recibido';
      case 'processing':
        return 'Procesando';
      case 'ready':
        return 'Listo';
      default:
        return status;
    }
  }

  String get statusColor {
    switch (status) {
      case 'pending':
        return '#EAB308'; // Yellow
      case 'received':
        return '#3B82F6'; // Blue
      case 'processing':
        return '#8B5CF6'; // Purple
      case 'ready':
        return '#10B981'; // Green
      default:
        return '#6B7280'; // Gray
    }
  }
}

class PreAlertsResponse {
  final List<PreAlert> preAlerts;
  final int currentPage;
  final int lastPage;
  final int total;

  PreAlertsResponse({
    required this.preAlerts,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory PreAlertsResponse.fromJson(Map<String, dynamic> json) {
    return PreAlertsResponse(
      preAlerts: (json['pre_alerts'] as List)
          .map((item) => PreAlert.fromJson(item))
          .toList(),
      currentPage: json['pagination']['current_page'],
      lastPage: json['pagination']['last_page'],
      total: json['pagination']['total'],
    );
  }
}
