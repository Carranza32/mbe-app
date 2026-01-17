import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pre_alert_stepper_provider.g.dart';

/// Provider para el paso actual del stepper de pre-alertas
@riverpod
class PreAlertCurrentStep extends _$PreAlertCurrentStep {
  @override
  int build() => 1; // Inicia en el paso 1

  /// Avanzar al siguiente paso
  void next() {
    if (state < 3) {
      state++;
    }
  }

  /// Retroceder al paso anterior
  void previous() {
    if (state > 1) {
      state--;
    }
  }

  /// Ir a un paso específico
  void goToStep(int step) {
    if (step >= 1 && step <= 3) {
      state = step;
    }
  }

  /// Resetear al primer paso
  void reset() {
    state = 1;
  }
}
