// lib/features/pre_alert/data/models/pre_alert_model.dart

class PreAlert {
  final String id;
  final String trackingNumber;
  final String mailboxNumber;
  final String store;
  final double totalValue;
  final String status;
  final DateTime createdAt;
  final int productCount;
  final String? deliveryMethod;

  PreAlert({
    required this.id,
    required this.trackingNumber,
    required this.mailboxNumber,
    required this.store,
    required this.totalValue,
    required this.status,
    required this.createdAt,
    required this.productCount,
    this.deliveryMethod,
  });

  factory PreAlert.fromJson(Map<String, dynamic> json) {
    // Obtener el tracking number (puede venir como track_number o tracking_number)
    final trackNumber =
        json['track_number']?.toString() ??
        json['tracking_number']?.toString() ??
        '';

    // Obtener el mailbox/package code (puede venir como package_code, ebox_code o mailbox_number)
    final mailboxCode =
        json['package_code']?.toString() ??
        json['ebox_code']?.toString() ??
        json['mailbox_number']?.toString() ??
        '';

    // Obtener el nombre de la tienda (puede venir como string o como objeto)
    String storeName = '';
    if (json['store'] != null) {
      if (json['store'] is String) {
        storeName = json['store'] as String;
      } else if (json['store'] is Map<String, dynamic>) {
        storeName =
            (json['store'] as Map<String, dynamic>)['name']?.toString() ?? '';
      }
    }

    // Obtener el estado (puede venir como string o como objeto current_status)
    String statusKey = 'pending';
    if (json['status'] != null && json['status'] is String) {
      statusKey = json['status'] as String;
    } else if (json['current_status'] != null) {
      if (json['current_status'] is String) {
        statusKey = json['current_status'] as String;
      } else if (json['current_status'] is Map<String, dynamic>) {
        final statusObj = json['current_status'] as Map<String, dynamic>;
        statusKey =
            statusObj['name']?.toString() ??
            statusObj['key']?.toString() ??
            'pending';
      }
    }

    // Obtener el total (puede venir como total o total_value)
    final total = (json['total'] ?? json['total_value'] ?? 0) as num;

    // Obtener el método de entrega
    final deliveryMethod = json['delivery_method'] as String?;

    return PreAlert(
      id: json['id'].toString(),
      trackingNumber: trackNumber,
      mailboxNumber: mailboxCode,
      store: storeName.isEmpty ? 'Sin tienda' : storeName,
      totalValue: total.toDouble(),
      status: statusKey,
      createdAt: DateTime.parse(json['created_at'] as String),
      productCount: (json['product_count'] ?? 0) as int,
      deliveryMethod: deliveryMethod,
    );
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pendiente':
        return 'Pendiente';
      case 'received':
      case 'recibido':
        return 'Recibido';
      case 'processing':
      case 'procesando':
        return 'Procesando';
      case 'ready':
      case 'listo':
        return 'Listo';
      case 'ingresada':
        return 'Ingresada';
      case 'lista_para_recibir':
        return 'Lista para recibir';
      case 'en_tienda':
        return 'En tienda';
      case 'solicitud_recoleccion':
        return 'Solicitud de recolección';
      case 'confirmada_recoleccion':
        return 'Recolección confirmada';
      case 'en_ruta':
        return 'En ruta';
      case 'entregada':
        return 'Entregada';
      case 'retornada':
        return 'Retornada';
      case 'lista_retiro':
        return 'Lista para retiro';
      case 'completada':
        return 'Completada';
      case 'cancelada':
        return 'Cancelada';
      default:
        // Intentar capitalizar el status
        return status
            .split('_')
            .map(
              (word) => word.isEmpty
                  ? ''
                  : word[0].toUpperCase() + word.substring(1).toLowerCase(),
            )
            .join(' ');
    }
  }

  String get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pendiente':
        return '#EAB308'; // Yellow
      case 'received':
      case 'recibido':
      case 'en_tienda':
        return '#3B82F6'; // Blue
      case 'processing':
      case 'procesando':
        return '#8B5CF6'; // Purple
      case 'ready':
      case 'listo':
      case 'lista_para_recibir':
      case 'lista_retiro':
        return '#10B981'; // Green
      case 'ingresada':
        return '#3B82F6'; // Blue (info)
      case 'solicitud_recoleccion':
        return '#3B82F6'; // Blue (info)
      case 'confirmada_recoleccion':
      case 'completada':
      case 'entregada':
        return '#10B981'; // Green (success)
      case 'en_ruta':
        return '#F59E0B'; // Orange (warning)
      case 'retornada':
      case 'cancelada':
        return '#EF4444'; // Red (error)
      default:
        return '#6B7280'; // Gray
    }
  }

  // Verificar si esta pre-alerta requiere acción (puede realizar el pago)
  // Requiere acción si está en_tienda y no tiene método de entrega
  bool get requiresAction {
    return status.toLowerCase() == 'en_tienda' && deliveryMethod == null;
  }
}

class PreAlertsResponse {
  final List<PreAlert> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  PreAlertsResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  bool get hasMorePages => currentPage < lastPage;
  int get nextPage => currentPage + 1;

  // Para compatibilidad con código existente
  List<PreAlert> get preAlerts => data;

  factory PreAlertsResponse.fromJson(Map<String, dynamic> json) {
    // El ApiService ya extrae el 'data' de la respuesta si existe
    // Entonces json debería ser directamente el objeto de paginación:
    // {current_page: 1, data: [...], last_page: X, total: Y, per_page: Z}

    // Extraer la lista de datos - manejar null correctamente
    List<dynamic> dataList = [];
    if (json.containsKey('data') && json['data'] != null) {
      if (json['data'] is List) {
        // Formato directo: {data: [...], current_page: 1, ...}
        dataList = json['data'] as List;
      } else if (json['data'] is Map<String, dynamic>) {
        // Formato anidado: {data: {data: [...], current_page: 1, ...}}
        final nestedData = json['data'] as Map<String, dynamic>;
        if (nestedData.containsKey('data') &&
            nestedData['data'] != null &&
            nestedData['data'] is List) {
          dataList = nestedData['data'] as List;
        }
      }
    }

    // Extraer metadatos de paginación
    final currentPage = json['current_page'] as int? ?? 1;
    final lastPage = json['last_page'] as int? ?? 1;
    final total = json['total'] as int? ?? 0;
    final perPage = json['per_page'] as int? ?? 15;

    // Parsear los datos
    final parsedData = <PreAlert>[];
    for (var item in dataList) {
      try {
        if (item != null && item is Map<String, dynamic>) {
          final preAlert = PreAlert.fromJson(item);
          parsedData.add(preAlert);
        }
      } catch (e, stackTrace) {
        print('❌ Error parsing PreAlert: $e');
        if (item != null && item is Map) {
          print('   Item keys: ${item.keys.toList()}');
        } else {
          print('   Item is null or not a Map');
        }
        print('   Stack: $stackTrace');
      }
    }

    return PreAlertsResponse(
      data: parsedData,
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
      perPage: perPage,
    );
  }
}
