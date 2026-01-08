import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../models/pre_alert_model.dart';
import '../models/create_pre_alert_request.dart';

part 'pre_alerts_repository.g.dart';

@riverpod
PreAlertsRepository preAlertsRepository(Ref ref) {
  return PreAlertsRepository(ref.read(apiServiceProvider));
}

class PreAlertsRepository {
  final ApiService _apiService;

  PreAlertsRepository(this._apiService);

  Future<PreAlertsResponse> getPreAlerts({
    int? page,
    int? perPage,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (perPage != null) queryParams['per_page'] = perPage;

    return await _apiService.get<PreAlertsResponse>(
      endpoint: ApiEndpoints.preAlerts,
      queryParameters: queryParams.isEmpty ? null : queryParams,
      fromJson: (json) => PreAlertsResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<PreAlert> createPreAlert({
    required CreatePreAlertRequest request,
    File? invoiceFile,
  }) async {
    final data = request.toJson();
    
    // Mapear los campos según lo esperado por el backend
    // El backend espera: track_number, locker_code, provider_id, total, product_count, products
    final formData = <String, dynamic>{
      'track_number': data['track_number'],
      'locker_code': data['locker_code'],
      'provider_id': data['provider_id'],
      'total': data['total'],
      'product_count': data['product_count'],
      'products': data['products'], // Array de productos
    };

    // Preparar archivos si existe
    final files = <String, String>{};
    if (invoiceFile != null) {
      files['invoice'] = invoiceFile.path;
    }

    // Si hay archivos, usar uploadFiles, sino usar post normal
    if (files.isNotEmpty) {
      return await _apiService.uploadFiles<PreAlert>(
        endpoint: ApiEndpoints.createPreAlert,
        files: files,
        data: formData,
        fromJson: (json) {
          if (json == null) {
            throw Exception('Respuesta vacía del servidor');
          }
          
          // La respuesta tiene formato: {status: true, message: "...", data: {...}}
          // El ApiService ya extrae el 'data', así que json debería ser directamente el objeto PreAlert
          if (json is Map<String, dynamic>) {
            return PreAlert.fromJson(json);
          }
          
          throw Exception('Formato de respuesta inesperado');
        },
      );
    } else {
      return await _apiService.post<PreAlert>(
        endpoint: ApiEndpoints.createPreAlert,
        data: formData,
        fromJson: (json) {
          if (json == null) {
            throw Exception('Respuesta vacía del servidor');
          }
          
          if (json is Map<String, dynamic>) {
            return PreAlert.fromJson(json);
          }
          
          throw Exception('Formato de respuesta inesperado');
        },
      );
    }
  }
}

