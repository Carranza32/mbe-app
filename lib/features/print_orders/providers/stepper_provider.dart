import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stepper_provider.g.dart';

/// Provider para el paso actual del stepper
@riverpod
class CurrentStep extends _$CurrentStep {
  @override
  int build() => 1; // Inicia en el paso 1

  /// Avanzar al siguiente paso
  void next() {
    if (state < 5) {
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
    if (step >= 1 && step <= 5) {
      state = step;
    }
  }

  /// Resetear al primer paso
  void reset() {
    state = 1;
  }
}