import 'admin_pre_alert_model.dart';

class ReceptionResult {
  final int processedCount;
  final int failedCount;
  final List<AdminPreAlert> packages;
  final List<dynamic> failed; // Paquetes que fallaron

  ReceptionResult({
    required this.processedCount,
    required this.failedCount,
    required this.packages,
    required this.failed,
  });

  factory ReceptionResult.fromJson(Map<String, dynamic> json) {
    // Si viene envuelto en 'data', extraerlo
    final data = json.containsKey('data') ? json['data'] as Map<String, dynamic> : json;
    
    return ReceptionResult(
      processedCount: data['processed_count'] as int? ?? 0,
      failedCount: data['failed_count'] as int? ?? 0,
      packages: (data['packages'] as List<dynamic>?)
              ?.map((e) => AdminPreAlert.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      failed: data['failed'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'processed_count': processedCount,
      'failed_count': failedCount,
      'packages': packages.map((p) => p.toJson()).toList(),
      'failed': failed,
    };
  }
}

