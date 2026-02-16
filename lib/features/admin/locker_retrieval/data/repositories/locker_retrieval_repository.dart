import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/api_service.dart';
import '../models/admin_store_model.dart';
import '../models/locker_retrieval_model.dart';

class LockerRetrievalRepository {
  final ApiService _apiService;

  LockerRetrievalRepository(this._apiService);

  /// GET /admin/stores - Lista de tiendas accesibles para el usuario.
  Future<List<AdminStoreModel>> getStores() async {
    return _apiService.get<List<AdminStoreModel>>(
      endpoint: ApiEndpoints.adminStores,
      fromJson: (json) {
        if (json is List) {
          return [
            for (final e in json)
              AdminStoreModel.fromJson(e as Map<String, dynamic>),
          ];
        }
        return <AdminStoreModel>[];
      },
    );
  }

  /// GET /admin/locker-retrieval/by-token/{token}
  Future<LockerRetrievalDetail> getRetrievalByToken(String token) async {
    final cleanToken = _extractToken(token);
    return await _apiService.get<LockerRetrievalDetail>(
      endpoint: ApiEndpoints.lockerRetrievalByToken(cleanToken),
      fromJson: (json) =>
          LockerRetrievalDetail.fromJson(json as Map<String, dynamic>),
    );
  }

  /// POST /admin/locker-retrieval/deliver
  Future<void> deliver({
    required String token,
    required String pin,
  }) async {
    final cleanToken = _extractToken(token);
    await _apiService.post<Map<String, dynamic>>(
      endpoint: ApiEndpoints.lockerRetrievalDeliver,
      data: {'token': cleanToken, 'pin': pin},
      fromJson: (json) => json as Map<String, dynamic>? ?? {},
    );
  }

  /// GET /admin/locker-retrieval/counts?store_id=
  Future<LockerRetrievalCounts> getCounts(int storeId) async {
    return _apiService.get<LockerRetrievalCounts>(
      endpoint: ApiEndpoints.lockerRetrievalCounts,
      queryParameters: {'store_id': storeId},
      fromJson: (json) =>
          LockerRetrievalCounts.fromJson(json as Map<String, dynamic>),
    );
  }

  /// GET /admin/locker-retrieval/pickups?store_id=&status=&page=&per_page=
  Future<PaginatedPickupsResponse> getPickups({
    required int storeId,
    required String status,
    int page = 1,
    int perPage = 15,
  }) async {
    return _apiService.get<PaginatedPickupsResponse>(
      endpoint: ApiEndpoints.lockerRetrievalPickups,
      queryParameters: {
        'store_id': storeId,
        'status': status,
        'page': page,
        'per_page': perPage,
      },
      fromJson: (json) =>
          PaginatedPickupsResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// GET /admin/locker-retrieval/stores/{storeId}/physical-lockers
  Future<List<PhysicalLockerModel>> getPhysicalLockers(int storeId) async {
    return _apiService.get<List<PhysicalLockerModel>>(
      endpoint: ApiEndpoints.physicalLockers(storeId),
      fromJson: (json) {
        if (json is List) {
          return [
            for (final e in json)
              PhysicalLockerModel.fromJson(e as Map<String, dynamic>),
          ];
        }
        return <PhysicalLockerModel>[];
      },
    );
  }

  /// GET /admin/locker-retrieval/locker-accounts?store_id=
  Future<List<LockerAccountModel>> getLockerAccounts({int? storeId}) async {
    return _apiService.get<List<LockerAccountModel>>(
      endpoint: ApiEndpoints.lockerAccounts,
      queryParameters:
          storeId != null ? {'store_id': storeId} : null,
      fromJson: (json) {
        if (json is List) {
          return [
            for (final e in json)
              LockerAccountModel.fromJson(e as Map<String, dynamic>),
          ];
        }
        return <LockerAccountModel>[];
      },
    );
  }

  /// POST /admin/locker-pickups - Crear retiro.
  Future<CreatePickupResponse> createPickup({
    required int storeId,
    required int physicalLockerId,
    required int lockerAccountId,
    String type = 'package',
    int pieceCount = 1,
    String notes = '',
  }) async {
    return _apiService.post<CreatePickupResponse>(
      endpoint: ApiEndpoints.lockerPickupsCreate,
      data: {
        'store_id': storeId,
        'physical_locker_id': physicalLockerId,
        'locker_account_id': lockerAccountId,
        'type': type,
        'piece_count': pieceCount,
        'notes': notes,
      },
      fromJson: (json) =>
          CreatePickupResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// GET /admin/locker-retrieval/search?store_id=&search=
  Future<List<LockerRetrievalSearchItem>> search({
    required int storeId,
    required String search,
  }) async {
    if (search.trim().length < 2) {
      return [];
    }
    return _apiService.get<List<LockerRetrievalSearchItem>>(
      endpoint: ApiEndpoints.lockerRetrievalSearch,
      queryParameters: {
        'store_id': storeId,
        'search': search.trim(),
      },
      fromJson: (json) {
        if (json is List) {
          return [
            for (final e in json)
              LockerRetrievalSearchItem.fromJson(e as Map<String, dynamic>),
          ];
        }
        return <LockerRetrievalSearchItem>[];
      },
    );
  }

  /// Extrae el token de una URL (ej. ?token=xxx) o devuelve el texto tal cual.
  static String _extractToken(String value) {
    final trimmed = value.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.queryParameters.containsKey('token')) {
      return uri.queryParameters['token']!.trim();
    }
    return trimmed;
  }
}
