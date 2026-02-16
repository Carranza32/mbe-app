// lib/core/services/deep_link_service.dart
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'deep_link_service.g.dart';

const _keyUsedResetToken = 'used_reset_password_token';

/// URI del deep link con el que se abrió la app (si aplica).
/// Se usa en main() para dar prioridad al reset-password sobre el splash.
final initialDeepLinkUriProvider = Provider<Uri?>((ref) => null);

/// Indica si [uri] es un deep link de restablecer contraseña válido.
bool isResetPasswordUri(Uri? uri) {
  if (uri == null) return false;
  if (uri.host == 'reset-password' || uri.path == '/reset-password') {
    final token = uri.queryParameters['token'];
    final email = uri.queryParameters['email'];
    return token != null && token.isNotEmpty && email != null && email.isNotEmpty;
  }
  return false;
}

/// Construye la ruta de reset-password a partir del [uri].
String buildResetPasswordRoute(Uri uri) {
  final token = uri.queryParameters['token']!;
  final email = uri.queryParameters['email']!;
  return '/auth/reset-password?token=${Uri.encodeComponent(token)}&email=${Uri.encodeComponent(email)}';
}

/// Marca el [token] de reset como ya usado (ej. después de restablecer contraseña).
/// Así no se vuelve a abrir la pantalla de reset al reiniciar la app.
Future<void> saveUsedResetToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_keyUsedResetToken, token);
}

/// Devuelve true si ese [token] ya se usó para restablecer contraseña.
Future<bool> wasResetTokenAlreadyUsed(String token) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_keyUsedResetToken) == token;
}

@riverpod
DeepLinkService deepLinkService(Ref ref) {
  return DeepLinkService();
}

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  /// Inicializar el servicio de deep linking
  void initialize(Function(Uri) onLink) {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        onLink(uri);
      },
      onError: (err) {
        print('Error en deep link: $err');
      },
    );
  }

  /// Obtener el link inicial (si la app se abrió desde un link)
  Future<Uri?> getInitialLink() async {
    try {
      return await _appLinks.getInitialLink();
    } catch (e) {
      print('Error al obtener link inicial: $e');
      return null;
    }
  }

  /// Espera a recibir un enlace de reset-password (por getInitialLink o por el stream).
  /// Útil en splash: al abrir desde el correo a veces el intent llega por stream o tarda.
  /// Retorna el [Uri] válido o null tras [timeout].
  Future<Uri?> waitForResetPasswordLink({
    Duration timeout = const Duration(milliseconds: 3500),
  }) async {
    final completer = Completer<Uri?>();
    StreamSubscription<Uri>? sub;

    void finish(Uri? u) {
      if (!completer.isCompleted) {
        sub?.cancel();
        completer.complete(u);
      }
    }

    // Escuchar el stream por si el link llega por ahí al abrir desde el correo
    sub = _appLinks.uriLinkStream.listen(
      (uri) async {
        if (!completer.isCompleted &&
            isResetPasswordUri(uri) &&
            !await wasResetTokenAlreadyUsed(uri.queryParameters['token']!)) {
          finish(uri);
        }
      },
      onError: (_) {},
    );

    // Timeout: si no llegó nada, devolver null
    Future.delayed(timeout, () => finish(null));

    // Polling en paralelo por getInitialLink (en cold start a veces tarda)
    Future<void> poll() async {
      while (!completer.isCompleted) {
        try {
          final uri = await getInitialLink();
          if (uri != null &&
              isResetPasswordUri(uri) &&
              !await wasResetTokenAlreadyUsed(uri.queryParameters['token']!)) {
            finish(uri);
            return;
          }
        } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 400));
      }
    }
    poll();

    return completer.future;
  }

  /// Dispose del servicio
  void dispose() {
    _linkSubscription?.cancel();
  }
}
