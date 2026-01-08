import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/api_service.dart';
import '../data/models/shipping_provider_model.dart';

part 'shipping_providers_provider.g.dart';

@riverpod
Future<List<ShippingProviderModel>> shippingProviders(Ref ref) async {
  final apiService = ref.read(apiServiceProvider);

  try {
    final response = await apiService.get<List<ShippingProviderModel>>(
      endpoint: ApiEndpoints.shippingProviders,
      fromJson: (json) {
        if (json == null) return [];

        // Manejar formato: { "status": true, "message": "...", "data": [...] }
        if (json is Map<String, dynamic>) {
          if (json.containsKey('data')) {
            final data = json['data'];
            if (data is List) {
              // Formato directo: data es una lista
              return data
                  .map((item) =>
                      ShippingProviderModel.fromJson(item as Map<String, dynamic>))
                  .toList();
            }
          }
        }

        if (json is List) {
          return json
              .map((item) =>
                  ShippingProviderModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }

        return [];
      },
    );

    // Filtrar solo los proveedores activos y ordenarlos
    return response
        .where((provider) => provider.isActive)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  } catch (e) {
    // Si la API falla, retornar lista vacía
    print('Error al cargar proveedores de envío: $e');
    return [];
  }
}

