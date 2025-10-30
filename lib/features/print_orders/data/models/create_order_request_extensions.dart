// lib/features/print_orders/data/models/create_order_request_extensions.dart

import 'create_order_request.dart';

/// Extensiones para agregar copyWith a los modelos
extension CreateOrderRequestExtension on CreateOrderRequest {
  CreateOrderRequest copyWith({
    CustomerInfo? customerInfo,
    PrintConfig? printConfig,
    DeliveryInfo? deliveryInfo,
    List<String>? files,
  }) {
    return CreateOrderRequest(
      customerInfo: customerInfo ?? this.customerInfo,
      printConfig: printConfig ?? this.printConfig,
      deliveryInfo: deliveryInfo ?? this.deliveryInfo,
      files: files ?? this.files,
    );
  }
}

extension CustomerInfoExtension on CustomerInfo {
  CustomerInfo copyWith({
    String? name,
    String? email,
    String? phone,
    String? notes,
  }) {
    return CustomerInfo(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
    );
  }
}

extension PrintConfigExtension on PrintConfig {
  PrintConfig copyWith({
    String? printType,
    String? paperSize,
    String? paperType,
    String? orientation,
    int? copies,
    bool? doubleSided,
    bool? binding,
  }) {
    return PrintConfig(
      printType: printType ?? this.printType,
      paperSize: paperSize ?? this.paperSize,
      paperType: paperType ?? this.paperType,
      orientation: orientation ?? this.orientation,
      copies: copies ?? this.copies,
      doubleSided: doubleSided ?? this.doubleSided,
      binding: binding ?? this.binding,
    );
  }
}

extension DeliveryInfoExtension on DeliveryInfo {
  DeliveryInfo copyWith({
    String? method,
    int? pickupLocation,
    String? address,
    String? phone,
    String? notes,
  }) {
    return DeliveryInfo(
      method: method ?? this.method,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
    );
  }
}