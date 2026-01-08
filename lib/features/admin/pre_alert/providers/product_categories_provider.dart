import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/api_service.dart';
import '../data/models/product_category_model.dart';

part 'product_categories_provider.g.dart';

@riverpod
Future<List<ProductCategory>> productCategories(
  Ref ref, {
  String? search,
  int perPage = 50,
}) async {
  final apiService = ref.read(apiServiceProvider);
  
  try {
    final queryParams = <String, dynamic>{
      'per_page': perPage,
    };
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await apiService.get<List<ProductCategory>>(
      endpoint: ApiEndpoints.productCategories,
      queryParameters: queryParams,
      fromJson: (json) {
        if (json == null) return [];
        
        // Manejar formato: { "status": true, "data": { "data": [...] } }
        if (json is Map<String, dynamic>) {
          if (json.containsKey('data')) {
            final data = json['data'];
            if (data is Map && data.containsKey('data')) {
              // Formato paginado: data.data
              final items = data['data'] as List;
              return items
                  .map((item) => ProductCategory.fromJson(item as Map<String, dynamic>))
                  .toList();
            } else if (data is List) {
              // Formato directo: data es una lista
              return data
                  .map((item) => ProductCategory.fromJson(item as Map<String, dynamic>))
                  .toList();
            }
          }
        }
        
        if (json is List) {
          return json
              .map((item) => ProductCategory.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        
        return [];
      },
    );
    return response;
  } catch (e) {
    // Si la API falla, retornar lista vacía
    return [];
  }
}

List<ProductCategory> _getStaticCategories() {
  return [
    ProductCategory(id: 1, name: 'Articulos Tecnologicos y Mecanicos'),
    ProductCategory(id: 2, name: 'Sombreros'),
    ProductCategory(id: 3, name: 'CD'),
    ProductCategory(id: 4, name: 'Consolas de Juego'),
    ProductCategory(id: 5, name: 'Ropa'),
    ProductCategory(id: 6, name: 'Electrónicos'),
    ProductCategory(id: 7, name: 'Hogar y Jardín'),
    ProductCategory(id: 8, name: 'Deportes'),
    ProductCategory(id: 9, name: 'Juguetes'),
    ProductCategory(id: 10, name: 'Libros'),
  ];
}

