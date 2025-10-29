/// Constantes de endpoints de la API
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Cambiar según tu entorno
  static const String baseUrl = 'http://192.168.31.44:8000/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String profile = '/auth/profile';

  // Orders endpoints (pedidos de impresiones)
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static const String createOrder = '/orders';
  static String updateOrder(String id) => '/orders/$id';
  static String deleteOrder(String id) => '/orders/$id';
  static String orderStatus(String id) => '/orders/$id/status';

  // Puedes agregar más endpoints según necesites
  static const String products = '/products';
  static const String users = '/users';
  
  // Helper method para construir URLs completas
  static String fullUrl(String endpoint) => baseUrl + endpoint;
}