class WarehouseLocation {
  final String rackNumber;
  final String segmentNumber;
  final bool isAvailable;
  final String? packageId; // Si está ocupado, el ID del paquete

  WarehouseLocation({
    required this.rackNumber,
    required this.segmentNumber,
    required this.isAvailable,
    this.packageId,
  });

  factory WarehouseLocation.fromJson(Map<String, dynamic> json) {
    return WarehouseLocation(
      rackNumber: json['rack_number'] as String,
      segmentNumber: json['segment_number'] as String,
      isAvailable: json['is_available'] as bool? ?? true,
      packageId: json['package_id']?.toString(),
    );
  }

  String get fullLocation => '$rackNumber-$segmentNumber';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WarehouseLocation &&
          runtimeType == other.runtimeType &&
          rackNumber == other.rackNumber &&
          segmentNumber == other.segmentNumber;

  @override
  int get hashCode => rackNumber.hashCode ^ segmentNumber.hashCode;
}

