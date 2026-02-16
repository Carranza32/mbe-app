/// Constantes de endpoints de la API
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Cambiar según tu entorno
  static const String baseUrl = 'https://sistema.mbeelsalvador.com/api/v1';
  //   static const String baseUrl = 'http://192.168.31.229:8000/api/v1';
  // static const String baseUrl = 'https://127.0.0.1:8000/api/v1';

  // Auth endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String refreshToken = '/refresh';
  static const String profile = '/profile';
  static const String updateProfile = '/profile';
  static const String changePassword = '/profile/change-password';
  static const String verifyCode = '/verify-code';
  static const String resendVerificationCode = '/resend-verification-code';
  static const String checkEmail = '/auth/check-email';
  static const String sendActivationCode = '/auth/send-activation-code';
  static const String verifyOtp = '/auth/verify-otp';
  static const String setPassword = '/auth/set-password';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

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
  static const String analyzeInvoice = '/pre-alerts/analyze-invoice';
  static String preAlertById(String id) => '/pre-alerts/$id';
  static String completePreAlertInfo(String id) =>
      '/pre-alerts/$id/complete-info';
  static String initiatePreAlertPayment(String id) => '/pre-alerts/$id/payment';
  static const String checkPreAlertPromotion = '/pre-alerts/check-promotion';

  // Payment endpoints
  static String paymentStatus(String paymentId) =>
      '/payments/$paymentId/status';
  static String paymentRedirectUrl(String paymentId) =>
      '/payments/$paymentId/redirect-url';

  // Promotions endpoints
  static const String bestPromotion = '/promotions/best-promotion';

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
  static String customerPendingCounts(int customerId) =>
      '/admin/pre-alerts/customer/$customerId/pending-counts';

  // Admin stores (listar tiendas para selector)
  static const String adminStores = '/admin/stores';

  // Store warehouse locations
  static String getStoreWarehouseLocations(int storeId) =>
      '/admin/stores/$storeId/warehouse-locations';

  // Locker retrieval (retiro en tienda)
  static String lockerRetrievalByToken(String token) =>
      '/admin/locker-retrieval/by-token/$token';
  static const String lockerRetrievalDeliver =
      '/admin/locker-retrieval/deliver';
  static const String lockerRetrievalSearch = '/admin/locker-retrieval/search';
  static const String lockerRetrievalCounts = '/admin/locker-retrieval/counts';
  static const String lockerRetrievalPickups =
      '/admin/locker-retrieval/pickups';
  static const String lockerPickupsCreate = '/admin/locker-pickups';
  static String physicalLockers(int storeId) =>
      '/admin/locker-retrieval/stores/$storeId/physical-lockers';
  static const String lockerAccounts =
      '/admin/locker-retrieval/locker-accounts';

  // Admin KPIs endpoints
  static const String adminKPIs = '/admin/kpis';

  // Product categories
  static const String productCategories = '/product-categories';

  // Shipping providers
  static const String shippingProviders = '/shipping-providers';

  // Shipping calculator
  static const String shippingCalculator = '/shipping-calculator/calculate';

  // Stores endpoints (tiendas MBE para recoger paquetes)
  static const String stores = '/stores';

  // Providers endpoints (tiendas/proveedores para pre-alertas)
  static const String providers = '/providers';

  // Addresses endpoints
  static const String addresses = '/addresses';
  static String addressById(String id) => '/addresses/$id';
  static String setDefaultAddress(String id) => '/addresses/$id/set-default';

  // Document configs endpoints
  static const String documentConfigs = '/document-configs';

  // Geo endpoints (para campos dependientes)
  static String getAdm1(String countryCode) => '/geo/adm1/$countryCode';
  static String getAdm2(String countryCode, String regionCode) =>
      '/geo/adm2/$countryCode/$regionCode';
  static String getAdm3(
    String countryCode,
    String regionCode,
    String cityCode,
  ) => '/geo/adm3/$countryCode/$regionCode/$cityCode';

  // Trends (productos en tendencia - no requiere auth)
  static const String trends = '/trends';

  // Puedes agregar más endpoints según necesites
  static const String products = '/products';
  static const String users = '/users';

  // Helper method para construir URLs completas
  static String fullUrl(String endpoint) => baseUrl + endpoint;
}
