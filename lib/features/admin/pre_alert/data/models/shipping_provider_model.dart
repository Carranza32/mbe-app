class ShippingProviderModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? website;
  final String? trackingUrlTemplate;
  final bool isActive;
  final int order;

  ShippingProviderModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.website,
    this.trackingUrlTemplate,
    required this.isActive,
    required this.order,
  });

  factory ShippingProviderModel.fromJson(Map<String, dynamic> json) {
    return ShippingProviderModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      website: json['website'] as String?,
      trackingUrlTemplate: json['tracking_url_template'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'website': website,
      'tracking_url_template': trackingUrlTemplate,
      'is_active': isActive,
      'order': order,
    };
  }
}

