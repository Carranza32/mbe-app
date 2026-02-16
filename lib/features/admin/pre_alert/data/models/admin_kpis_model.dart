// lib/features/admin/pre_alert/data/models/admin_kpis_model.dart
class AdminKPIs {
  final int createdToday; // Alertados hoy
  final int receivedToday; // Recibidos hoy
  final int totalWarehouse; // En bodega
  final int departuresToday; // Salidas hoy

  AdminKPIs({
    required this.createdToday,
    required this.receivedToday,
    required this.totalWarehouse,
    required this.departuresToday,
  });

  factory AdminKPIs.fromJson(Map<String, dynamic> json) {
    return AdminKPIs(
      createdToday: json['created_today'] as int? ?? 0,
      receivedToday: json['received_today'] as int? ?? 0,
      totalWarehouse: json['total_warehouse'] as int? ?? 0,
      departuresToday: json['departures_today'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_today': createdToday,
      'received_today': receivedToday,
      'total_warehouse': totalWarehouse,
      'departures_today': departuresToday,
    };
  }
}
