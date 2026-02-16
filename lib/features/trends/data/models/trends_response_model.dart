import 'trend_product_model.dart';

/// Respuesta de GET /trends: hero_product + trending_by_category.
class TrendsData {
  final TrendProduct? heroProduct;
  final Map<String, List<TrendProduct>> trendingByCategory;

  const TrendsData({
    this.heroProduct,
    this.trendingByCategory = const {},
  });

  factory TrendsData.fromJson(Map<String, dynamic> json) {
    TrendProduct? hero;
    if (json['hero_product'] != null) {
      hero = TrendProduct.fromJson(
        json['hero_product'] as Map<String, dynamic>,
      );
    }

    final Map<String, List<TrendProduct>> byCategory = {};
    final raw = json['trending_by_category'];
    if (raw is Map<String, dynamic>) {
      for (final entry in raw.entries) {
        final list = entry.value;
        if (list is List) {
          byCategory[entry.key] = list
              .map((e) => TrendProduct.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    }

    return TrendsData(
      heroProduct: hero,
      trendingByCategory: byCategory,
    );
  }
}
