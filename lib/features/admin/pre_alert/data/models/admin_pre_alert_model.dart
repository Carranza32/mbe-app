import 'package_status.dart';
import 'product_item_model.dart';

class AdminPreAlert {
  final String id;
  final String trackingNumber;
  final String eboxCode;
  final String clientName;
  final String provider;
  final String? providerName;
  final double total;
  final int productCount;
  final String store;
  final String? deliveryMethod;
  final double? totalWeight; // Peso total del paquete
  final String? weightType; // Tipo de peso: "LB", "KG", etc.
  final PackageStatus status;
  final DateTime createdAt;
  final DateTime? exportedAt;
  final bool isSelected;

  // Campos de rack y segmento
  final String? rackNumber;
  final String? segmentNumber;

  // Campos de entrega
  final DateTime? deliveredAt;
  final String? deliveredTo; // "titular" | "encargado" | nombre del encargado
  final String? signaturePath; // Ruta de la imagen de firma
  final String? shippingProvider; // Proveedor de envíos para delivery

  // Campos adicionales del backend
  final int? customerId;
  final String? contactName;
  final String? contactEmail;
  final String? contactPhone;
  final String? contactNotes;
  final bool isDifferentReceiver;
  final String? receiverName;
  final String? receiverEmail;
  final String? receiverPhone;
  final int? customerAddressId;
  final int? storeId;

  // Lista de productos de la pre-alerta
  final List<ProductItem>? products;

  AdminPreAlert({
    required this.id,
    required this.trackingNumber,
    required this.eboxCode,
    required this.clientName,
    required this.provider,
    this.providerName,
    required this.total,
    required this.productCount,
    required this.store,
    this.deliveryMethod,
    this.totalWeight,
    this.weightType,
    required this.status,
    required this.createdAt,
    this.exportedAt,
    this.isSelected = false,
    // Rack y segmento
    this.rackNumber,
    this.segmentNumber,
    // Entrega
    this.deliveredAt,
    this.deliveredTo,
    this.signaturePath,
    this.shippingProvider,
    // Campos adicionales
    this.customerId,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    this.contactNotes,
    this.isDifferentReceiver = false,
    this.receiverName,
    this.receiverEmail,
    this.receiverPhone,
    this.customerAddressId,
    this.storeId,
    this.products,
  });

