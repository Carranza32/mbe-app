/// Configuración de entrega del pedido
class DeliveryConfiguration {
  final DeliveryMethod method;
  final String? pickupLocationId;
  final String? address;
  final String? phone;
  final String? notes;

  const DeliveryConfiguration({
    this.method = DeliveryMethod.pickup,
    this.pickupLocationId,
    this.address,
    this.phone,
    this.notes,
  });

  DeliveryConfiguration copyWith({
    DeliveryMethod? method,
    String? pickupLocationId,
    String? address,
    String? phone,
    String? notes,
  }) {
    return DeliveryConfiguration(
      method: method ?? this.method,
      pickupLocationId: pickupLocationId ?? this.pickupLocationId,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
    );
  }

  bool get isValid {
    if (method == DeliveryMethod.pickup) {
      return pickupLocationId != null;
    } else {
      return address != null &&
          address!.isNotEmpty &&
          phone != null &&
          phone!.isNotEmpty;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method == DeliveryMethod.pickup ? 'pickup' : 'delivery',
      'pickup_location_id': pickupLocationId,
      'address': address,
      'phone': phone,
      'notes': notes,
    };
  }
}

enum DeliveryMethod {
  pickup,
  delivery,
}

/// Configuración de costos de envío
class DeliveryPricing {
  final double baseCost;
  final double freeShippingThreshold;
  final String estimatedTime;

  const DeliveryPricing({
    this.baseCost = 2.00,
    this.freeShippingThreshold = 20.00,
    this.estimatedTime = '1-2 días hábiles',
  });

  factory DeliveryPricing.fromJson(Map<String, dynamic> json) {
    return DeliveryPricing(
      baseCost: (json['base_cost'] as num?)?.toDouble() ?? 2.00,
      freeShippingThreshold:
          (json['free_shipping_threshold'] as num?)?.toDouble() ?? 20.00,
      estimatedTime: json['estimated_time'] as String? ?? '1-2 días hábiles',
    );
  }

  double calculateCost(double orderTotal) {
    if (orderTotal >= freeShippingThreshold) {
      return 0.0;
    }
    return baseCost;
  }

  factory DeliveryPricing.defaults() {
    return const DeliveryPricing();
  }
}