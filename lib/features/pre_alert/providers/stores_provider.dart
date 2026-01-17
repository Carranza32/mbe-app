import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../data/models/store_model.dart';
import '../data/models/create_pre_alert_request.dart';

part 'stores_provider.g.dart';

/// Provider para obtener las tiendas disponibles para el cliente
@riverpod
Future<List<StoreModel>> customerStores(Ref ref) async {
  final apiService = ref.read(apiServiceProvider);

  try {
    final stores = await apiService.get<List<StoreModel>>(
      endpoint: ApiEndpoints.stores,
      fromJson: (json) {
        if (json == null) return [];

        // Manejar formato: { "status": true, "data": [...] }
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
  } catch (e) {
    print('Error al cargar tiendas: $e');
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
