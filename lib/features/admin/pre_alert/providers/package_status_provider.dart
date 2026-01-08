import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/package_status.dart';
import '../data/repositories/admin_pre_alerts_repository.dart';
import 'admin_pre_alerts_provider.dart';

part 'package_status_provider.g.dart';

@riverpod
class PackageStatusManager extends _$PackageStatusManager {
  @override
  FutureOr<void> build() {}

  Future<bool> updateStatus({
    required List<String> packageIds,
    required PackageStatus newStatus,
  }) async {
    state = const AsyncLoading();
    
    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      
      if (packageIds.length == 1) {
        await repository.updateStatus(
          id: packageIds.first,
          status: newStatus,
        );
      } else {
        await repository.bulkUpdateStatus(
          ids: packageIds,
          status: newStatus,
        );
      }
      
      ref.invalidate(adminPreAlertsProvider);
      
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}

