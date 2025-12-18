import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/package_status.dart';
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
      await Future.delayed(const Duration(seconds: 1));
      
      final alertsProvider = ref.read(adminPreAlertsProvider.notifier);
      final currentData = ref.read(adminPreAlertsProvider).value ?? [];
      
      final updatedData = currentData.map((alert) {
        if (packageIds.contains(alert.id)) {
          return alert.copyWith(
            status: newStatus,
            exportedAt: newStatus == PackageStatus.exported 
                ? DateTime.now() 
                : alert.exportedAt,
          );
        }
        return alert;
      }).toList();
      
      alertsProvider.state = AsyncData(updatedData);
      
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}

