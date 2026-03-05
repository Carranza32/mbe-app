/// Patrones de URL para detectar resultado del hosted checkout (CyberSource).
/// El backend redirige a estas rutas; el WebView las intercepta y cierra con el resultado.
class HostedCheckoutUrls {
  HostedCheckoutUrls._();

  /// URLs que indican pago exitoso
  static bool isSuccess(String url) {
    return url.contains('/payment/success') ||
        (url.contains('/payment-result') && !url.contains('error'));
  }

  /// URLs que indican cancelación o error (usuario canceló o fallo del gateway)
  static bool isCancelOrError(String url) {
    return url.contains('/payment/info') ||
        url.contains('/payment/error') ||
        url.contains('/payment/cancel');
  }

  /// Determina si la URL es de nuestro dominio (para no interceptar CyberSource ni terceros)
  static bool isAppDomain(String url, String? appBaseUrl) {
    if (appBaseUrl == null || appBaseUrl.isEmpty) return true;
    try {
      final uri = Uri.parse(url);
      final base = Uri.parse(appBaseUrl);
      return uri.host == base.host;
    } catch (_) {
      return false;
    }
  }
}
