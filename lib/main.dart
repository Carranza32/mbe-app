import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/router/app_router.dart';
import 'config/theme/mbe_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      key: navigatorKey,
      title: 'MBE El Salvador',
      debugShowCheckedModeBanner: false,
      theme: MBETheme.lightTheme,
      darkTheme: MBETheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}