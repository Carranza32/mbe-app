/// Respuesta del endpoint confirm-shipment-group
class ConfirmShipmentGroupResult {
  final int processedCount;
  final int failedCount;
  final List<int> processedIds;
  final List<int> failedIds;
  final List<FailedPackageItem> failed;

  ConfirmShipmentGroupResult({
    required this.processedCount,
    required this.failedCount,
    required this.processedIds,
    required this.failedIds,
    required this.failed,
  });

  factory ConfirmShipmentGroupResult.fromJson(Map<String, dynamic> json) {
    final data = json;
    final processedIdsRaw = data['processed_ids'] as List<dynamic>? ?? [];
    final failedIdsRaw = data['failed_ids'] as List<dynamic>? ?? [];
    final failedRaw = data['failed'] as List<dynamic>? ?? [];

    return ConfirmShipmentGroupResult(
      processedCount: data['processed_count'] as int? ?? 0,
      failedCount: data['failed_count'] as int? ?? 0,
      processedIds:
          processedIdsRaw
              .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
              .where((e) => e > 0)
              .toList(),
      failedIds:
          failedIdsRaw
              .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
              .where((e) => e > 0)
              .toList(),
      failed: failedRaw
          .map(
            (e) => FailedPackageItem.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  bool get hasFailures => failedCount > 0;
  bool get hasSuccess => processedCount > 0;
}

class FailedPackageItem {
  final int id;
  final String? trackNumber;
  final String? error;

  FailedPackageItem({
    required this.id,
    this.trackNumber,
    this.error,
  });

  factory FailedPackageItem.fromJson(Map<String, dynamic> json) {
    return FailedPackageItem(
      id: json['id'] as int? ?? int.tryParse(json['id']?.toString() ?? '') ?? 0,
      trackNumber: json['track_number'] as String? ?? json['trackNumber'] as String?,
      error: json['error'] as String?,
    );
  }
}
