// lib/features/print_orders/data/models/create_order_request.dart
import 'package:json_annotation/json_annotation.dart';

part 'create_order_request.g.dart';

@JsonSerializable(explicitToJson: true)
class CreateOrderRequest {
  @JsonKey(name: 'customer_info')
  final CustomerInfo customerInfo;
  
  @JsonKey(name: 'print_config')
  final PrintConfig printConfig;
  
  @JsonKey(name: 'delivery_info')
  final DeliveryInfo deliveryInfo;
  
  @JsonKey(name: 'payment_info')
  final PaymentInfo paymentInfo;
  
  final List<String> files;
  final String? notes;

  CreateOrderRequest({
    required this.customerInfo,
    required this.printConfig,
    required this.deliveryInfo,
    required this.paymentInfo,
    required this.files,
    this.notes,
  });

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderRequestFromJson(json);
  
  Map<String, dynamic> toJson() => _$CreateOrderRequestToJson(this);
}

@JsonSerializable()
class CustomerInfo {
  @JsonKey(name: 'full_name')
  final String fullName;
  final String email;
  final String? phone;

  CustomerInfo({
    required this.fullName,
    required this.email,
    this.phone,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) =>
      _$CustomerInfoFromJson(json);
  
  Map<String, dynamic> toJson() => _$CustomerInfoToJson(this);
}

@JsonSerializable()
class PrintConfig {
  @JsonKey(name: 'print_type')
  final String printType; // 'bw' o 'color'
  
  @JsonKey(name: 'paper_size')
  final String paperSize; // 'letter', 'legal', 'double_letter'
  
  @JsonKey(name: 'paper_type')
  final String paperType; // 'bond', 'glossy'
  
  final String orientation; // 'vertical', 'horizontal'
  final int copies;
  
  @JsonKey(name: 'double_sided')
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

  factory PrintConfig.fromJson(Map<String, dynamic> json) =>
      _$PrintConfigFromJson(json);
  
  Map<String, dynamic> toJson() => _$PrintConfigToJson(this);
}

@JsonSerializable()
class DeliveryInfo {
  @JsonKey(name: 'delivery_method')
  final String deliveryMethod; // 'pickup' o 'delivery'
  
  @JsonKey(name: 'pickup_location_id')
  final int? pickupLocationId;
  
  @JsonKey(name: 'delivery_address')
  final String? deliveryAddress;
  
  @JsonKey(name: 'delivery_phone')
  final String? deliveryPhone;
  
  @JsonKey(name: 'delivery_notes')
  final String? deliveryNotes;

  DeliveryInfo({
    required this.deliveryMethod,
    this.pickupLocationId,
    this.deliveryAddress,
    this.deliveryPhone,
    this.deliveryNotes,
  });

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) =>
      _$DeliveryInfoFromJson(json);
  
  Map<String, dynamic> toJson() => _$DeliveryInfoToJson(this);
}

@JsonSerializable()
class PaymentInfo {
  @JsonKey(name: 'payment_method')
  final String paymentMethod; // 'cash', 'card', 'transfer'
  
  @JsonKey(name: 'card_info')
  final CardInfo? cardInfo;

  PaymentInfo({
    required this.paymentMethod,
    this.cardInfo,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) =>
      _$PaymentInfoFromJson(json);
  
  Map<String, dynamic> toJson() => _$PaymentInfoToJson(this);
}

@JsonSerializable()
class CardInfo {
  @JsonKey(name: 'card_number')
  final String cardNumber;
  
  @JsonKey(name: 'card_holder')
  final String cardHolder;
  
  @JsonKey(name: 'expiry_date')
  final String expiryDate;
  
  final String cvv;

  CardInfo({
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryDate,
    required this.cvv,
  });

  factory CardInfo.fromJson(Map<String, dynamic> json) =>
      _$CardInfoFromJson(json);
  
  Map<String, dynamic> toJson() => _$CardInfoToJson(this);
}

// Respuesta del servidor
@JsonSerializable()
class CreateOrderResponse {
  @JsonKey(name: 'order_id')
  final String orderId;
  
  final String status;
  final String message;
  
  @JsonKey(name: 'payment_url')
  final String? paymentUrl;

  CreateOrderResponse({
    required this.orderId,
    required this.status,
    required this.message,
    this.paymentUrl,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$CreateOrderResponseToJson(this);
}