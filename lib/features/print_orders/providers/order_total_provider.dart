// lib/features/print_orders/providers/order_total_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'print_pricing_provider.dart';
import 'delivery_pricing_provider.dart';

part 'order_total_provider.g.dart';

class OrderTotal {
  final double printingTotal;
  final double deliveryTotal;
  final double grandTotal;

  OrderTotal({
    required this.printingTotal,
    required this.deliveryTotal,
    required this.grandTotal,
  });

  OrderTotal.zero()
      : printingTotal = 0,
        deliveryTotal = 0,
        grandTotal = 0;
}

@riverpod
class OrderTotalCalculator extends _$OrderTotalCalculator {
  @override
  OrderTotal build() {
    final printingPricing = ref.watch(printPricingProvider);
    final deliveryPricing = ref.watch(deliveryPricingProvider);  // ← CAMBIO AQUÍ

    final printingTotal = printingPricing.total;
    final deliveryTotal = deliveryPricing.deliveryCost;
    final grandTotal = printingTotal + deliveryTotal;

    return OrderTotal(
      printingTotal: printingTotal,
      deliveryTotal: deliveryTotal,
      grandTotal: grandTotal,
    );
  }
}