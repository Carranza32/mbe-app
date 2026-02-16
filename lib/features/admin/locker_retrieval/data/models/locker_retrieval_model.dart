/// Detalle de un retiro obtenido por token (by-token).
/// Respuesta de GET /api/v1/admin/locker-retrieval/by-token/{token}
class LockerRetrievalDetail {
  final int id;
  final String storeName;
  final String physicalLockerCode;
  final String customerNameMasked;
  final String lockerCodeLast4;
  final String type;
  final String typeLabel;
  final int pieceCount;
  final String? pinExpiresAt;

  LockerRetrievalDetail({
    required this.id,
    required this.storeName,
    required this.physicalLockerCode,
    required this.customerNameMasked,
    required this.lockerCodeLast4,
    required this.type,
    required this.typeLabel,
    required this.pieceCount,
    this.pinExpiresAt,
  });

  factory LockerRetrievalDetail.fromJson(Map<String, dynamic> json) {
    return LockerRetrievalDetail(
      id: json['id'] as int,
      storeName: json['store_name'] as String? ?? '',
      physicalLockerCode:
          json['physical_locker_code'] as String? ?? '',
      customerNameMasked:
          json['customer_name_masked'] as String? ?? '',
      lockerCodeLast4: json['locker_code_last4'] as String? ?? '',
      type: json['type'] as String? ?? 'package',
      typeLabel: json['type_label'] as String? ?? 'Paquete',
      pieceCount: json['piece_count'] as int? ?? 1,
      pinExpiresAt: json['pin_expires_at'] as String?,
    );
  }
}

/// Item de búsqueda de retiros (search).
/// Respuesta de GET /api/v1/admin/locker-retrieval/search
class LockerRetrievalSearchItem {
  final int id;
  final String pickupToken;
  final String storeName;
  final String physicalLockerCode;
  final String customerNameMasked;
  final String? lockerCode;
  final String type;
  final int pieceCount;

  LockerRetrievalSearchItem({
    required this.id,
    required this.pickupToken,
    required this.storeName,
    required this.physicalLockerCode,
    required this.customerNameMasked,
    this.lockerCode,
    required this.type,
    this.pieceCount = 1,
  });

  factory LockerRetrievalSearchItem.fromJson(Map<String, dynamic> json) {
    return LockerRetrievalSearchItem(
      id: json['id'] as int,
      pickupToken: json['pickup_token'] as String? ?? '',
      storeName: json['store_name'] as String? ?? '',
      physicalLockerCode:
          json['physical_locker_code'] as String? ?? '',
      customerNameMasked:
          json['customer_name_masked'] as String? ?? '',
      lockerCode: json['locker_code'] as String?,
      type: json['type'] as String? ?? 'package',
      pieceCount: json['piece_count'] as int? ?? 1,
    );
  }
}

/// Contadores para tabs (pendientes / entregados).
/// Respuesta de GET /api/v1/admin/locker-retrieval/counts
class LockerRetrievalCounts {
  final int pending;
  final int delivered;

  LockerRetrievalCounts({required this.pending, required this.delivered});

  factory LockerRetrievalCounts.fromJson(Map<String, dynamic> json) {
    return LockerRetrievalCounts(
      pending: json['pending'] as int? ?? 0,
      delivered: json['delivered'] as int? ?? 0,
    );
  }
}

/// Item de la lista paginada de retiros (pickups).
/// Respuesta de GET /api/v1/admin/locker-retrieval/pickups (cada elemento del array data.data)
class LockerPickupItem {
  final int id;
  final String pickupToken;
  final String storeName;
  final String physicalLockerCode;
  final String customerNameMasked;
  final String? lockerCode;
  final String type;
  final String typeLabel;
  final int pieceCount;
  final String? createdAt;
  final String? pinExpiresAt;
  final String? deliveredAt;

  LockerPickupItem({
    required this.id,
    required this.pickupToken,
    required this.storeName,
    required this.physicalLockerCode,
    required this.customerNameMasked,
    this.lockerCode,
    required this.type,
    this.typeLabel = 'Paquete',
    this.pieceCount = 1,
    this.createdAt,
    this.pinExpiresAt,
    this.deliveredAt,
  });

