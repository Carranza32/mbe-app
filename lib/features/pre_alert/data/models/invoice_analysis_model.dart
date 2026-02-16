/// Producto extraído por IA del análisis de factura
class ExtractedProduct {
  final String? description;
  final int quantity;
  final double? price;
  final String? soldBy;
  final int productCategoryId;
  final String? productOther;

  const ExtractedProduct({
    this.description,
    required this.quantity,
    this.price,
    this.soldBy,
    required this.productCategoryId,
    this.productOther,
  });

  factory ExtractedProduct.fromJson(Map<String, dynamic> json) {
    return ExtractedProduct(
      description: json['description'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      price: (json['price'] as num?)?.toDouble(),
      soldBy: json['sold_by'] as String?,
      productCategoryId: json['product_category_id'] as int? ?? 0,
      productOther: json['product_other'] as String?,
    );
  }
}

/// Datos extraídos por la IA del documento (para rellenar formulario)
class ExtractedInvoice {
  /// Número de orden / factura (order_number o invoice_number en API)
  final String? orderNumber;
  final String? invoiceNumber;
  final String? providerName;
  final String? recipientName;
  final String? addressLine1;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final double? productsSubtotal;
  final double? shippingCost;
  final double? total;
  final int? productCount;
  final List<ExtractedProduct> products;

  const ExtractedInvoice({
    this.orderNumber,
    this.invoiceNumber,
    this.providerName,
    this.recipientName,
    this.addressLine1,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.productsSubtotal,
    this.shippingCost,
    this.total,
    this.productCount,
    this.products = const [],
  });

  factory ExtractedInvoice.fromJson(Map<String, dynamic> json) {
    final productsList = json['products'] as List<dynamic>? ?? [];
    return ExtractedInvoice(
      orderNumber: json['order_number'] as String?,
      invoiceNumber: json['invoice_number'] as String?,
      providerName: json['provider_name'] as String?,
      recipientName: json['recipient_name'] as String?,
      addressLine1: json['address_line1'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String?,
      productsSubtotal: (json['products_subtotal'] as num?)?.toDouble(),
      shippingCost: (json['shipping_cost'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble(),
      productCount: json['product_count'] as int?,
      products: productsList
          .map((e) => ExtractedProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Respuesta del endpoint POST /pre-alerts/analyze-invoice
class InvoiceAnalysisResult {
  final ExtractedInvoice extracted;
  final int? elapsedMs;

  const InvoiceAnalysisResult({
    required this.extracted,
    this.elapsedMs,
  });

  factory InvoiceAnalysisResult.fromJson(Map<String, dynamic> json) {
    final extractedJson = json['extracted'] as Map<String, dynamic>?;
    return InvoiceAnalysisResult(
      extracted: extractedJson != null
          ? ExtractedInvoice.fromJson(extractedJson)
          : const ExtractedInvoice(),
      elapsedMs: json['elapsed_ms'] as int?,
    );
  }
}
