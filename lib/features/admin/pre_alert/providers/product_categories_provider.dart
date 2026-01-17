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

// Provider que carga TODOS los productos de una vez y los mantiene en memoria
// Se usa para optimizar el dropdown, cargando todo al inicio y filtrando localmente
// keepAlive: true mantiene los datos en memoria incluso cuando no hay listeners
@Riverpod(keepAlive: true)
class AllProductCategories extends _$AllProductCategories {
  @override
  Future<List<ProductCategory>> build() async {
    final apiService = ref.read(apiServiceProvider);
    
    try {
      final allCategories = <ProductCategory>[];
      int currentPage = 1;
      int lastPage = 1;
      bool hasMore = true;

      // Cargar todas las páginas
      while (hasMore) {
        final queryParams = <String, dynamic>{
          'page': currentPage,
          'per_page': 100, // Cargar 100 por página
        };

        final response = await apiService.get<dynamic>(
          endpoint: ApiEndpoints.productCategories,
          queryParameters: queryParams,
          fromJson: (json) => json, // Devolver el JSON tal cual para procesarlo manualmente
        );

        // Procesar la respuesta que puede venir en diferentes formatos
        List<ProductCategory> pageCategories = [];
        Map<String, dynamic>? paginationInfo;

        if (response is Map<String, dynamic>) {
          // Formato paginado: { "data": [...], "current_page": 1, "last_page": 1, ... }
          if (response.containsKey('data') && response['data'] is List) {
            final items = response['data'] as List;
            pageCategories = items
                .map((item) {
                  try {
                    return ProductCategory.fromJson(item as Map<String, dynamic>);
                  } catch (e) {
                    print('Error parseando categoría: $e');
                    return null;
                  }
                })
                .whereType<ProductCategory>()
                .toList();
            paginationInfo = response;
          } else {
            // Puede ser que data sea un objeto con data anidado
            paginationInfo = response;
          }
        } else if (response is List) {
          // Formato directo: lista de categorías sin paginación
          pageCategories = response
              .map((item) {
                try {
                  return ProductCategory.fromJson(item as Map<String, dynamic>);
                } catch (e) {
                  print('Error parseando categoría: $e');
                  return null;
                }
              })
              .whereType<ProductCategory>()
              .toList();
          // Si es lista directa, no hay más páginas
          hasMore = false;
        }

        allCategories.addAll(pageCategories);

        // Verificar si hay más páginas
        if (paginationInfo != null) {
          currentPage = paginationInfo['current_page'] as int? ?? 1;
          lastPage = paginationInfo['last_page'] as int? ?? 1;
          hasMore = currentPage < lastPage;
        } else {
          hasMore = false;
        }
        
        if (hasMore) {
          currentPage++;
        }
      }

      print('✅ Cargadas ${allCategories.length} categorías de productos');
      return allCategories;
    } catch (e, stackTrace) {
      // Si la API falla, retornar lista vacía
      print('❌ Error cargando todas las categorías: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  // Método para refrescar los datos
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

