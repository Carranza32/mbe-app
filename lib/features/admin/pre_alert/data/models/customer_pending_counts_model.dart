// lib/features/admin/pre_alert/data/models/customer_pending_counts_model.dart
class CustomerPendingCounts {
  final int pickupPending; // Paquetes pickup pendientes
  final int deliveryPending; // Paquetes delivery pendientes

  CustomerPendingCounts({
    required this.pickupPending,
    required this.deliveryPending,
  });

  factory CustomerPendingCounts.fromJson(Map<String, dynamic> json) {
    return CustomerPendingCounts(
      pickupPending: json['pickup_pending'] as int? ?? 0,
      deliveryPending: json['delivery_pending'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pickup_pending': pickupPending,
      'delivery_pending': deliveryPending,
    };
  }
}
