import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/admin_pre_alert_model.dart';
import '../data/models/reception_result.dart';
import '../data/repositories/admin_pre_alerts_repository.dart';
import 'admin_pre_alerts_provider.dart';
import 'context_counts_provider.dart' show contextCountsProvider;

part 'reception_manager.g.dart';

@riverpod
class ReceptionManager extends _$ReceptionManager {
  @override
  FutureOr<void> build() async {}

  /// Buscar paquete por código ebox
  Future<AdminPreAlert?> findPackageByEbox(String eboxCode) async {
    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      final package = await repository.findPackageByEbox(eboxCode);
      return package;
    } catch (e) {
      return null;
    }
  }

  /// Procesar recepción de paquetes escaneados
  /// Cambia estado a en_tienda y asigna rack automáticamente
  Future<ReceptionResult?> processReception({
    required List<String> packageIds,
  }) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      final result = await repository.processReception(
        packageIds: packageIds,
      );

      // Invalidar la lista de pre-alerts y los contadores para refrescar
      ref.invalidate(adminPreAlertsProvider);
      ref.invalidate(contextCountsProvider);

      state = const AsyncData(null);
      return result;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return null;
    }
  }
}

