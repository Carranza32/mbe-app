// lib/core/providers/biometric_preference_provider.dart
// Provider para la preferencia de ingreso biométrico (huella/Face ID).

import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/app_preferences.dart';

final biometricPreferenceProvider =
    NotifierProvider<BiometricPreferenceNotifier, AsyncValue<bool>>(
  BiometricPreferenceNotifier.new,
);

class BiometricPreferenceNotifier extends Notifier<AsyncValue<bool>> {
  @override
  AsyncValue<bool> build() {
    _load();
    return const AsyncValue.loading();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final value = await getBiometricLoginEnabled();
      state = AsyncValue.data(value);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Activa o desactiva el ingreso biométrico.
  Future<void> setEnabled(bool value) async {
    await setBiometricLoginEnabled(value);
    state = AsyncValue.data(value);
  }

  /// Recarga el valor desde almacenamiento.
  Future<void> refresh() => _load();
}
