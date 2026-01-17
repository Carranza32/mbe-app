/// Modelo de promoción
class PromotionModel {
  final int id;
  final String name;
  final String description;
  final String discountType;
  final double discountValue;
  final String appliesTo;
  final String discountLabel;
  final double estimatedDiscount;

  PromotionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.appliesTo,
    required this.discountLabel,
    required this.estimatedDiscount,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      discountType: json['discount_type'] as String,
      discountValue: (json['discount_value'] as num).toDouble(),
      appliesTo: json['applies_to'] as String,
      discountLabel: json['discount_label'] as String,
      estimatedDiscount: (json['estimated_discount'] as num).toDouble(),
    );
  }
}

/// Respuesta de mejor promoción
class BestPromotionResponse {
  final bool success;
  final PromotionModel? data;

  BestPromotionResponse({
    required this.success,
    this.data,
  });

  factory BestPromotionResponse.fromJson(Map<String, dynamic> json) {
    return BestPromotionResponse(
      success: json['success'] as bool? ?? true,
      data: json['data'] != null
          ? PromotionModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Request para obtener mejor promoción
class BestPromotionRequest {
  final int storeId;
  final String serviceType;
  final double subtotal;
  final double deliveryCost;
  final String appliesTo;
  final int? customerId;

  BestPromotionRequest({
    required this.storeId,
    required this.serviceType,
    required this.subtotal,
    required this.deliveryCost,
    required this.appliesTo,
    this.customerId,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'store_id': storeId,
      'service_type': serviceType,
      'subtotal': subtotal,
      'delivery_cost': deliveryCost,
      'applies_to': appliesTo,
    };
    if (customerId != null) {
      json['customer_id'] = customerId;
    }
    return json;
  }
}
