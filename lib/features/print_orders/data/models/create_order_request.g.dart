// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateOrderRequest _$CreateOrderRequestFromJson(Map<String, dynamic> json) =>
    CreateOrderRequest(
      customerInfo: CustomerInfo.fromJson(
        json['customer_info'] as Map<String, dynamic>,
      ),
      printConfig: PrintConfig.fromJson(
        json['print_config'] as Map<String, dynamic>,
      ),
      deliveryInfo: DeliveryInfo.fromJson(
        json['delivery_info'] as Map<String, dynamic>,
      ),
      paymentInfo: PaymentInfo.fromJson(
        json['payment_info'] as Map<String, dynamic>,
      ),
      files: (json['files'] as List<dynamic>).map((e) => e as String).toList(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$CreateOrderRequestToJson(CreateOrderRequest instance) =>
    <String, dynamic>{
      'customer_info': instance.customerInfo.toJson(),
      'print_config': instance.printConfig.toJson(),
      'delivery_info': instance.deliveryInfo.toJson(),
      'payment_info': instance.paymentInfo.toJson(),
      'files': instance.files,
      'notes': instance.notes,
    };

CustomerInfo _$CustomerInfoFromJson(Map<String, dynamic> json) => CustomerInfo(
  fullName: json['full_name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
);

Map<String, dynamic> _$CustomerInfoToJson(CustomerInfo instance) =>
    <String, dynamic>{
      'full_name': instance.fullName,
      'email': instance.email,
      'phone': instance.phone,
    };

PrintConfig _$PrintConfigFromJson(Map<String, dynamic> json) => PrintConfig(
  printType: json['print_type'] as String,
  paperSize: json['paper_size'] as String,
  paperType: json['paper_type'] as String,
  orientation: json['orientation'] as String,
  copies: (json['copies'] as num).toInt(),
  doubleSided: json['double_sided'] as bool,
  binding: json['binding'] as bool,
);

Map<String, dynamic> _$PrintConfigToJson(PrintConfig instance) =>
    <String, dynamic>{
      'print_type': instance.printType,
      'paper_size': instance.paperSize,
      'paper_type': instance.paperType,
      'orientation': instance.orientation,
      'copies': instance.copies,
      'double_sided': instance.doubleSided,
      'binding': instance.binding,
    };

DeliveryInfo _$DeliveryInfoFromJson(Map<String, dynamic> json) => DeliveryInfo(
  deliveryMethod: json['delivery_method'] as String,
  pickupLocationId: (json['pickup_location_id'] as num?)?.toInt(),
  deliveryAddress: json['delivery_address'] as String?,
  deliveryPhone: json['delivery_phone'] as String?,
  deliveryNotes: json['delivery_notes'] as String?,
);

Map<String, dynamic> _$DeliveryInfoToJson(DeliveryInfo instance) =>
    <String, dynamic>{
      'delivery_method': instance.deliveryMethod,
      'pickup_location_id': instance.pickupLocationId,
      'delivery_address': instance.deliveryAddress,
      'delivery_phone': instance.deliveryPhone,
      'delivery_notes': instance.deliveryNotes,
    };

PaymentInfo _$PaymentInfoFromJson(Map<String, dynamic> json) => PaymentInfo(
  paymentMethod: json['payment_method'] as String,
  cardInfo: json['card_info'] == null
      ? null
      : CardInfo.fromJson(json['card_info'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PaymentInfoToJson(PaymentInfo instance) =>
    <String, dynamic>{
      'payment_method': instance.paymentMethod,
      'card_info': instance.cardInfo,
    };

CardInfo _$CardInfoFromJson(Map<String, dynamic> json) => CardInfo(
  cardNumber: json['card_number'] as String,
  cardHolder: json['card_holder'] as String,
  expiryDate: json['expiry_date'] as String,
  cvv: json['cvv'] as String,
);

Map<String, dynamic> _$CardInfoToJson(CardInfo instance) => <String, dynamic>{
  'card_number': instance.cardNumber,
  'card_holder': instance.cardHolder,
  'expiry_date': instance.expiryDate,
  'cvv': instance.cvv,
};

CreateOrderResponse _$CreateOrderResponseFromJson(Map<String, dynamic> json) =>
    CreateOrderResponse(
      orderId: json['order_id'] as String,
      status: json['status'] as String,
      message: json['message'] as String,
      paymentUrl: json['payment_url'] as String?,
    );

Map<String, dynamic> _$CreateOrderResponseToJson(
  CreateOrderResponse instance,
) => <String, dynamic>{
  'order_id': instance.orderId,
  'status': instance.status,
  'message': instance.message,
  'payment_url': instance.paymentUrl,
};
