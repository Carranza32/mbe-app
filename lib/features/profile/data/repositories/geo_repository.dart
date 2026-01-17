import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../models/geo_model.dart';

/// Provider del repositorio de geo
final geoRepositoryProvider = Provider<GeoRepository>((ref) {
  return GeoRepository(ref.read(apiServiceProvider));
});

class GeoRepository {
  final ApiService _apiService;

  GeoRepository(this._apiService);

  /// Obtener departamentos/regiones (ADM1) por país
  Future<List<GeoOption>> getAdm1(String countryCode) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint: ApiEndpoints.getAdm1(countryCode),
      fromJson: (json) => json as Map<String, dynamic>,
    );
    
    // Extraer el campo 'results' de la respuesta
    final results = response['results'] as List<dynamic>? ?? [];
    return results
        .map((item) => GeoOption.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Obtener municipios/ciudades (ADM2) por país y departamento
  Future<List<GeoOption>> getAdm2(String countryCode, String regionCode) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint: ApiEndpoints.getAdm2(countryCode, regionCode),
      fromJson: (json) => json as Map<String, dynamic>,
    );
    
    // Extraer el campo 'results' de la respuesta
    final results = response['results'] as List<dynamic>? ?? [];
    return results
        .map((item) => GeoOption.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Obtener distritos/subzonas (ADM3) por país, departamento y municipio
  Future<List<GeoOption>> getAdm3(
    String countryCode,
    String regionCode,
    String cityCode,
  ) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint: ApiEndpoints.getAdm3(countryCode, regionCode, cityCode),
      fromJson: (json) => json as Map<String, dynamic>,
    );
    
    // Extraer el campo 'results' de la respuesta
    final results = response['results'] as List<dynamic>? ?? [];
    return results
        .map((item) => GeoOption.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

