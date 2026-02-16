import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../pre_alert/data/models/promotion_model.dart';
import '../../pre_alert/data/repositories/pre_alerts_repository.dart';

/// Obtiene la mejor promoción de envío para impresiones (igual que en pre-alertas).
/// [subtotal] es el subtotal del pedido de impresión para evaluar si aplica envío gratis, etc.
final printOrderBestPromotionProvider =
    FutureProvider.family<PromotionModel?, double>((ref, subtotal) async {
  try {
    final repository = ref.read(preAlertsRepositoryProvider);
    final request = BestPromotionRequest(
      storeId: 1,
      serviceType: 'print_order',
      subtotal: subtotal,
      deliveryCost: 2.0,
      appliesTo: 'delivery',
    );
    final response = await repository.getBestPromotion(request: request);
    return response?.data;
  } catch (_) {
    return null;
  }
});
