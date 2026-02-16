// lib/core/services/app_preferences.dart
// Preferencias de la app (SharedPreferences). Ej.: si el usuario ya usó la app en este dispositivo.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyHasUsedAppOnThisDevice = 'has_used_app_on_this_device';
const _keyLocale = 'locale';
const _keyLockerRetrievalStoreId = 'locker_retrieval_store_id';

/// True si el usuario ya inició sesión o completó registro al menos una vez en este dispositivo.
/// Se usa para no mostrar el portero (EmailEntryScreen) tras un logout; solo en primera instalación.
Future<bool> getHasUsedAppOnThisDevice() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_keyHasUsedAppOnThisDevice) ?? false;
}

/// Marca que el usuario ya usó la app en este dispositivo (login o registro exitoso).
Future<void> setHasUsedAppOnThisDevice(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_keyHasUsedAppOnThisDevice, value);
}

/// Obtiene el código de idioma guardado (ej: 'es', 'en'). Null si nunca se ha establecido.
Future<String?> getLocaleCode() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_keyLocale);
}

/// Guarda el código de idioma elegido por el usuario.
Future<void> setLocaleCode(String code) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_keyLocale, code);
}

/// ID de la última tienda seleccionada en el módulo Retiro en tienda (casilleros).
/// Null si nunca se ha guardado.
Future<int?> getLockerRetrievalStoreId() async {
  final prefs = await SharedPreferences.getInstance();
  final v = prefs.getInt(_keyLockerRetrievalStoreId);
  return v;
}

/// Guarda la tienda seleccionada en Retiro en tienda.
Future<void> setLockerRetrievalStoreId(int storeId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_keyLockerRetrievalStoreId, storeId);
}

/// DEBUG: Imprime todas las claves y valores de SharedPreferences.
Future<void> debugPrintSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys();
  print('📋 [DEBUG] SharedPreferences: ${keys.length} claves');
  for (final k in keys) {
    final v = prefs.get(k);
    print('   $k = $v');
  }
  if (keys.isEmpty) {
    print('   (vacío)');
  }
}

/// Resetea TODO el almacenamiento (SharedPreferences + SecureStorage).
/// Deja la app como recién instalada: sin token, sin usuario, sin preferencias.
/// ⚠️ DEBUG: Usar solo para pruebas. Comentar en producción.
Future<void> resetAllForDebug() async {
  // SharedPreferences: borrar todo
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  // SecureStorage: borrar auth_token, user, customer
  const storage = FlutterSecureStorage();
  await storage.delete(key: 'auth_token');
  await storage.delete(key: 'user');
  await storage.delete(key: 'customer');
}
