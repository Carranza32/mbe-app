/// Modelo de un producto en tendencia (hero o por categoría).
class TrendProduct {
  final int id;
  final String title;
  final String? description;
  final String category;
  final String approxPrice;
  final String? imageUrl;
  final String? purchaseLink;
  final String? badge;
  final String? storeSource;
  final String? syncedAt;

  const TrendProduct({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.approxPrice,
    this.imageUrl,
    this.purchaseLink,
    this.badge,
    this.storeSource,
    this.syncedAt,
  });

  factory TrendProduct.fromJson(Map<String, dynamic> json) {
    return TrendProduct(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      category: json['category'] as String? ?? '',
      approxPrice: json['approx_price'] as String? ?? '0',
      imageUrl: json['image_url'] as String?,
      purchaseLink: json['purchase_link'] as String?,
      badge: json['badge'] as String?,
      storeSource: json['store_source'] as String?,
      syncedAt: json['synced_at'] as String?,
    );
  }

  bool get isHot => badge?.toLowerCase() == 'hot';
}
