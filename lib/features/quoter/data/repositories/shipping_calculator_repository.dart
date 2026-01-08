import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../models/shipping_calculation_model.dart';

part 'shipping_calculator_repository.g.dart';

@riverpod
ShippingCalculatorRepository shippingCalculatorRepository(Ref ref) {
  return ShippingCalculatorRepository(ref.read(apiServiceProvider));
}

class ShippingCalculatorRepository {
  final ApiService _apiService;

  ShippingCalculatorRepository(this._apiService);

  Future<ShippingCalculationResponse> calculate({
    required double weight,
    required double value,
    required int productCategoryId,
    int? storeId,
    int? customerId,
    String? countryCode,
  }) async {
    final data = <String, dynamic>{
      'weight': weight,
      'value': value,
      'product_category_id': productCategoryId,
    };

    if (storeId != null) {
      data['store_id'] = storeId;
    }
    if (customerId != null) {
      data['customer_id'] = customerId;
    }
    if (countryCode != null && countryCode.isNotEmpty) {
      data['country_code'] = countryCode;
    }

    return await _apiService.post<ShippingCalculationResponse>(
      endpoint: ApiEndpoints.shippingCalculator,
      data: data,
      fromJson: (json) {
        if (json == null) {
          throw Exception('Respuesta vacía del servidor');
        }

        // La respuesta tiene formato: {status: true, message: "...", data: {...}}
        // El ApiService ya extrae el 'data', así que json debería ser directamente el objeto
        if (json is Map<String, dynamic>) {
          return ShippingCalculationResponse.fromJson(json);
        }

        throw Exception('Formato de respuesta inesperado');
      },
    );
  }
}