  factory LockerPickupItem.fromJson(Map<String, dynamic> json) {
    return LockerPickupItem(
      id: json['id'] as int,
      pickupToken: json['pickup_token'] as String? ?? '',
      storeName: json['store_name'] as String? ?? '',
      physicalLockerCode:
          json['physical_locker_code'] as String? ?? '',
      customerNameMasked:
          json['customer_name_masked'] as String? ?? '',
      lockerCode: json['locker_code'] as String?,
      type: json['type'] as String? ?? 'package',
      typeLabel: json['type_label'] as String? ?? 'Paquete',
      pieceCount: json['piece_count'] as int? ?? 1,
      createdAt: json['created_at'] as String?,
      pinExpiresAt: json['pin_expires_at'] as String?,
      deliveredAt: json['delivered_at'] as String?,
    );
  }
}

/// Respuesta paginada de pickups (data.data + data.meta).
/// El ApiService extrae el primer "data", así que fromJson recibe { data: [...], meta: {...} }
class PaginatedPickupsResponse {
  final List<LockerPickupItem> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  PaginatedPickupsResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  bool get hasMorePages => currentPage < lastPage;

  factory PaginatedPickupsResponse.fromJson(Map<String, dynamic> json) {
    List<LockerPickupItem> dataList = [];
    if (json['data'] is List) {
      for (final e in json['data'] as List) {
        dataList.add(
            LockerPickupItem.fromJson(e as Map<String, dynamic>));
      }
    }
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    return PaginatedPickupsResponse(
      data: dataList,
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage: meta['last_page'] as int? ?? 1,
      total: meta['total'] as int? ?? 0,
      perPage: meta['per_page'] as int? ?? 15,
    );
  }
}

/// Casillero físico de una tienda (para formulario crear retiro).
/// GET /admin/locker-retrieval/stores/{storeId}/physical-lockers
class PhysicalLockerModel {
  final int id;
  final String code;
  final int order;

  PhysicalLockerModel({
    required this.id,
    required this.code,
    this.order = 0,
  });

  factory PhysicalLockerModel.fromJson(Map<String, dynamic> json) {
    return PhysicalLockerModel(
      id: json['id'] as int,
      code: json['code'] as String? ?? '',
      order: json['order'] as int? ?? 0,
    );
  }
}

/// Cuenta de casillero (para formulario crear retiro).
/// GET /admin/locker-retrieval/locker-accounts
class LockerAccountModel {
  final int id;
  final String code;
  final String customerName;

  LockerAccountModel({
    required this.id,
    required this.code,
    required this.customerName,
  });

  factory LockerAccountModel.fromJson(Map<String, dynamic> json) {
    return LockerAccountModel(
      id: json['id'] as int,
      code: json['code'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
    );
  }
}

/// Respuesta de POST /admin/locker-pickups (crear retiro).
class CreatePickupResponse {
  final int id;
  final String pickupToken;
  final int storeId;
  final String physicalLockerCode;
  final String lockerAccountCode;
  final String type;
  final int pieceCount;
  final String status;
  final String? pinExpiresAt;

  CreatePickupResponse({
    required this.id,
    required this.pickupToken,
    required this.storeId,
    required this.physicalLockerCode,
    required this.lockerAccountCode,
    required this.type,
    required this.pieceCount,
    required this.status,
    this.pinExpiresAt,
  });

  factory CreatePickupResponse.fromJson(Map<String, dynamic> json) {
    return CreatePickupResponse(
      id: json['id'] as int,
      pickupToken: json['pickup_token'] as String? ?? '',
      storeId: json['store_id'] as int? ?? 0,
      physicalLockerCode:
          json['physical_locker_code'] as String? ?? '',
      lockerAccountCode:
          json['locker_account_code'] as String? ?? '',
      type: json['type'] as String? ?? 'package',
      pieceCount: json['piece_count'] as int? ?? 1,
      status: json['status'] as String? ?? 'pending',
      pinExpiresAt: json['pin_expires_at'] as String?,
    );
  }
}
