import 'package:dio/dio.dart';

/// Excepción base para errores de API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => message;

  /// Factory para crear excepciones desde DioException
  factory ApiException.fromDioException(DioException error) {
    String message;
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Tiempo de conexión agotado. Por favor, verifica tu internet.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Tiempo de envío agotado. Por favor, intenta nuevamente.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Tiempo de respuesta agotado. Por favor, intenta nuevamente.';
        break;
      case DioExceptionType.badResponse:
        message = _handleStatusCode(statusCode, error.response?.data);
        break;
      case DioExceptionType.cancel:
        message = 'La solicitud fue cancelada.';
        break;
      case DioExceptionType.connectionError:
        message = 'Error de conexión. Verifica tu conexión a internet.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Error de certificado SSL.';
        break;
      case DioExceptionType.unknown:
        message = 'Error desconocido. Por favor, intenta nuevamente.';
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      errors: error.response?.data is Map
          ? Map<String, dynamic>.from(error.response?.data ?? {})
          : null,
    );
  }

  /// Maneja los códigos de estado HTTP
  static String _handleStatusCode(int? statusCode, dynamic responseData) {
    // Intenta extraer el mensaje del servidor
    String? serverMessage;
    if (responseData is Map) {
      serverMessage = responseData['message'] as String?;
    }

    switch (statusCode) {
      case 400:
        return serverMessage ?? 'Solicitud incorrecta. Verifica los datos enviados.';
      case 401:
        return serverMessage ?? 'No autorizado. Por favor, inicia sesión nuevamente.';
      case 403:
        return serverMessage ?? 'Acceso denegado. No tienes permisos para esta acción.';
      case 404:
        return serverMessage ?? 'Recurso no encontrado.';
      case 408:
        return serverMessage ?? 'Tiempo de espera agotado. Intenta nuevamente.';
      case 422:
        return serverMessage ?? 'Datos de validación incorrectos.';
      case 429:
        return serverMessage ?? 'Demasiadas solicitudes. Espera un momento.';
      case 500:
        return serverMessage ?? 'Error del servidor. Por favor, intenta más tarde.';
      case 502:
        return serverMessage ?? 'Error de puerta de enlace. Intenta más tarde.';
      case 503:
        return serverMessage ?? 'Servicio no disponible. Intenta más tarde.';
      default:
        return serverMessage ?? 'Error en la respuesta del servidor ($statusCode).';
    }
  }
}

/// Excepción específica para tokens expirados
class TokenExpiredException extends ApiException {
  TokenExpiredException()
      : super(
          message: 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
          statusCode: 401,
        );
}

/// Excepción para errores de validación
class ValidationException extends ApiException {
  ValidationException({
    required String message,
    Map<String, dynamic>? errors,
  }) : super(
          message: message,
          statusCode: 422,
          errors: errors,
        );
}