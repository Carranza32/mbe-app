import 'admin_pre_alert_model.dart';
import 'package_status.dart';

/// Respuesta del endpoint /admin/pre-alerts/search-for-delivery
class DeliverySearchResponse {
  final String type; // "package" o "customer"
  final CustomerInfo customer;
  final AdminPreAlert? package; // Solo cuando type=package
  final List<AdminPreAlert> deliverablePackages; // Solo cuando type=customer
  final List<AdminPreAlert> otherPackages; // Solo cuando type=customer
  final Map<String, int> totalsByStatus;

  DeliverySearchResponse({
    required this.type,
    required this.customer,
    this.package,
    this.deliverablePackages = const [],
    this.otherPackages = const [],
    this.totalsByStatus = const {},
  });

  factory DeliverySearchResponse.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'package';
    final customerJson = json['customer'] as Map<String, dynamic>?;
    final totalsJson = json['totals_by_status'] as Map<String, dynamic>? ?? {};

    // Parsear customer
    final customer = customerJson != null
        ? CustomerInfo.fromJson(customerJson)
        : CustomerInfo.empty();

    // Parsear totals
    final totalsByStatus = totalsJson.map(
      (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
    );

    if (type == 'package') {
      // Respuesta de búsqueda por paquete
      final packageJson = json['package'] as Map<String, dynamic>?;
      AdminPreAlert? package;
      
      if (packageJson != null) {
        package = _parsePackageFromDeliverySearch(packageJson, customer);
      }

      return DeliverySearchResponse(
        type: type,
        customer: customer,
        package: package,
        deliverablePackages: package != null ? [package] : [],
        totalsByStatus: totalsByStatus,
      );
    } else {
      // Respuesta de búsqueda por cliente
      final deliverableJson = json['deliverable_packages'] as List<dynamic>? ?? [];
      final otherJson = json['other_packages'] as List<dynamic>? ?? [];

      final deliverablePackages = deliverableJson
          .map((p) => _parsePackageFromDeliverySearch(
                p as Map<String, dynamic>,
                customer,
              ))
          .toList();

      final otherPackages = otherJson
          .map((p) => _parsePackageFromDeliverySearch(
                p as Map<String, dynamic>,
                customer,
              ))
          .toList();

      return DeliverySearchResponse(
        type: type,
        customer: customer,
        deliverablePackages: deliverablePackages,
        otherPackages: otherPackages,
        totalsByStatus: totalsByStatus,
      );
    }
  }

  /// Todos los paquetes (deliverable + other)
  List<AdminPreAlert> get allPackages => [...deliverablePackages, ...otherPackages];

  /// Stats calculados desde totals_by_status
  CustomerStats get stats {
    final delivered = totalsByStatus['entregado'] ?? 0;
    final disponible = totalsByStatus['disponible_para_retiro'] ?? 0;
    final solicitud = totalsByStatus['solicitud_recoleccion'] ?? 0;
    final enRuta = totalsByStatus['en_ruta'] ?? 0;
    final confirmada = totalsByStatus['confirmada_recoleccion'] ?? 0;
    final available = disponible + solicitud + confirmada;
    final total = totalsByStatus.values.fold(0, (sum, val) => sum + val);
    final deliverableTotal =
        disponible + solicitud + enRuta + confirmada; // Paquetes entregables

    return CustomerStats(
      total: total,
      delivered: delivered,
      available: available,
      deliverableTotal: deliverableTotal,
    );
  }
}

/// Información del cliente
class CustomerInfo {
  final int id;
  final String code;
  final String name;
  final String? email;
  final String? phone;

  CustomerInfo({
    required this.id,
    required this.code,
    required this.name,
    this.email,
    this.phone,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      id: json['id'] as int? ?? 0,
      code: json['locker_code'] as String? ?? json['code'] as String? ?? '',
      name: json['name'] as String? ?? json['full_name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  factory CustomerInfo.empty() {
    return CustomerInfo(id: 0, code: '', name: '');
  }
}

/// Estadísticas de paquetes del cliente
class CustomerStats {
  final int total;
  final int delivered;
  final int available;

  /// Paquetes pendientes de entregar (disponible + solicitud + en_ruta + confirmada)
  final int deliverableTotal;

  CustomerStats({
    required this.total,
    required this.delivered,
    required this.available,
    this.deliverableTotal = 0,
  });

  int get pending => total - delivered - available;
}

/// Helper para parsear paquete desde el formato del endpoint de delivery search
AdminPreAlert _parsePackageFromDeliverySearch(
  Map<String, dynamic> json,
  CustomerInfo customer,
) {
  final statusJson = json['current_status'] as Map<String, dynamic>?;
  final storeJson = json['store'] as Map<String, dynamic>?;

  // Determinar el status
  PackageStatus status = PackageStatus.enTransito;
  if (statusJson != null) {
    final statusName = statusJson['name'] as String?;
    final statusId = statusJson['id'] as int?;
    if (statusName != null) {
      status = PackageStatusExtension.fromKey(statusName) ?? PackageStatus.enTransito;
    } else if (statusId != null) {
      status = PackageStatusExtension.fromStatusId(statusId) ?? PackageStatus.enTransito;
    }
  }

  return AdminPreAlert(
    id: (json['id'] as int?)?.toString() ?? '',
    trackingNumber: json['track_number'] as String? ?? '',
    eboxCode: json['package_code'] as String? ?? '',
    clientName: customer.name,
    provider: json['provider_name'] as String? ?? '',
    providerName: json['provider_name'] as String?,
    total: (json['total'] as num?)?.toDouble() ?? 0.0,
    productCount: json['product_count'] as int? ?? 1,
    store: storeJson?['name'] as String? ?? '',
    storeId: storeJson?['id'] as int?,
    deliveryMethod: json['delivery_method'] as String?,
    totalWeight: (json['total_weight'] as num?)?.toDouble(),
    weightType: json['weight_type'] as String? ?? 'LB',
    status: status,
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
        : DateTime.now(),
    rackNumber: json['rack_number'] as String?,
    segmentNumber: json['segment_number'] as String?,
    customerId: customer.id,
    contactEmail: customer.email,
    contactPhone: customer.phone,
    isDifferentReceiver: json['is_different_receiver'] as bool? ?? false,
    receiverName: json['receiver_name'] as String?,
    receiverEmail: json['receiver_email'] as String?,
    receiverPhone: json['receiver_phone'] as String?,
  );
}
