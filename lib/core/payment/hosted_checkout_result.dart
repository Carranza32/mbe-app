/// Resultado del hosted checkout (CyberSource u otro gateway vía WebView).
/// Usado de forma global por pre-alerts, print orders y futuros módulos.
class HostedCheckoutResult {
  final bool success;
  final String paymentId;
  final bool cancelled;

  const HostedCheckoutResult({
    required this.success,
    required this.paymentId,
    this.cancelled = false,
  });
}
