// lib/features/print_orders/data/models/create_order_request.dart

class CreateOrderRequest {
  final CustomerInfo customerInfo;
  final PrintConfig printConfig;
  final DeliveryInfo deliveryInfo;
  final List<String> files;

  CreateOrderRequest({
    required this.customerInfo,
    required this.printConfig,
    required this.deliveryInfo,
    required this.files,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer': {
        'name': customerInfo.name,
        'email': customerInfo.email,
        if (customerInfo.phone != null) 'phone': customerInfo.phone,
        if (customerInfo.notes != null) 'notes': customerInfo.notes,
      },
      'config': {
        'printType': printConfig.printType,
        'paperSize': printConfig.paperSize,
        'paperType': printConfig.paperType,
        'orientation': printConfig.orientation,
        'copies': printConfig.copies,
        'binding': printConfig.binding,
        'doubleSided': printConfig.doubleSided,
      },
      'delivery': {
        'method': deliveryInfo.method,
        if (deliveryInfo.pickupLocation != null) 
          'pickupLocation': deliveryInfo.pickupLocation,
        if (deliveryInfo.address != null) 
          'address': deliveryInfo.address,
        if (deliveryInfo.phone != null) 
          'phone': deliveryInfo.phone,
        if (deliveryInfo.notes != null) 
          'notes': deliveryInfo.notes,
      },
    };
  }
}

class CustomerInfo {
  final String name;
  final String email;
  final String? phone;
  final String? notes;

  CustomerInfo({
    required this.name,
    required this.email,
    this.phone,
    this.notes,
  });
}

class PrintConfig {
  final String printType; // 'bw' o 'color'
  final String paperSize; // 'letter', 'legal', 'double_letter'
  final String paperType; // 'bond', 'photo_glossy'
  final String orientation; // 'portrait' o 'landscape'
  final int copies;
  final bool doubleSided;
  final bool binding;

  PrintConfig({
    required this.printType,
    required this.paperSize,
    required this.paperType,
    required this.orientation,
    required this.copies,
    required this.doubleSided,
    required this.binding,
  });
}

class DeliveryInfo {
  final String method; // 'pickup' o 'delivery'
  final int? pickupLocation;
  final String? address;
  final String? phone;
  final String? notes;

  DeliveryInfo({
    required this.method,
    this.pickupLocation,
    this.address,
    this.phone,
    this.notes,
  });
}

class CreateOrderResponse {
  final String orderId;
  final String message;

  CreateOrderResponse({
    required this.orderId,
    required this.message,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      orderId: json['order_id'] ?? json['orderId'] ?? '',
      message: json['message'] ?? '',
    );
  }
}