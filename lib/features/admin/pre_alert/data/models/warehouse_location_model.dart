class WarehouseLocation {
  final String rackNumber;
  final String segmentNumber;
  final bool isAvailable;
  final String? packageId; // Si está ocupado, el ID del paquete
  /// ID de la bodega (multi-bodega). Opcional, viene en la nueva API.
  final int? warehouseId;
  /// Nombre de la bodega. Opcional, viene en la nueva API.
  final String? warehouseName;

  WarehouseLocation({
    required this.rackNumber,
    required this.segmentNumber,
    required this.isAvailable,
    this.packageId,
    this.warehouseId,
    this.warehouseName,
  });

  factory WarehouseLocation.fromJson(Map<String, dynamic> json) {
    return WarehouseLocation(
      rackNumber: json['rack_number'] as String,
      segmentNumber: json['segment_number'] as String,
      isAvailable: json['is_available'] as bool? ?? true,
      packageId: json['package_id']?.toString(),
      warehouseId: json['warehouse_id'] is int
          ? json['warehouse_id'] as int
          : (int.tryParse(json['warehouse_id']?.toString() ?? '')),
      warehouseName: json['warehouse_name'] as String?,
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

