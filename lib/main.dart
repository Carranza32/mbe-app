import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'config/router/app_router.dart';
import 'config/theme/mbe_theme.dart';
import 'core/services/deep_link_service.dart';
import 'core/providers/locale_provider.dart';
import 'l10n/app_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Al abrir desde el link el intent a veces tarda; varios intentos aquí, el splash también espera (stream + polling)
  Uri? initialUri;
  try {
    final appLinks = AppLinks();
    await Future.delayed(const Duration(milliseconds: 150));
    initialUri = await appLinks.getInitialLink();
    for (int i = 0; i < 3 && initialUri == null; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      initialUri = await appLinks.getInitialLink();
    }
    if (initialUri != null &&
        isResetPasswordUri(initialUri) &&
        await wasResetTokenAlreadyUsed(initialUri.queryParameters['token']!)) {
      initialUri = null;
    }
  } catch (_) {}

  runApp(
    ProviderScope(
      overrides: initialUri != null && isResetPasswordUri(initialUri)
          ? [initialDeepLinkUriProvider.overrideWithValue(initialUri)]
          : [],
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDeepLinks();
    });
  }

  void _initializeDeepLinks() {
    final deepLinkService = ref.read(deepLinkServiceProvider);

    // El link inicial ya se resolvió en main() y se usa en initialLocation.
    // Escuchar links nuevos: app en segundo plano → usuario toca el enlace → ir a reset-password.
    deepLinkService.initialize((uri) {
      if (!isResetPasswordUri(uri)) return;
      final token = uri.queryParameters['token']!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        wasResetTokenAlreadyUsed(token).then((used) {
          if (used) return;
          final router = ref.read(appRouterProvider);
          router.go(buildResetPasswordRoute(uri));
        });
      });
    });
  }

  @override
  void dispose() {
    ref.read(deepLinkServiceProvider).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      key: navigatorKey,
      title: 'MBE El Salvador',
      debugShowCheckedModeBanner: false,
      theme: MBETheme.lightTheme,
      // Modo claro siempre: no seguir tema del dispositivo para evitar inputs/labels negros
      themeMode: ThemeMode.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
