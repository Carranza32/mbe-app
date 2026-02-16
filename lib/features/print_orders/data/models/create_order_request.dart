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
        if (deliveryInfo.method == 'pickup' && deliveryInfo.pickupLocation != null)
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