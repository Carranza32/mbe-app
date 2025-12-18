import 'package_status.dart';

class AdminPreAlert {
  final String id;
  final String trackingNumber;
  final String eboxCode;
  final String clientName;
  final String provider;
  final double total;
  final int productCount;
  final String store;
  final String? deliveryMethod;
  final PackageStatus status;
  final DateTime createdAt;
  final DateTime? exportedAt;
  final bool isSelected;

  AdminPreAlert({
    required this.id,
    required this.trackingNumber,
    required this.eboxCode,
    required this.clientName,
    required this.provider,
    required this.total,
    required this.productCount,
    required this.store,
    this.deliveryMethod,
    required this.status,
    required this.createdAt,
    this.exportedAt,
    this.isSelected = false,
  });

  factory AdminPreAlert.fromJson(Map<String, dynamic> json) {
    return AdminPreAlert(
      id: json['id'].toString(),
      trackingNumber:
          json['tracking_number'] as String? ??
          json['trackingNumber'] as String,
      eboxCode: json['ebox_code'] as String? ?? json['eboxCode'] as String,
      clientName:
          json['client_name'] as String? ?? json['clientName'] as String,
      provider: json['provider'] as String,
      total: (json['total'] as num).toDouble(),
      productCount:
          json['product_count'] as int? ?? json['productCount'] as int? ?? 0,
      store: json['store'] as String,
      deliveryMethod:
          json['delivery_method'] as String? ??
          json['deliveryMethod'] as String?,
      status:
          PackageStatusExtension.fromKey(json['status'] as String) ??
          PackageStatus.pendingConfirmation,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? json['createdAt'] as String,
      ),
      exportedAt: json['exported_at'] != null
          ? DateTime.parse(json['exported_at'] as String)
          : json['exportedAt'] != null
          ? DateTime.parse(json['exportedAt'] as String)
          : null,
      isSelected:
          json['is_selected'] as bool? ?? json['isSelected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tracking_number': trackingNumber,
      'ebox_code': eboxCode,
      'client_name': clientName,
      'provider': provider,
      'total': total,
      'product_count': productCount,
      'store': store,
      'delivery_method': deliveryMethod,
      'status': status.key,
      'created_at': createdAt.toIso8601String(),
      'exported_at': exportedAt?.toIso8601String(),
      'is_selected': isSelected,
    };
  }

  AdminPreAlert copyWith({
    String? id,
    String? trackingNumber,
    String? eboxCode,
    String? clientName,
    String? provider,
    double? total,
    int? productCount,
    String? store,
    String? deliveryMethod,
    PackageStatus? status,
    DateTime? createdAt,
    DateTime? exportedAt,
    bool? isSelected,
  }) {
    return AdminPreAlert(
      id: id ?? this.id,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      eboxCode: eboxCode ?? this.eboxCode,
      clientName: clientName ?? this.clientName,
      provider: provider ?? this.provider,
      total: total ?? this.total,
      productCount: productCount ?? this.productCount,
      store: store ?? this.store,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      exportedAt: exportedAt ?? this.exportedAt,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
