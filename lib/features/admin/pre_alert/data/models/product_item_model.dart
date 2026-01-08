class ProductItem {
  final int? productCategoryId;
  final String? productCategoryName;
  final int quantity;
  final double price;
  final String? description;
  final double? weight; // Peso del producto
  final String? weightType; // Tipo de peso: "LB", "KG", etc.

  ProductItem({
    this.productCategoryId,
    this.productCategoryName,
    required this.quantity,
    required this.price,
    this.description,
    this.weight,
    this.weightType,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed;
      }
      return null;
    }

    return ProductItem(
      productCategoryId: json['product_category_id'] as int?,
      productCategoryName: json['product_category_name'] as String?,
      quantity: json['quantity'] as int? ?? 0,
      // El precio puede venir como string o número
      price: parseDouble(json['price']) ?? 0.0,
      // El API usa 'product_description' no 'description'
      description: json['product_description'] as String? ?? json['description'] as String?,
      // El API usa 'product_weight' no 'weight'
      weight: parseDouble(json['product_weight'] ?? json['weight']),
      // El weight_type no viene en el producto individual, solo en el paquete
      weightType: json['weight_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (productCategoryId != null) 'product_category_id': productCategoryId,
      'quantity': quantity,
      'price': price,
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (weight != null) 'weight': weight,
      if (weightType != null) 'weight_type': weightType,
    };
  }

  ProductItem copyWith({
    int? productCategoryId,
    String? productCategoryName,
    int? quantity,
    double? price,
    String? description,
    double? weight,
    String? weightType,
  }) {
    return ProductItem(
      productCategoryId: productCategoryId ?? this.productCategoryId,
      productCategoryName: productCategoryName ?? this.productCategoryName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      description: description ?? this.description,
      weight: weight ?? this.weight,
      weightType: weightType ?? this.weightType,
    );
  }
}

