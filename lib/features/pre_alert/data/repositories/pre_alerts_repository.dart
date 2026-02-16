import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../models/pre_alert_model.dart';
import '../models/create_pre_alert_request.dart';
import '../models/promotion_model.dart';
import '../models/invoice_analysis_model.dart';
import '../models/pre_alert_detail_model.dart';
import 'dart:convert';

part 'pre_alerts_repository.g.dart';

@riverpod
PreAlertsRepository preAlertsRepository(Ref ref) {
  return PreAlertsRepository(ref.read(apiServiceProvider));
}

class PreAlertsRepository {
  final ApiService _apiService;

  PreAlertsRepository(this._apiService);

  /// Analizar factura/PDF con IA (Gemini). Requiere autenticación.
  /// El archivo es el mismo que se puede adjuntar al crear la pre-alerta.
  Future<InvoiceAnalysisResult> analyzeInvoice(
    File file, {
    List<Map<String, dynamic>>? productCategories,
  }) async {
    final files = <String, String>{'file': file.path};
    final data = <String, dynamic>{};
    if (productCategories != null && productCategories.isNotEmpty) {
      data['product_categories'] = jsonEncode(productCategories);
    }
    // El análisis con IA (Gemini) puede tardar 15-60+ segundos
    return _apiService.uploadFiles<InvoiceAnalysisResult>(
      endpoint: ApiEndpoints.analyzeInvoice,
      files: files,
      data: data.isEmpty ? null : data,
      fromJson: (json) =>
          InvoiceAnalysisResult.fromJson(json as Map<String, dynamic>),
      receiveTimeout: const Duration(seconds: 120),
      sendTimeout: const Duration(seconds: 60),
    );
  }

  Future<PreAlertsResponse> getPreAlerts({int? page, int? perPage}) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (perPage != null) queryParams['per_page'] = perPage;

    return await _apiService.get<PreAlertsResponse>(
      endpoint: ApiEndpoints.preAlerts,
      queryParameters: queryParams.isEmpty ? null : queryParams,
      fromJson: (json) =>
          PreAlertsResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Detalle de una pre-alerta (cliente). GET /pre-alerts/{id}
  Future<PreAlertDetail> getPreAlertDetail(String id) async {
    return _apiService.get<PreAlertDetail>(
      endpoint: ApiEndpoints.preAlertById(id),
      fromJson: (json) {
        final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
        return PreAlertDetail.fromJson(map);
      },
    );
  }

  Future<PreAlert> createPreAlert({
    required CreatePreAlertRequest request,
    File? invoiceFile,
  }) async {
    final data = request.toJson();

    final files = <String, String>{};
    if (invoiceFile != null) {
      // OJO: En tu validación de Laravel pusiste 'bill', aquí decía 'invoice'.
      // Debe coincidir con el backend.
      files['bill'] = invoiceFile.path;
    }

    // SI HAY ARCHIVOS (Multipart/FormData)
    if (files.isNotEmpty) {
      // 2. CORRECCIÓN: Convertir Arrays/Mapas a String JSON manualmente
      final formData = <String, dynamic>{
        'invoice_number': data['invoice_number'],
        'track_number': null,
        'locker_code': data['locker_code'],
        'provider_id': data['provider_id'],
        'total': data['total'],
        'product_count': data['product_count'],

        // AQUÍ ESTA LA MAGIA: jsonEncode convierte la lista a String "[{...}]"
        'products': jsonEncode(data['products']),

        // Hacemos lo mismo con otros objetos complejos si existen
        if (data['delivery'] != null) 'delivery': jsonEncode(data['delivery']),

        if (data['contact'] != null) 'contact': jsonEncode(data['contact']),

        // Si hay campos simples (strings/ints) extra, agrégalos normal
        if (data['provider_other'] != null)
          'provider_other': data['provider_other'],
      };

      return await _apiService.uploadFiles<PreAlert>(
        endpoint: ApiEndpoints.createPreAlert,
        files: files,
        data: formData,
        fromJson: (json) {
          // ... tu lógica de parsing existente ...
          if (json == null) throw Exception('Respuesta vacía');
          // Asegúrate de acceder a 'data' si tu backend envuelve la respuesta
          final responseData =
              json is Map<String, dynamic> && json.containsKey('data')
              ? json['data']
              : json;
          return PreAlert.fromJson(responseData);
        },
      );
    }
    // SI NO HAY ARCHIVOS (JSON Normal)
    else {
      // 3. Cuando es JSON normal, NO usas jsonEncode, envías el mapa nativo
      // Laravel entiende arrays nativos si el Content-Type es application/json
      return await _apiService.post<PreAlert>(
        endpoint: ApiEndpoints.createPreAlert,
        data: data, // Aquí mandamos el objeto directo, Dio lo serializa solo
        fromJson: (json) {
          if (json == null) throw Exception('Respuesta vacía');
          final responseData =
              json is Map<String, dynamic> && json.containsKey('data')
              ? json['data']
              : json;
          return PreAlert.fromJson(responseData);
        },
      );
    }
  }

  /// Completar información de pre-alerta
  Future<PreAlert> completePreAlertInfo({
    required String preAlertId,
    required Map<String, dynamic> data,
  }) async {
    return await _apiService.put<PreAlert>(
      endpoint: ApiEndpoints.completePreAlertInfo(preAlertId),
      data: data,
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

  /// Obtener la mejor promoción disponible
  /// Retorna null si no hay promoción (404 es esperado)
  Future<BestPromotionResponse?> getBestPromotion({
    required BestPromotionRequest request,
  }) async {
    try {
      return await _apiService.post<BestPromotionResponse>(
        endpoint: ApiEndpoints.bestPromotion,
        data: request.toJson(),
        fromJson: (json) {
          if (json == null) {
            return BestPromotionResponse(success: false, data: null);
          }

          if (json is Map<String, dynamic>) {
            // El ApiService ya extrae el campo "data" de la respuesta, así que
            // json aquí es el objeto de promoción directo (id, name, discount_type, etc.)
            if (json.containsKey('data') && json['data'] != null) {
              return BestPromotionResponse.fromJson(json);
            }
            return BestPromotionResponse(
              success: true,
              data: PromotionModel.fromJson(json),
            );
          }

          return BestPromotionResponse(success: false, data: null);
        },
      );
    } catch (e) {
      // 404 es esperado cuando no hay promoción, retornar null
      final errorMessage = e.toString();
      if (errorMessage.contains('404') ||
          errorMessage.contains('no encontrado') ||
          errorMessage.contains('not found')) {
        return BestPromotionResponse(success: false, data: null);
      }
      // Para otros errores, relanzar la excepción
      rethrow;
    }
  }
}
