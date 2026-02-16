import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/api_service.dart';
import '../models/admin_pre_alert_model.dart';
import '../models/package_status.dart';
import '../models/paginated_response.dart';
import '../models/reception_result.dart';
import '../models/status_history_model.dart';
import '../models/warehouse_location_model.dart';
import '../models/admin_kpis_model.dart';
import '../models/customer_pending_counts_model.dart';

part 'admin_pre_alerts_repository.g.dart';

@riverpod
AdminPreAlertsRepository adminPreAlertsRepository(Ref ref) {
  return AdminPreAlertsRepository(ref.read(apiServiceProvider));
}

class AdminPreAlertsRepository {
  final ApiService _apiService;

  AdminPreAlertsRepository(this._apiService);

  Future<PaginatedPreAlertsResponse> getPreAlerts({
    String?
    statusFilter, // 'por_recibir', 'en_bodega', 'para_entregar', o estado específico
    int? storeId,
    String? from,
    String? to,
    int perPage = 15,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{'per_page': perPage, 'page': page};
    if (statusFilter != null) queryParams['status'] = statusFilter;
    if (storeId != null) queryParams['store_id'] = storeId;
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;

    return await _apiService.get<PaginatedPreAlertsResponse>(
      endpoint: ApiEndpoints.adminPreAlerts,
      queryParameters: queryParams,
      fromJson: (json) {
        if (json == null) {
          return PaginatedPreAlertsResponse(
            data: [],
            currentPage: 1,
            lastPage: 1,
            total: 0,
            perPage: 15,
          );
        }

        if (json is Map<String, dynamic>) {
          // El ApiService ya extrae el 'data' de la respuesta si existe
          // Entonces aquí json debería ser directamente el objeto de paginación
          // {current_page: 1, data: [...], last_page: X, total: Y, per_page: Z}
          return PaginatedPreAlertsResponse.fromJson(json);
        }

        return PaginatedPreAlertsResponse(
          data: [],
          currentPage: 1,
          lastPage: 1,
          total: 0,
          perPage: 15,
        );
      },
    );
  }

  Future<AdminPreAlert> updateStatus({
    required String id,
    required PackageStatus status,
  }) async {
    return await _apiService.patch<AdminPreAlert>(
      endpoint: ApiEndpoints.updatePreAlertStatus(id),
      data: {'status': status.key, 'status_id': status.statusId},
      fromJson: (json) => AdminPreAlert.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<List<AdminPreAlert>> bulkUpdateStatus({
    required List<String> ids,
    required PackageStatus status,
  }) async {
    return await _apiService.patch<List<AdminPreAlert>>(
      endpoint: ApiEndpoints.bulkUpdatePreAlertStatus,
      data: {'ids': ids, 'status': status.key, 'status_id': status.statusId},
      fromJson: (json) {
        if (json is List) {
          return json
              .map(
                (item) => AdminPreAlert.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        if (json is Map && json.containsKey('data')) {
          final data = json['data'] as List;
          return data
              .map(
                (item) => AdminPreAlert.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return [];
      },
    );
  }

  /// Obtener pre-alerta por ID (para edición)
  Future<AdminPreAlert> getPreAlertById(String id) async {
    return await _apiService.get<AdminPreAlert>(
      endpoint: ApiEndpoints.getPreAlertById(id),
      fromJson: (json) {
        if (json == null) throw Exception('Paquete no encontrado');
        if (json is Map<String, dynamic>) {
          // Si viene envuelto en 'data', extraerlo
          if (json.containsKey('data')) {
            return AdminPreAlert.fromJson(json['data'] as Map<String, dynamic>);
          }
          return AdminPreAlert.fromJson(json);
        }
        throw Exception('Formato de respuesta inválido');
      },
    );
  }

  /// Obtener información de racks y segmentos de una tienda desde el paquete
  /// Retorna un Map con 'racks_count' y 'segments_per_rack'
  Future<Map<String, int>> getStoreWarehouseInfo(String packageId) async {
    try {
      // Obtener el JSON completo del paquete para extraer info del store
      final packageData = await _apiService.get<Map<String, dynamic>>(
        endpoint: ApiEndpoints.getPreAlertById(packageId),
        fromJson: (json) {
          if (json == null) return <String, dynamic>{};
          if (json is Map<String, dynamic>) {
            // Si viene envuelto en 'data', extraerlo
            if (json.containsKey('data')) {
              return json['data'] as Map<String, dynamic>;
            }
            return json;
          }
          return <String, dynamic>{};
        },
      );

      // Extraer información del store
      final store = packageData['store'];
      if (store is Map<String, dynamic>) {
        final racksCount = store['warehouse_racks_count'] as int? ?? 5;
        final segmentsPerRack = store['warehouse_segments_per_rack'] as int? ?? 10;
        return {
          'racks_count': racksCount,
          'segments_per_rack': segmentsPerRack,
        };
      }

      return {'racks_count': 5, 'segments_per_rack': 10};
    } catch (e) {
      // En caso de error, retornar valores por defecto
      return {'racks_count': 5, 'segments_per_rack': 10};
    }
  }

  /// Obtener ubicaciones disponibles de una tienda.
  /// [warehouseId] opcional: filtrar por bodega (multi-bodega).
  Future<List<WarehouseLocation>> getStoreWarehouseLocations({
    required int storeId,
    bool availableOnly = false,
    String? rackNumber,
    int? warehouseId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (availableOnly) queryParams['available_only'] = 'true';
    if (rackNumber != null) queryParams['rack_number'] = rackNumber;
    if (warehouseId != null) queryParams['warehouse_id'] = warehouseId;

    return await _apiService.get<List<WarehouseLocation>>(
      endpoint: ApiEndpoints.getStoreWarehouseLocations(storeId),
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) {
        if (json == null) return [];
        if (json is List) {
          return json
              .map((item) =>
                  WarehouseLocation.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        if (json is Map<String, dynamic>) {
          // La API puede devolver la lista en "data" o en "locations"
          final list = json['data'] ?? json['locations'];
          if (list is List) {
            return list
                .map((item) =>
                    WarehouseLocation.fromJson(item as Map<String, dynamic>))
                .toList();
          }
        }
        return [];
      },
    );
  }

  /// Buscar paquete por código ebox
  Future<AdminPreAlert?> findPackageByEbox(String eboxCode) async {
    try {
      final result = await _apiService.get<AdminPreAlert?>(
        endpoint: ApiEndpoints.findPackageByEbox,
        queryParameters: {'ebox_code': eboxCode},
        fromJson: (json) {
          if (json == null) return null;
          if (json is Map<String, dynamic>) {
            // Si viene envuelto en 'data', extraerlo
            if (json.containsKey('data')) {
              return AdminPreAlert.fromJson(
                json['data'] as Map<String, dynamic>,
              );
            }
            return AdminPreAlert.fromJson(json);
          }
          return null;
        },
      );
      return result;
    } catch (e) {
      // Si no se encuentra, retornar null en lugar de lanzar error
      return null;
    }
  }

  /// Procesar recepción de paquetes
  /// Cambia estado a en_tienda y asigna rack automáticamente
  Future<ReceptionResult> processReception({
    required List<String> packageIds,
  }) async {
    return await _apiService.post<ReceptionResult>(
      endpoint: ApiEndpoints.processReception,
      data: {'package_ids': packageIds},
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return ReceptionResult.fromJson(json);
        }
        throw Exception('Invalid response format');
      },
    );
  }

  /// Asignar rack y segmento manualmente a paquetes
  Future<List<AdminPreAlert>> assignRack({
    required List<String> packageIds,
    required String rackNumber,
    required String segmentNumber,
    bool changeToReadyForPickup = false,
  }) async {
    return await _apiService.patch<List<AdminPreAlert>>(
      endpoint: ApiEndpoints.assignRack,
      data: {
        'package_ids': packageIds,
        'rack_number': rackNumber,
        'segment_number': segmentNumber,
        'change_to_ready_for_pickup': changeToReadyForPickup,
      },
      fromJson: (json) {
        if (json is List) {
          return json
              .map(
                (item) => AdminPreAlert.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        if (json is Map && json.containsKey('data')) {
          final data = json['data'] as List;
          return data
              .map(
                (item) => AdminPreAlert.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return [];
      },
    );
  }

  /// Actualizar solo la ubicación de una pre-alerta
  Future<AdminPreAlert> updatePackageLocation({
    required String packageId,
    required String rackNumber,
    required String segmentNumber,
  }) async {
    return await _apiService.patch<AdminPreAlert>(
      endpoint: ApiEndpoints.updateLocation(packageId),
      data: {
        'rack_number': rackNumber,
        'segment_number': segmentNumber,
      },
      fromJson: (json) {
        if (json == null) throw Exception('Respuesta inválida');
        if (json is Map<String, dynamic>) {
          // Si viene envuelto en 'data', extraerlo
          if (json.containsKey('data')) {
            return AdminPreAlert.fromJson(json['data'] as Map<String, dynamic>);
          }
          return AdminPreAlert.fromJson(json);
        }
        throw Exception('Formato de respuesta inválido');
      },
    );
  }

  /// Procesar entrega pickup (cliente retira en tienda).
  /// Soporta múltiples paquetes: [packageIds] puede tener uno o varios IDs.
  Future<List<AdminPreAlert>> processPickupDelivery({
    required List<String> packageIds,
    required String signaturePath, // Base64 (se envía como "signature" al backend)
    required String deliveredTo, // "titular" | nombre del encargado
    required DateTime deliveredAt,
  }) async {
    return await _apiService.post<List<AdminPreAlert>>(
      endpoint: ApiEndpoints.processPickupDelivery,
      data: {
        'package_ids': packageIds,
        'signature': signaturePath, // Backend espera "signature", no "signature_path"
        'delivered_to': deliveredTo,
        'delivered_at': deliveredAt.toIso8601String(),
      },
      fromJson: (json) => _parseProcessDeliveryResponse(json),
    );
  }

  /// Procesar entrega delivery (despacho a domicilio).
  /// Soporta múltiples paquetes: [packageIds] puede tener uno o varios IDs.
  Future<List<AdminPreAlert>> processDeliveryDispatch({
    required List<String> packageIds,
    required int shippingProviderId,
    String? providerTrackingNumber,
  }) async {
    return await _apiService.post<List<AdminPreAlert>>(
      endpoint: ApiEndpoints.processDeliveryDispatch,
      data: {
        'package_ids': packageIds,
        'shipping_provider_id': shippingProviderId,
        if (providerTrackingNumber != null)
          'provider_tracking_number': providerTrackingNumber,
      },
      fromJson: (json) => _parseProcessDeliveryResponse(json),
    );
  }

  /// Parsea la respuesta de process-pickup-delivery y process-delivery-dispatch.
  /// Backend devuelve: { processed_count, failed_count, processed: [...], failed: [] }
  static List<AdminPreAlert> _parseProcessDeliveryResponse(dynamic json) {
    if (json is List) {
      return json
          .map((item) => AdminPreAlert.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    if (json is Map<String, dynamic>) {
      if (json.containsKey('processed') && json['processed'] is List) {
        final list = json['processed'] as List;
        return list
            .map((item) => AdminPreAlert.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      if (json.containsKey('data') && json['data'] is List) {
        final list = json['data'] as List;
        return list
            .map((item) => AdminPreAlert.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  /// Actualizar información de un paquete
  Future<AdminPreAlert> updatePackage({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    return await _apiService.patch<AdminPreAlert>(
      endpoint: ApiEndpoints.updatePreAlert(id),
      data: updates,
      fromJson: (json) => AdminPreAlert.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Subir documento/archivo a un paquete
  Future<AdminPreAlert> uploadDocument({
    required String id,
    required String filePath,
    String? documentType,
  }) async {
    return await _apiService.uploadFiles<AdminPreAlert>(
      endpoint: ApiEndpoints.uploadPreAlertDocument(id),
      files: {'document': filePath},
      data: documentType != null ? {'document_type': documentType} : null,
      fromJson: (json) => AdminPreAlert.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Buscar pre-alertas por múltiples criterios
  /// Busca en: track_number, package_code, locker_code, customer_name, customer.email, provider.name
  /// Usa el endpoint dedicado de búsqueda: /admin/pre-alerts/search
  Future<PaginatedPreAlertsResponse> searchPreAlerts({
    required String query,
    String? statusFilter, // 'por_recibir', 'en_bodega', 'para_entregar', etc.
    int? storeId,
    String? from,
    String? to,
    int perPage = 50,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'q': query.trim(), // El parámetro de búsqueda
      'per_page': perPage,
      'page': page,
    };

    // Agregar filtros opcionales
    if (statusFilter != null) queryParams['status'] = statusFilter;
    if (storeId != null) queryParams['store_id'] = storeId;
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;

    return await _apiService.get<PaginatedPreAlertsResponse>(
      endpoint: ApiEndpoints.searchPreAlerts,
      queryParameters: queryParams,
      fromJson: (json) {
        if (json == null) {
          return PaginatedPreAlertsResponse(
            data: [],
            currentPage: 1,
            lastPage: 1,
            total: 0,
            perPage: perPage,
          );
        }

        if (json is Map<String, dynamic>) {
          return PaginatedPreAlertsResponse.fromJson(json);
        }

        return PaginatedPreAlertsResponse(
          data: [],
          currentPage: 1,
          lastPage: 1,
          total: 0,
          perPage: perPage,
        );
      },
    );
  }

  /// Obtener historial de estados de una pre-alerta
  Future<List<StatusHistoryItem>> getStatusHistory(String id) async {
    return await _apiService.get<List<StatusHistoryItem>>(
      endpoint: ApiEndpoints.getPreAlertStatusHistory(id),
      fromJson: (json) {
        if (json == null) return [];
        if (json is Map<String, dynamic>) {
          // Si viene envuelto en la respuesta estándar
          if (json.containsKey('data') && json.containsKey('status')) {
            final response = StatusHistoryResponse.fromJson(json);
            return response.data;
          }
          // Si viene directamente como lista
          if (json.containsKey('data') && json['data'] is List) {
            final data = json['data'] as List;
            return data
                .map(
                  (item) =>
                      StatusHistoryItem.fromJson(item as Map<String, dynamic>),
                )
                .toList();
          }
        }
        if (json is List) {
          return json
              .map(
                (item) =>
                    StatusHistoryItem.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return [];
      },
    );
  }

  /// Obtener KPIs del admin
  Future<AdminKPIs> getKPIs() async {
    return await _apiService.get<AdminKPIs>(
      endpoint: ApiEndpoints.adminKPIs,
      fromJson: (json) {
        // El api_service ya extrae el campo 'data' de la respuesta
        // Entonces json ya es el objeto data directamente
        if (json is Map<String, dynamic>) {
          return AdminKPIs.fromJson(json);
        }
        // Si por alguna razón viene envuelto, intentar extraer 'data'
        if (json is Map<String, dynamic> && json.containsKey('data')) {
          return AdminKPIs.fromJson(json['data'] as Map<String, dynamic>);
        }
        // Retornar valores por defecto si hay error
        return AdminKPIs(
          createdToday: 0,
          receivedToday: 0,
          totalWarehouse: 0,
          departuresToday: 0,
        );
      },
    );
  }

  /// Obtener conteos de paquetes pendientes de un cliente por tipo de entrega
  Future<CustomerPendingCounts> getCustomerPendingCounts(int customerId) async {
    return await _apiService.get<CustomerPendingCounts>(
      endpoint: ApiEndpoints.customerPendingCounts(customerId),
      fromJson: (json) {
        // El api_service ya extrae el campo 'data' de la respuesta
        // Entonces json ya es el objeto { pickup_pending: X, delivery_pending: Y }
        if (json is Map<String, dynamic>) {
          return CustomerPendingCounts.fromJson(json);
        }
        // Retornar valores por defecto si hay error
        return CustomerPendingCounts(
          pickupPending: 0,
          deliveryPending: 0,
        );
      },
    );
  }
}
