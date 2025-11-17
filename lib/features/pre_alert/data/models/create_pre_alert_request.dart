// lib/features/pre_alert/data/models/create_pre_alert_request.dart

class CreatePreAlertRequest {
  final String trackingNumber;
  final String mailboxNumber;
  final String storeId;
  final double totalValue;
  final List<PreAlertProduct> products;
  final String? invoiceFilePath;

  CreatePreAlertRequest({
    required this.trackingNumber,
    required this.mailboxNumber,
    required this.storeId,
    required this.totalValue,
    required this.products,
    this.invoiceFilePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'tracking_number': trackingNumber,
      'mailbox_number': mailboxNumber,
      'store_id': storeId,
      'total_value': totalValue.toString(),
      'products': products.map((p) => p.toJson()).toList(),
    };
  }

  CreatePreAlertRequest copyWith({
    String? trackingNumber,
    String? mailboxNumber,
    String? storeId,
    double? totalValue,
    List<PreAlertProduct>? products,
    String? invoiceFilePath,
  }) {
    return CreatePreAlertRequest(
      trackingNumber: trackingNumber ?? this.trackingNumber,
      mailboxNumber: mailboxNumber ?? this.mailboxNumber,
      storeId: storeId ?? this.storeId,
      totalValue: totalValue ?? this.totalValue,
      products: products ?? this.products,
      invoiceFilePath: invoiceFilePath ?? this.invoiceFilePath,
    );
  }
}

class PreAlertProduct {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  PreAlertProduct({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price.toString(),
    };
  }

  PreAlertProduct copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? price,
  }) {
    return PreAlertProduct(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  double get subtotal => quantity * price;
}

class Store {
  final String id;
  final String name;

  Store({
    required this.id,
    required this.name,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'].toString(),
      name: json['name'] as String,
    );
  }
}
