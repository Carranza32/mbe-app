import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:mbe_orders_app/config/theme/mbe_theme.dart';
import 'hosted_checkout_result.dart';
import 'hosted_checkout_urls.dart';

/// WebView reutilizable para hosted checkout (CyberSource / Promerica).
/// Carga [redirectUrl], intercepta navegación a success/error/cancel y notifica [onComplete].
/// Usado por pre-alerts, print orders y otros módulos que paguen con el mismo flujo.
class HostedCheckoutWebView extends StatefulWidget {
  final String redirectUrl;
  final String paymentId;
  final void Function(HostedCheckoutResult result) onComplete;
  final String? title;
  /// Base URL del backend (ej. ApiEndpoints.baseUrl) para solo interceptar URLs del app
  final String? appBaseUrl;

  const HostedCheckoutWebView({
    super.key,
    required this.redirectUrl,
    required this.paymentId,
    required this.onComplete,
    this.title,
    this.appBaseUrl,
  });

  @override
  State<HostedCheckoutWebView> createState() => _HostedCheckoutWebViewState();
}

class _HostedCheckoutWebViewState extends State<HostedCheckoutWebView> {
  late WebViewController _controller;
  bool _isLoading = true;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _loadingProgress = 0;
            });

            final isApp = HostedCheckoutUrls.isAppDomain(url, widget.appBaseUrl);
            if (!isApp) return;

            if (HostedCheckoutUrls.isSuccess(url)) {
              widget.onComplete(HostedCheckoutResult(
                success: true,
                paymentId: widget.paymentId,
                cancelled: false,
              ));
              return;
            }
            if (HostedCheckoutUrls.isCancelOrError(url)) {
              widget.onComplete(HostedCheckoutResult(
                success: false,
                paymentId: widget.paymentId,
                cancelled: true,
              ));
            }
          },
          onProgress: (int progress) {
            setState(() => _loadingProgress = progress);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _loadingProgress = 100;
            });
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error al cargar: ${error.description}'),
                  backgroundColor: MBETheme.brandRed,
                ),
              );
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  void _closeWithCancel() {
    widget.onComplete(HostedCheckoutResult(
      success: false,
      paymentId: widget.paymentId,
      cancelled: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title ?? 'Procesando pago';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.close_circle, color: MBETheme.brandBlack),
          onPressed: _closeWithCancel,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: MBETheme.brandBlack,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: _loadingProgress / 100,
                  backgroundColor: MBETheme.lightGray,
                  valueColor: const AlwaysStoppedAnimation<Color>(MBETheme.brandBlack),
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading && _loadingProgress < 100)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(MBETheme.brandBlack),
                    ),
                    const SizedBox(height: MBESpacing.lg),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: MBETheme.brandBlack,
                          ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
