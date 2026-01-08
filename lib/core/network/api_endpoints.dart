/// Constantes de endpoints de la API
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Cambiar según tu entorno
  static const String baseUrl = 'http://192.168.31.132:8000/api/v1';
  // static const String baseUrl = 'https://127.0.0.1:8000/api/v1';

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

  // Pre-alerts endpoints (customer)
  static const String preAlerts = '/pre-alerts';
  static const String createPreAlert = '/pre-alerts';
  static String preAlertById(String id) => '/pre-alerts/$id';

  // Pre-alerts endpoints (admin)
  static const String adminPreAlerts = '/admin/pre-alerts';
  static String getPreAlertById(String id) => '/admin/pre-alerts/$id';
  static String updatePreAlertStatus(String id) =>
      '/admin/pre-alerts/$id/status';
  static String bulkUpdatePreAlertStatus = '/admin/pre-alerts/bulk-status';
  static String findPackageByEbox = '/admin/pre-alerts/find-by-ebox';
  static String processReception = '/admin/pre-alerts/process-reception';
  static String assignRack = '/admin/pre-alerts/assign-rack';
  static String updateLocation(String id) => '/admin/pre-alerts/$id/location';
  static String processPickupDelivery =
      '/admin/pre-alerts/process-pickup-delivery';
  static String processDeliveryDispatch =
      '/admin/pre-alerts/process-delivery-dispatch';
  static String updatePreAlert(String id) => '/admin/pre-alerts/$id';
  static String uploadPreAlertDocument(String id) =>
      '/admin/pre-alerts/$id/documents';
  static String getPreAlertStatusHistory(String id) =>
      '/admin/pre-alerts/$id/status-history';
  static const String searchPreAlerts = '/admin/pre-alerts/search';
  
  // Store warehouse locations
  static String getStoreWarehouseLocations(int storeId) =>
      '/admin/stores/$storeId/warehouse-locations';

  // Product categories
  static const String productCategories = '/product-categories';

  // Shipping providers
  static const String shippingProviders = '/shipping-providers';

  // Shipping calculator
  static const String shippingCalculator = '/shipping-calculator/calculate';

  // Puedes agregar más endpoints según necesites
  static const String products = '/products';
  static const String users = '/users';

  // Helper method para construir URLs completas
  static String fullUrl(String endpoint) => baseUrl + endpoint;
}
