/// Modelo genérico para manejar respuestas de la API
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
    this.errors,
  });

  factory ApiResponse.success({
    required T data,
    String message = 'Operación exitosa',
    int? statusCode,
  }) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({
    required String message,
    int? statusCode,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode)';
  }
}