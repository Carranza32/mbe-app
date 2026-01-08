import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/admin_pre_alerts_repository.dart';
import 'admin_pre_alerts_provider.dart';

part 'package_edit_manager.g.dart';

@riverpod
class PackageEditManager extends _$PackageEditManager {
  @override
  FutureOr<void> build() async {}

  /// Actualizar información de un paquete
  Future<bool> updatePackage({
    required String packageId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      await repository.updatePackage(
        id: packageId,
        updates: updates,
      );

      // Invalidar la lista de pre-alerts para refrescar solo si el provider sigue activo
      if (ref.exists(adminPreAlertsProvider)) {
        ref.invalidate(adminPreAlertsProvider);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Subir documento/archivo a un paquete
  Future<bool> uploadDocument({
    required String packageId,
    required String filePath,
    String? documentType,
  }) async {
    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      await repository.uploadDocument(
        id: packageId,
        filePath: filePath,
        documentType: documentType,
      );

      // Invalidar la lista de pre-alerts para refrescar solo si el provider sigue activo
      if (ref.exists(adminPreAlertsProvider)) {
        ref.invalidate(adminPreAlertsProvider);
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}