  factory AdminPreAlert.fromJson(Map<String, dynamic> json) {
    // Funciones auxiliares para parsear números de manera segura
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed;
      }
      return null;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        return parsed;
      }
      return null;
    }

    String? getStoreName(dynamic storeData) {
      if (storeData == null) return 'N/A';
      if (storeData is String) return storeData;
      if (storeData is Map<String, dynamic>) {
        return storeData['name'] as String? ??
            storeData['store_name'] as String? ??
            'N/A';
      }
      return 'N/A';
    }

    String? getClientName(dynamic customerData) {
      if (customerData == null) return 'N/A';
      if (customerData is String) return customerData;
      if (customerData is Map<String, dynamic>) {
        return customerData['name'] as String? ??
            customerData['full_name'] as String? ??
            'N/A';
      }
      return 'N/A';
    }

    String? getProviderName(dynamic providerData) {
      if (providerData == null) return null;
      if (providerData is String) return providerData;
      if (providerData is Map<String, dynamic>) {
        return providerData['name'] as String?;
      }
      return null;
    }

    PackageStatus getStatus(dynamic statusData) {
      if (statusData == null) return PackageStatus.ingresada;

      if (statusData is String) {
        // Primero intentar como key del estado
        final byKey = PackageStatusExtension.fromKey(statusData);
        if (byKey != null) return byKey;

        // Si no funciona, intentar parsearlo como ID numérico
        final parsedId = int.tryParse(statusData);
        if (parsedId != null) {
          final byId = PackageStatusExtension.fromStatusId(parsedId);
          if (byId != null) return byId;
        }

        return PackageStatus.ingresada;
      }

      if (statusData is int) {
        return PackageStatusExtension.fromStatusId(statusData) ??
            PackageStatus.ingresada;
      }

      if (statusData is Map) {
        // Intentar obtener el nombre del estado
        final statusName = statusData['name'] as String?;
        if (statusName != null) {
          return PackageStatusExtension.fromKey(statusName) ??
              PackageStatus.ingresada;
        }
        // Intentar obtener el key
        final statusKey = statusData['key'] as String?;
        if (statusKey != null) {
          return PackageStatusExtension.fromKey(statusKey) ??
              PackageStatus.ingresada;
        }
        // Intentar obtener el ID (puede venir como int o String)
        final statusIdValue = statusData['id'];
        if (statusIdValue != null) {
          final statusId = statusIdValue is int
              ? statusIdValue
              : (statusIdValue is String ? int.tryParse(statusIdValue) : null);
          if (statusId != null) {
            return PackageStatusExtension.fromStatusId(statusId) ??
                PackageStatus.ingresada;
          }
        }
      }

      return PackageStatus.ingresada;
    }

    return AdminPreAlert(
      id: json['id'].toString(),
      trackingNumber:
          json['track_number'] as String? ??
          json['tracking_number'] as String? ??
          '',
      eboxCode:
          json['package_code'] as String? ?? json['ebox_code'] as String? ?? '',
      clientName: getClientName(json['customer']) ?? 'N/A',
      provider:
          (getProviderName(json['provider']) ??
          json['provider_name'] as String? ??
          json['provider_other'] as String? ??
          'N/A'),
      providerName: json['provider_name'] as String?,
      total: parseDouble(json['total']) ?? 0.0,
      productCount: parseInt(json['product_count']) ?? 0,
      store: getStoreName(json['store']) ?? 'N/A',
      deliveryMethod: json['delivery_method'] as String?,
      totalWeight: parseDouble(json['total_weight']),
      weightType: json['weight_type'] as String?,
      status: getStatus(
        json['current_status'] ?? json['current_status_id'] ?? json['status'],
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      exportedAt: json['last_exported_at'] != null
          ? DateTime.tryParse(json['last_exported_at'] as String)
          : null,
      isSelected: false,
      // Rack y segmento
      rackNumber: json['rack_number'] as String?,
      segmentNumber: json['segment_number'] as String?,
      // Entrega
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'] as String)
          : null,
      deliveredTo: json['delivered_to'] as String?,
      signaturePath: json['signature_path'] as String?,
      shippingProvider: json['shipping_provider_name'] as String? ??
          (json['shipping_provider'] is Map
              ? (json['shipping_provider'] as Map)['name'] as String?
              : json['shipping_provider'] as String?),
      // Campos adicionales
      customerId: parseInt(json['customer_id']),
      contactName: json['contact_name'] as String?,
      contactEmail: json['contact_email'] as String?,
      contactPhone: json['contact_phone'] as String?,
      contactNotes: json['contact_notes'] as String?,
      isDifferentReceiver: (parseInt(json['is_different_receiver']) ?? 0) == 1,
      receiverName: json['receiver_name'] as String?,
      receiverEmail: json['receiver_email'] as String?,
      receiverPhone: json['receiver_phone'] as String?,
      customerAddressId: parseInt(json['customer_address_id']),
      storeId: parseInt(json['store_id']),
      // Parsear productos si vienen en el JSON
      products: json['products'] != null
          ? (json['products'] as List)
                .map(
                  (item) => ProductItem.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tracking_number': trackingNumber,
      'ebox_code': eboxCode,
      'client_name': clientName,
      'provider': provider,
      'provider_name': providerName,
      'total': total,
      'product_count': productCount,
      'store': store,
      'delivery_method': deliveryMethod,
      'total_weight': totalWeight,
      'weight_type': weightType,
      'status': status.key,
      'status_id': status.statusId,
      'created_at': createdAt.toIso8601String(),
      'exported_at': exportedAt?.toIso8601String(),
      'is_selected': isSelected,
      // Rack y segmento
      'rack_number': rackNumber,
      'segment_number': segmentNumber,
      // Entrega
      'delivered_at': deliveredAt?.toIso8601String(),
      'delivered_to': deliveredTo,
      'signature_path': signaturePath,
      'shipping_provider': shippingProvider,
      // Campos adicionales
      'customer_id': customerId,
      'contact_name': contactName,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'contact_notes': contactNotes,
      'is_different_receiver': isDifferentReceiver ? 1 : 0,
      'receiver_name': receiverName,
      'receiver_email': receiverEmail,
      'receiver_phone': receiverPhone,
      'customer_address_id': customerAddressId,
      'store_id': storeId,
      // Productos
      if (products != null)
        'products': products!.map((p) => p.toJson()).toList(),
    };
  }

  AdminPreAlert copyWith({
    String? id,
    String? trackingNumber,
    String? eboxCode,
    String? clientName,
    String? provider,
    String? providerName,
    double? total,
    int? productCount,
    String? store,
    String? deliveryMethod,
    double? totalWeight,
    String? weightType,
    PackageStatus? status,
    DateTime? createdAt,
    DateTime? exportedAt,
    bool? isSelected,
    // Rack y segmento
    String? rackNumber,
    String? segmentNumber,
    // Entrega
    DateTime? deliveredAt,
    String? deliveredTo,
    String? signaturePath,
    String? shippingProvider,
    // Campos adicionales
    int? customerId,
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    String? contactNotes,
    bool? isDifferentReceiver,
    String? receiverName,
    String? receiverEmail,
    String? receiverPhone,
    int? customerAddressId,
    int? storeId,
    List<ProductItem>? products,
  }) {
    return AdminPreAlert(
      id: id ?? this.id,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      eboxCode: eboxCode ?? this.eboxCode,
      clientName: clientName ?? this.clientName,
      provider: provider ?? this.provider,
      providerName: providerName ?? this.providerName,
      total: total ?? this.total,
      productCount: productCount ?? this.productCount,
      store: store ?? this.store,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      totalWeight: totalWeight ?? this.totalWeight,
      weightType: weightType ?? this.weightType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      exportedAt: exportedAt ?? this.exportedAt,
      isSelected: isSelected ?? this.isSelected,
      // Rack y segmento
      rackNumber: rackNumber ?? this.rackNumber,
      segmentNumber: segmentNumber ?? this.segmentNumber,
      // Entrega
      deliveredAt: deliveredAt ?? this.deliveredAt,
      deliveredTo: deliveredTo ?? this.deliveredTo,
      signaturePath: signaturePath ?? this.signaturePath,
      shippingProvider: shippingProvider ?? this.shippingProvider,
      // Campos adicionales
      customerId: customerId ?? this.customerId,
      contactName: contactName ?? this.contactName,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      contactNotes: contactNotes ?? this.contactNotes,
      isDifferentReceiver: isDifferentReceiver ?? this.isDifferentReceiver,
      receiverName: receiverName ?? this.receiverName,
      receiverEmail: receiverEmail ?? this.receiverEmail,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      customerAddressId: customerAddressId ?? this.customerAddressId,
      storeId: storeId ?? this.storeId,
      products: products ?? this.products,
    );
  }
}
