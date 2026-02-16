import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/warehouse_location_model.dart';
import '../data/repositories/admin_pre_alerts_repository.dart';

part 'warehouse_locations_provider.g.dart';

@riverpod
class WarehouseLocations extends _$WarehouseLocations {
  @override
  Future<List<WarehouseLocation>> build({
    required int storeId,
    bool availableOnly = false,
    String? rackNumber,
    int? warehouseId,
  }) async {
    final repository = ref.read(adminPreAlertsRepositoryProvider);
    return await repository.getStoreWarehouseLocations(
      storeId: storeId,
      availableOnly: availableOnly,
      rackNumber: rackNumber,
      warehouseId: warehouseId,
    );
  }

  Future<void> refresh({
    required int storeId,
    bool availableOnly = false,
    String? rackNumber,
    int? warehouseId,
  }) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      final locations = await repository.getStoreWarehouseLocations(
        storeId: storeId,
        availableOnly: availableOnly,
        rackNumber: rackNumber,
        warehouseId: warehouseId,
      );
      state = AsyncData(locations);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}

