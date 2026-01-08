import 'admin_pre_alert_model.dart';
import 'package_status.dart';

class PaginatedPreAlertsResponse {
  final List<AdminPreAlert> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  PaginatedPreAlertsResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  bool get hasMorePages => currentPage < lastPage;
  int get nextPage => currentPage + 1;

  factory PaginatedPreAlertsResponse.fromJson(Map<String, dynamic> json) {
    // Debug: imprimir el JSON recibido
    print('📦 PaginatedPreAlertsResponse.fromJson recibido:');
    print('  Keys: ${json.keys.toList()}');
    print('  Tiene data: ${json.containsKey('data')}');
    if (json.containsKey('data')) {
      print('  Tipo de data: ${json['data'].runtimeType}');
    }
    
    // El ApiService ya extrae el 'data' de la respuesta si existe
    // Entonces json debería ser directamente el objeto de paginación:
    // {current_page: 1, data: [...], last_page: X, total: Y, per_page: Z}
    
    // Extraer la lista de datos
    List<dynamic> dataList = [];
    if (json.containsKey('data')) {
      if (json['data'] is List) {
        // Formato directo: {data: [...], current_page: 1, ...}
        dataList = json['data'] as List;
        print('  ✅ Lista de datos encontrada: ${dataList.length} items');
      } else if (json['data'] is Map<String, dynamic>) {
        // Formato anidado: {data: {data: [...], current_page: 1, ...}}
        final nestedData = json['data'] as Map<String, dynamic>;
        if (nestedData.containsKey('data') && nestedData['data'] is List) {
          dataList = nestedData['data'] as List;
          print('  ✅ Lista de datos anidada encontrada: ${dataList.length} items');
        }
      }
    }
    
    // Extraer metadatos de paginación
    final currentPage = json['current_page'] as int? ?? 1;
    final lastPage = json['last_page'] as int? ?? 1;
    final total = json['total'] as int? ?? 0;
    final perPage = json['per_page'] as int? ?? 15;
    
    print('  📄 Paginación: página $currentPage de $lastPage, total: $total');

    final parsedData = <AdminPreAlert>[];
    for (var item in dataList) {
      try {
        final package = AdminPreAlert.fromJson(item as Map<String, dynamic>);
        parsedData.add(package);
      } catch (e, stackTrace) {
        print('❌ Error parsing AdminPreAlert: $e');
        print('   Error type: ${e.runtimeType}');
        print('   Item keys: ${(item as Map).keys.toList()}');
        // Intentar identificar el campo problemático
        if (e.toString().contains('is not a subtype')) {
          print('   ⚠️ Problema de tipo: un campo viene como String cuando se espera num');
          // Intentar parsear con valores por defecto
          try {
            final itemMap = item as Map<String, dynamic>;
            // Crear un paquete con valores por defecto para campos problemáticos
            final safePackage = AdminPreAlert(
              id: itemMap['id']?.toString() ?? '0',
              trackingNumber: itemMap['track_number']?.toString() ?? itemMap['tracking_number']?.toString() ?? '',
              eboxCode: itemMap['package_code']?.toString() ?? itemMap['ebox_code']?.toString() ?? '',
              clientName: 'N/A',
              provider: 'N/A',
              total: 0.0,
              productCount: 0,
              store: 'N/A',
              status: PackageStatus.ingresada,
              createdAt: DateTime.now(),
            );
            parsedData.add(safePackage);
            print('   ✅ Paquete creado con valores por defecto');
          } catch (e2) {
            print('   ❌ No se pudo crear paquete por defecto: $e2');
          }
        }
        print('   Stack: $stackTrace');
      }
    }
    
    print('  ✅ Paquetes parseados correctamente: ${parsedData.length}');

    return PaginatedPreAlertsResponse(
      data: parsedData,
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
      perPage: perPage,
    );
  }
}

