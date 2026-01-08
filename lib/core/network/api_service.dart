import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_exception.dart';
import 'dio_provider.dart';

/// Provider del servicio API
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.read(dioProvider));
});

/// Servicio principal para todas las peticiones API
class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  /// GET - Obtener datos
  /// 
  /// [endpoint] - El endpoint de la API (ej: '/orders')
  /// [fromJson] - Función para convertir JSON a tu modelo
  /// [queryParameters] - Parámetros de consulta opcionales
  /// 
  /// Retorna directamente el tipo T o lanza ApiException si hay error
  /// 
  /// Ejemplo de uso:
  /// ```dart
  /// final orders = await apiService.get<List<Order>>(
  ///   endpoint: ApiEndpoints.orders,
  ///   fromJson: (json) => (json as List).map((e) => Order.fromJson(e)).toList(),
  /// );
  /// ```
  Future<T> get<T>({
    required String endpoint,
    required T Function(dynamic json) fromJson,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      return _processResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error inesperado: ${e.toString()}');
    }
  }

  /// POST - Crear/enviar datos
  /// 
  /// [endpoint] - El endpoint de la API
  /// [data] - Los datos a enviar
  /// [fromJson] - Función para convertir la respuesta JSON a tu modelo
  /// 
  /// Retorna directamente el tipo T o lanza ApiException si hay error
  /// 
  /// Ejemplo de uso:
  /// ```dart
  /// final newOrder = await apiService.post<Order>(
  ///   endpoint: ApiEndpoints.createOrder,
  ///   data: orderData,
  ///   fromJson: (json) => Order.fromJson(json),
  /// );
  /// ```
  Future<T> post<T>({
    required String endpoint,
    required dynamic data,
    required T Function(dynamic json) fromJson,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );

      return _processResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error inesperado: ${e.toString()}');
    }
  }

  /// PUT - Actualizar datos completos
  /// 
  /// [endpoint] - El endpoint de la API
  /// [data] - Los datos a actualizar
  /// [fromJson] - Función para convertir la respuesta JSON a tu modelo
  /// 
  /// Retorna directamente el tipo T o lanza ApiException si hay error
  /// 
  /// Ejemplo de uso:
  /// ```dart
  /// final updatedOrder = await apiService.put<Order>(
  ///   endpoint: ApiEndpoints.updateOrder('123'),
  ///   data: orderData,
  ///   fromJson: (json) => Order.fromJson(json),
  /// );
  /// ```
  Future<T> put<T>({
    required String endpoint,
    required Map<String, dynamic> data,
    required T Function(dynamic json) fromJson,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );

      return _processResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error inesperado: ${e.toString()}');
    }
  }

  /// PATCH - Actualizar datos parciales
  /// 
  /// Similar a PUT pero para actualizaciones parciales
  /// 
  /// Retorna directamente el tipo T o lanza ApiException si hay error
  Future<T> patch<T>({
    required String endpoint,
    required Map<String, dynamic> data,
    required T Function(dynamic json) fromJson,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );

      return _processResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error inesperado: ${e.toString()}');
    }
  }

  /// DELETE - Eliminar datos
  /// 
  /// [endpoint] - El endpoint de la API
  /// [fromJson] - Función opcional para convertir la respuesta (si el servidor retorna algo)
  /// 
  /// Retorna directamente el tipo T o lanza ApiException si hay error
  /// Por defecto, si T es bool, retorna true si la petición fue exitosa
  /// 
  /// Ejemplo de uso:
  /// ```dart
  /// // Para retornar bool (más común)
  /// await apiService.delete<bool>(
  ///   endpoint: ApiEndpoints.deleteOrder('123'),
  /// );
  /// 
  /// // O si el servidor retorna datos:
  /// final result = await apiService.delete<Order>(
  ///   endpoint: ApiEndpoints.deleteOrder('123'),
  ///   fromJson: (json) => Order.fromJson(json),
  /// );
  /// ```
  Future<T> delete<T>({
    required String endpoint,
    T Function(dynamic json)? fromJson,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
        data: data,
      );

      // Si no se provee fromJson y T es bool, retornar true por defecto
      if (fromJson == null && T == bool) {
        return true as T;
      }

      // Si se provee fromJson, usar el proceso normal
      if (fromJson != null) {
        return _processResponse<T>(response, fromJson);
      }

      // Si no hay fromJson y no es bool, lanzar error
      throw ApiException(
        message: 'Se requiere fromJson para el tipo $T',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error inesperado: ${e.toString()}');
    }
  }

  /// POST para subir archivos (multipart/form-data)
  /// 
  /// [endpoint] - El endpoint de la API
  /// [files] - Mapa de archivos a subir (nombre del campo -> ruta del archivo)
  /// [data] - Datos adicionales del formulario
  /// [fromJson] - Función para convertir la respuesta
  /// [onProgress] - Callback opcional para seguir el progreso de subida
  /// 
  /// Retorna directamente el tipo T o lanza ApiException si hay error
  /// 
  /// Ejemplo de uso:
  /// ```dart
  /// final order = await apiService.uploadFiles<Order>(
  ///   endpoint: ApiEndpoints.createOrder,
  ///   files: {'document': '/path/to/file.pdf'},
  ///   data: {'name': 'Mi orden', 'quantity': 5},
  ///   fromJson: (json) => Order.fromJson(json),
  ///   onProgress: (sent, total) {
  ///     print('Progreso: ${(sent / total * 100).toStringAsFixed(0)}%');
  ///   },
  /// );
  /// ```
  Future<T> uploadFiles<T>({
    required String endpoint,
    required Map<String, String> files,
    Map<String, dynamic>? data,
    required T Function(dynamic json) fromJson,
    void Function(int, int)? onProgress,
  }) async {
    try {
      final formData = FormData();

      // Agregar archivos
      for (final entry in files.entries) {
        formData.files.add(MapEntry(
          entry.key,
          await MultipartFile.fromFile(entry.value),
        ));
      }

      // Agregar datos aplanados
      if (data != null) {
        final flattened = _flattenMap(data);
      
        // ✅ LOG PARA DEBUG
        print('📤 Datos aplanados:');
        flattened.forEach((key, value) {
          print('  $key: $value');
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

       // ✅ LOG DE ARCHIVOS
        print('📎 Archivos:');
        for (var file in formData.files) {
          print('  ${file.key}: ${file.value.filename}');
        }

      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: onProgress,
      );

      return _processResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error inesperado: ${e.toString()}');
    }
  }

  Map<String, dynamic> _flattenMap(Map<String, dynamic> map, [String prefix = '']) {
    final result = <String, dynamic>{};
    
    map.forEach((key, value) {
      final newKey = prefix.isEmpty ? key : '$prefix[$key]';
      
      if (value is Map<String, dynamic>) {
        result.addAll(_flattenMap(value, newKey));
      } else if (value != null) {
        if (value is bool) {
          result[newKey] = value ? '1' : '0';
        } else {
          result[newKey] = value;
        }
      }
    });
    
    return result;
  }

  /// Procesa la respuesta HTTP y convierte los datos al tipo T
  /// Lanza ApiException si hay algún error
  T _processResponse<T>(
    Response response,
    T Function(dynamic json) fromJson,
  ) {
    final statusCode = response.statusCode ?? 0;

    // Verificar si la respuesta es exitosa (200-299)
    if (statusCode >= 200 && statusCode < 300) {
      try {
        dynamic dataToConvert = response.data;

        // Si la respuesta tiene estructura { status, message, data }
        // extraer el campo 'data'
        if (response.data is Map<String, dynamic>) {
          final map = response.data as Map<String, dynamic>;
          
          // Si tiene un campo 'data' y no es null, usar ese para la conversión
          if (map.containsKey('data') && map['data'] != null) {
            dataToConvert = map['data'];
            print('📦 ApiService: Extraído campo "data" de la respuesta');
          }
          // Si no tiene 'data' pero tiene 'result', usar ese
          else if (map.containsKey('result') && map['result'] != null) {
            dataToConvert = map['result'];
            print('📦 ApiService: Extraído campo "result" de la respuesta');
          }
          // Si no, usar todo el map
          else {
            print('📦 ApiService: Usando toda la respuesta como data');
          }
        }

        // Convertir los datos usando fromJson
        return fromJson(dataToConvert);
      } catch (e) {
        throw ApiException(
          message: 'Error al procesar la respuesta: ${e.toString()}',
          statusCode: statusCode,
        );
      }
    } else {
      // Respuesta no exitosa (aunque no debería llegar aquí normalmente)
      String message = 'Error en la petición';
      Map<String, dynamic>? errors;

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        message = map['message'] as String? ?? message;
        errors = map['errors'] as Map<String, dynamic>?;
      }

      throw ApiException(
        message: message,
        statusCode: statusCode,
        errors: errors,
      );
    }
  }
}