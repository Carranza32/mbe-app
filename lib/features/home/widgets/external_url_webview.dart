import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../l10n/app_localizations.dart';

/// WebView de pantalla completa para abrir una URL externa (p. ej. registro de casillero).
class ExternalUrlWebView extends StatefulWidget {
  final String url;
  final String? title;
  /// Si true, al terminar de cargar la página hace scroll hasta el final (útil para formularios al pie).
  final bool scrollToBottomOnLoad;

  const ExternalUrlWebView({
    super.key,
    required this.url,
    this.title,
    this.scrollToBottomOnLoad = false,
  });

  @override
  State<ExternalUrlWebView> createState() => _ExternalUrlWebViewState();
}

class _ExternalUrlWebViewState extends State<ExternalUrlWebView> {
  late WebViewController _controller;
  bool _isLoading = true;

  /// Hace scroll al final de la página (formulario suele estar abajo).
  void _scrollToBottom() {
    // Pequeño delay para que el DOM esté estable y contenido dinámico cargado
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _controller.runJavaScript('''
        (function() {
          var h = Math.max(
            document.body.scrollHeight,
            document.documentElement.scrollHeight
          );
          window.scrollTo(0, h);
        })();
      ''');
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            if (widget.scrollToBottomOnLoad) _scrollToBottom();
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title ?? AppLocalizations.of(context)!.homeOpenLink;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Iconsax.close_circle),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
