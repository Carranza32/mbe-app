/// Constantes de endpoints de la API
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Cambiar según tu entorno
  static const String baseUrl = 'http://192.168.31.104:8000/api/v1';

  // Auth endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String refreshToken = '/refresh';
  static const String profile = '/profile';

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