import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';
import 'api_endpoints.dart';

/// Provider para Flutter Secure Storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Provider para Dio configurado
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Agregar interceptores
  dio.interceptors.add(AuthInterceptor(ref));
  dio.interceptors.add(LoggingInterceptor());

  return dio;
});

/// Interceptor para agregar el token automáticamente
class AuthInterceptor extends Interceptor {
  final Ref ref;

  AuthInterceptor(this.ref);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Obtener el token del secure storage
    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(key: 'auth_token');

    // Si existe token, agregarlo al header
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Si el error es 401, el token expiró
    if (err.response?.statusCode == 401) {
      // Aquí podrías intentar refrescar el token
      // O limpiar la sesión y redirigir al login
      final storage = ref.read(secureStorageProvider);
      await storage.delete(key: 'auth_token');
      
      // Opcional: Intentar refrescar el token
      // final refreshed = await _refreshToken();
      // if (refreshed) {
      //   return handler.resolve(await _retry(err.requestOptions));
      // }

      // _redirectToLoginGlobal();
    }

    handler.next(err);
  }

  void _redirectToLoginGlobal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        GoRouter.of(context).go('/auth/login');
      }
    });
  }

  // Método para refrescar el token (opcional)
  // Future<bool> _refreshToken() async {
  //   try {
  //     final storage = ref.read(secureStorageProvider);
  //     final refreshToken = await storage.read(key: 'refresh_token');
  //     
  //     if (refreshToken == null) return false;
  //     
  //     final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
  //     final response = await dio.post(
  //       ApiEndpoints.refreshToken,
  //       data: {'refresh_token': refreshToken},
  //     );
  //     
  //     final newToken = response.data['token'];
  //     await storage.write(key: 'auth_token', value: newToken);
  //     
  //     return true;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // Método para reintentar la petición con el nuevo token
  // Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
  //   final options = Options(
  //     method: requestOptions.method,
  //     headers: requestOptions.headers,
  //   );
  //   
  //   return ref.read(dioProvider).request<dynamic>(
  //     requestOptions.path,
  //     data: requestOptions.data,
  //     queryParameters: requestOptions.queryParameters,
  //     options: options,
  //   );
  // }
}

/// Interceptor para logging (útil en desarrollo)
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
    print('📦 Data: ${options.data}');
    print('🔑 Headers: ${options.headers}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    print('📦 Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    print('📦 Error: ${err.message}');
    print('📦 Response: ${err.response?.data}');
    handler.next(err);
  }
}