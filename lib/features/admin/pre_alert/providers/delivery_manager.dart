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
    required String signature,
    required String deliveredTo,
    required DateTime deliveredAt,
    bool isDifferentReceiver = false,
    String? receiverName,
    String? receiverEmail,
    String? receiverPhone,
  }) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      await repository.processPickupDelivery(
        packageIds: packageIds,
        signature: signature,
        deliveredTo: deliveredTo,
        deliveredAt: deliveredAt,
        isDifferentReceiver: isDifferentReceiver,
        receiverName: receiverName,
        receiverEmail: receiverEmail,
        receiverPhone: receiverPhone,
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
    String? signatureBase64,
  }) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      await repository.processDeliveryDispatch(
        packageIds: packageIds,
        signatureBase64: signatureBase64,
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
