import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/admin_pre_alerts_repository.dart';
import 'admin_pre_alerts_provider.dart';

part 'delivery_manager.g.dart';

@riverpod
class DeliveryManager extends _$DeliveryManager {
  @override
  FutureOr<void> build() async {}

  /// Procesar entrega pickup (cliente retira en tienda)
  Future<bool> processPickupDelivery({
    required List<String> packageIds,
    required String signaturePath,
    required String deliveredTo,
    required DateTime deliveredAt,
  }) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      await repository.processPickupDelivery(
        packageIds: packageIds,
        signaturePath: signaturePath,
        deliveredTo: deliveredTo,
        deliveredAt: deliveredAt,
      );

      _safeUpdateAfterAsync(() {
        ref.invalidate(adminPreAlertsProvider);
        state = const AsyncData(null);
      });
      return true;
    } catch (e) {
      _safeUpdateAfterAsync(() {
        state = AsyncError(e, StackTrace.current);
      });
      return false;
    }
  }

  /// Procesar entrega delivery (despacho a domicilio)
  Future<bool> processDeliveryDispatch({
    required List<String> packageIds,
    required int shippingProviderId,
    String? providerTrackingNumber,
  }) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      await repository.processDeliveryDispatch(
        packageIds: packageIds,
        shippingProviderId: shippingProviderId,
        providerTrackingNumber: providerTrackingNumber,
      );

      _safeUpdateAfterAsync(() {
        ref.invalidate(adminPreAlertsProvider);
        state = const AsyncData(null);
      });
      return true;
    } catch (e) {
      _safeUpdateAfterAsync(() {
        state = AsyncError(e, StackTrace.current);
      });
      return false;
    }
  }

  /// Evita usar [ref] o [state] después de que el provider fue disposed
  /// (p. ej. usuario cerró el modal antes de que terminara el request).
  void _safeUpdateAfterAsync(void Function() action) {
    try {
      action();
    } catch (_) {
      // Ref/state ya no válidos (provider disposed), ignorar
    }
  }
}

