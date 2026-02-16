// lib/core/providers/locale_provider.dart
// Provider para el idioma de la app. En primera ejecución usa el locale del dispositivo.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/app_preferences.dart';

/// Locales soportados por la app.
const supportedLocales = [Locale('es'), Locale('en')];

/// Códigos soportados para guardar en preferencias.
const supportedLocaleCodes = ['es', 'en'];

/// Provider que expone el Locale actual de la app.
/// En la primera ejecución usa el locale del dispositivo si es es/en; si no, español.
/// Si el usuario eligió un idioma en configuraciones, se usa ese.
final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    _loadLocale();
    return null;
  }

  Future<void> _loadLocale() async {
    final saved = await getLocaleCode();
    if (saved != null && supportedLocaleCodes.contains(saved)) {
      state = Locale(saved);
      return;
    }
    // Primera vez: usar locale del dispositivo
    final device = PlatformDispatcher.instance.locale;
    final deviceCode = device.languageCode.toLowerCase();
    if (supportedLocaleCodes.contains(deviceCode)) {
      state = Locale(deviceCode);
    } else {
      state = const Locale('es');
    }
  }

  /// Cambia el idioma y lo persiste.
  Future<void> setLocale(Locale locale) async {
    final code = locale.languageCode;
    if (!supportedLocaleCodes.contains(code)) return;
    await setLocaleCode(code);
    state = locale;
  }

  /// Cambia el idioma por código ('es' o 'en').
  Future<void> setLocaleByCode(String code) async {
    if (!supportedLocaleCodes.contains(code)) return;
    await setLocaleCode(code);
    state = Locale(code);
  }
}
