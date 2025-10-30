// lib/features/print_orders/providers/delivery_pricing_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'print_config_provider.dart';
import 'create_order_provider.dart'; // ✅ CAMBIO
import 'print_pricing_provider.dart';

part 'delivery_pricing_provider.g.dart';

/// Resultado del cálculo de envío
class DeliveryPricingResult {
  final double baseCost;
  final double deliveryCost;
  final double freeDeliveryMinimum;
  final bool isFreeDelivery;
  final String message;

  DeliveryPricingResult({
    required this.baseCost,
    required this.deliveryCost,
    required this.freeDeliveryMinimum,
    required this.isFreeDelivery,
    required this.message,
  });

  DeliveryPricingResult.zero()
      : baseCost = 0,
        deliveryCost = 0,
        freeDeliveryMinimum = 0,
        isFreeDelivery = true,
        message = 'Sin costo de envío';
}

@riverpod
class DeliveryPricing extends _$DeliveryPricing {
  @override
  DeliveryPricingResult build() {
    final configAsync = ref.watch(printConfigProvider);
    // ✅ CAMBIO: Lee desde el provider centralizado
    final orderState = ref.watch(createOrderProvider);
    final orderPricing = ref.watch(printPricingProvider);

    // ✅ CAMBIO: Obtener método de entrega del request
    final deliveryInfo = orderState.request?.deliveryInfo;
    final isPickup = deliveryInfo?.method == 'pickup' || deliveryInfo == null;

    // Si es pickup, no hay costo de envío
    if (isPickup) {
      return DeliveryPricingResult(
        baseCost: 0,
        deliveryCost: 0,
        freeDeliveryMinimum: 0,
        isFreeDelivery: true,
        message: 'Sin costo adicional',
      );
    }

    return configAsync.when(
      data: (configModel) {
        final deliveryConfig = configModel.config?.delivery;
        if (deliveryConfig == null) {
          return DeliveryPricingResult.zero();
        }

        final baseCost = (deliveryConfig.baseCost ?? 0).toDouble();
        final freeDeliveryMinimum = (deliveryConfig.freeDeliveryMinimum ?? 0).toDouble();
        final orderTotal = orderPricing.total;

        // Verificar si califica para envío gratis
        final isFree = orderTotal >= freeDeliveryMinimum;
        final deliveryCost = isFree ? 0.0 : baseCost;

        final message = isFree
            ? '¡Envío gratis! (pedido mayor a \$${freeDeliveryMinimum.toStringAsFixed(2)})'
            : 'Costo de envío: \$${deliveryCost.toStringAsFixed(2)}';

        return DeliveryPricingResult(
          baseCost: baseCost,
          deliveryCost: deliveryCost,
          freeDeliveryMinimum: freeDeliveryMinimum,
          isFreeDelivery: isFree,
          message: message,
        );
      },
      loading: () => DeliveryPricingResult.zero(),
      error: (_, __) => DeliveryPricingResult.zero(),
    );
  }

  /// Obtener info de delivery config
  Map<String, dynamic> getDeliveryInfo() {
    final configAsync = ref.read(printConfigProvider);
    
    return configAsync.when(
      data: (configModel) {
        final deliveryConfig = configModel.config?.delivery;
        return {
          'baseCost': (deliveryConfig?.baseCost ?? 0).toDouble(),
          'freeDeliveryMinimum': (deliveryConfig?.freeDeliveryMinimum ?? 0).toDouble(),
          'estimatedDays': '1-2 días hábiles',
        };
      },
      loading: () => {},
      error: (_, __) => {},
    );
  }
}