import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/admin_pre_alerts_repository.dart';
import 'admin_pre_alerts_provider.dart';

part 'rack_assignment_manager.g.dart';

@riverpod
class RackAssignmentManager extends _$RackAssignmentManager {
  @override
  FutureOr<void> build() async {}

  /// Asignar rack y segmento manualmente a paquetes
  Future<bool> assignRack({
    required List<String> packageIds,
    required String rackNumber,
    required String segmentNumber,
    bool changeToReadyForPickup = false,
  }) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      await repository.assignRack(
        packageIds: packageIds,
        rackNumber: rackNumber,
        segmentNumber: segmentNumber,
        changeToReadyForPickup: changeToReadyForPickup,
      );

      // Invalidar la lista de pre-alerts para refrescar
      ref.invalidate(adminPreAlertsProvider);

      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}

