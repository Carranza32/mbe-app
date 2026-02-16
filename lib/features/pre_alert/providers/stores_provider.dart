import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../data/models/store_model.dart';
import '../data/models/create_pre_alert_request.dart';

part 'stores_provider.g.dart';

/// Provider para obtener las tiendas MBE (para recoger paquetes)
/// Usa el endpoint GET /api/v1/stores
@riverpod
Future<List<StoreModel>> mbeStores(Ref ref) async {
  final apiService = ref.read(apiServiceProvider);

  try {
    print('🔍 Iniciando carga de tiendas MBE desde ${ApiEndpoints.stores}');
    
    // ApiService ya extrae automáticamente el campo 'data' de la respuesta
    // Entonces 'response' ya contiene { stores: [...], suggested_store_id: 1 }
    final response = await apiService.get<Map<String, dynamic>>(
      endpoint: ApiEndpoints.stores,
      fromJson: (json) {
        print('📦 fromJson recibió: ${json.runtimeType}');
        if (json is Map) {
          print('📦 Keys en json: ${json.keys.toList()}');
        }
        return json as Map<String, dynamic>;
      },
    );

    print('📦 Respuesta completa: $response');
    print('📦 Tipo de respuesta: ${response.runtimeType}');
    print('📦 Keys en response: ${response.keys.toList()}');

    // La respuesta original tiene esta estructura:
    // {
    //   "status": true,
    //   "message": "Tiendas obtenidas correctamente",
    //   "data": {
    //     "stores": [...],
    //     "suggested_store_id": 1
    //   }
    // }
    // ApiService extrae 'data', así que 'response' debería ser:
    // {
    //   "stores": [...],
    //   "suggested_store_id": 1
    // }
    
    // Buscar 'stores' en diferentes niveles posibles
    dynamic storesList;
    
    // Primero intentar directamente en response
    if (response.containsKey('stores')) {
      storesList = response['stores'];
      print('✅ Encontrado "stores" directamente en response');
    }
    // Si no está, buscar en response['data']['stores'] (por si ApiService no extrajo)
    else if (response.containsKey('data')) {
      final data = response['data'];
      print('📦 Encontrado campo "data" en response: ${data.runtimeType}');
      if (data is Map<String, dynamic> && data.containsKey('stores')) {
        storesList = data['stores'];
        print('✅ Encontrado "stores" en response["data"]');
      }
    }
    
    if (storesList == null) {
      print('❌ No se encontró "stores" en ningún nivel');
      print('📦 Estructura completa de response:');
      response.forEach((key, value) {
        print('   - $key: ${value.runtimeType}');
        if (value is Map) {
          print('     Keys: ${(value as Map).keys.toList()}');
        }
      });
      return [];
    }
    
    print('📦 storesList encontrado: ${storesList.runtimeType}');
    if (storesList is List) {
      print('✅ storesList es una List con ${storesList.length} items');
    } else {
      print('❌ storesList NO es una List');
      return [];
    }
    
    if (storesList == null) {
      print('❌ storesList es null después de buscar');
      return [];
    }
    
    if (storesList is! List) {
      print('❌ storesList no es una List, es: ${storesList.runtimeType}');
      return [];
    }
    
    if (storesList.isEmpty) {
      print('⚠️ storesList está vacía');
      return [];
    }

    print('🔄 Parseando ${storesList.length} tiendas...');
    final stores = storesList
        .map((storeJson) {
          try {
            if (storeJson is! Map<String, dynamic>) {
              print('⚠️ storeJson no es Map: ${storeJson.runtimeType}');
              return null;
            }
            final store = StoreModel.fromJson(storeJson);
            print('✅ Tienda parseada: ${store.name} (id: ${store.id})');
            return store;
          } catch (e, stackTrace) {
            print('❌ Error al parsear tienda: $e');
            print('Datos de la tienda: $storeJson');
            print('Stack trace: $stackTrace');
            return null;
          }
        })
        .whereType<StoreModel>()
        .toList();

    print('✅ Tiendas MBE cargadas exitosamente: ${stores.length}');
    return stores;
  } catch (e, stackTrace) {
    print('❌ Error al obtener tiendas MBE: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}

/// Provider para obtener los proveedores (tiendas) disponibles para el cliente
/// Usa el endpoint GET /api/v1/providers
/// Por defecto solo devuelve proveedores activos, ordenados por order y luego por name
@riverpod
Future<List<StoreModel>> customerStores(Ref ref) async {
  final apiService = ref.read(apiServiceProvider);

  try {
    // Construir parámetros de consulta
    // Por defecto el endpoint filtra solo activos y ordena por order y luego por name
    final queryParams = <String, dynamic>{
      'per_page': 100, // Obtener más resultados para evitar paginación
      'include_inactive':
          false, // Solo activos por defecto (aunque el endpoint ya lo hace por defecto)
    };

    final stores = await apiService.get<List<StoreModel>>(
      endpoint: ApiEndpoints.providers,
      queryParameters: queryParams,
      fromJson: (json) {
        if (json == null) return [];

        // Manejar formato paginado: { "status": true, "data": { "data": [...] } }
        if (json is Map<String, dynamic>) {
          if (json.containsKey('data')) {
            final data = json['data'];
            if (data is Map && data.containsKey('data')) {
              // Formato paginado: data.data
              final items = data['data'] as List? ?? [];
              return items
                  .map(
                    (item) => StoreModel.fromJson(item as Map<String, dynamic>),
                  )
                  .toList();
            } else if (data is List) {
              // Formato directo: data es una lista
              return data
                  .map(
                    (item) => StoreModel.fromJson(item as Map<String, dynamic>),
                  )
                  .toList();
            }
          }
        }

        if (json is List) {
          return json
              .map((item) => StoreModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }

        return [];
      },
    );

    return stores;
  } catch (e, stackTrace) {
    // Error al cargar proveedores - log para depuración
    print('Error al cargar proveedores desde /providers: $e');
    print('Stack trace: $stackTrace');
    return [];
  }
}

/// Provider que convierte StoreModel a Store para el dropdown
@riverpod
Future<List<Store>> allStores(Ref ref) async {
  final storeModels = await ref.watch(customerStoresProvider.future);
  return storeModels
      .map((model) => Store(id: model.id.toString(), name: model.name))
      .toList();
}
