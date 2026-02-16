import 'package:flutter/material.dart';
import 'package:mbe_orders_app/l10n/app_localizations.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../data/models/payment_models.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mbe_orders_app/config/theme/mbe_theme.dart';

class PaymentWebView extends StatefulWidget {
  final String redirectUrl;
  final int paymentId;
  final Function(PaymentResult) onPaymentComplete;

  const PaymentWebView({
    super.key,
    required this.redirectUrl,
    required this.paymentId,
    required this.onPaymentComplete,
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
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

            // Detectar cuando se redirige a la página de éxito/error
            if (url.contains('/payment/success') ||
                url.contains('/payment-result') ||
                url.contains('/payment/cancel') ||
                url.contains('/payment/error')) {
              // El backend procesará el callback
              // Solo detectamos la redirección
              final isSuccess =
                  url.contains('success') ||
                  (url.contains('payment-result') && !url.contains('error'));

              widget.onPaymentComplete(
                PaymentResult(
                  success: isSuccess,
                  paymentId: widget.paymentId,
                  cancelled: url.contains('cancel'),
                ),
              );
            }
          },
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _loadingProgress = 100;
            });
          },
          onWebResourceError: (WebResourceError error) {
            // Manejar errores de carga
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Error al cargar la página: ${error.description}',
                  ),
                  backgroundColor: MBETheme.brandRed,
                ),
              );
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.close_circle, color: MBETheme.brandBlack),
          onPressed: () {
            widget.onPaymentComplete(
              PaymentResult(
                success: false,
                paymentId: widget.paymentId,
                cancelled: true,
              ),
            );
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.preAlertProcessingPayment,
          style: TextStyle(
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
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    MBETheme.brandBlack,
                  ),
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                        MBETheme.brandBlack,
                      ),
                    ),
                    const SizedBox(height: MBESpacing.lg),
                    Text(
                      AppLocalizations.of(context)!.preAlertLoadingPaymentForm,
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
