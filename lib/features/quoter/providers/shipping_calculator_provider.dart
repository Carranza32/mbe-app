import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/shipping_calculation_model.dart';
import '../data/repositories/shipping_calculator_repository.dart';

part 'shipping_calculator_provider.g.dart';

@riverpod
class ShippingCalculator extends _$ShippingCalculator {
  @override
  Future<ShippingCalculationResponse?> build() async {
    return null;
  }

  Future<void> calculate({
    required double weight,
    required double value,
    required int productCategoryId,
    int? storeId,
    int? customerId,
    String? countryCode,
  }) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(shippingCalculatorRepositoryProvider);
      final result = await repository.calculate(
        weight: weight,
        value: value,
        productCategoryId: productCategoryId,
        storeId: storeId,
        customerId: customerId,
        countryCode: countryCode,
      );

      state = AsyncData(result);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  void clear() {
    state = const AsyncData(null);
  }
}

