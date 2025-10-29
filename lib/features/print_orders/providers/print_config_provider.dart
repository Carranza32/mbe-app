import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/print_configuration_model.dart';
import '../data/repositories/print_order_repository.dart';

part 'print_config_provider.g.dart';

@riverpod
class PrintConfig extends _$PrintConfig {
  @override
  Future<PrintConfigurationModel> build() async {
    // Cargar configuración al iniciar
    return await ref.read(printOrderRepositoryProvider).getPrintConfig();
  }

  /// Recargar configuración
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(printOrderRepositoryProvider).getPrintConfig();
    });
  }
}