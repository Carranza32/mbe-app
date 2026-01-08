// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipping_calculator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ShippingCalculator)
const shippingCalculatorProvider = ShippingCalculatorProvider._();

final class ShippingCalculatorProvider
    extends
        $AsyncNotifierProvider<
          ShippingCalculator,
          ShippingCalculationResponse?
        > {
  const ShippingCalculatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shippingCalculatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shippingCalculatorHash();

  @$internal
  @override
  ShippingCalculator create() => ShippingCalculator();
}

String _$shippingCalculatorHash() =>
    r'77a1f8737c1a93c19f5671a2d8dab928bfb92cfa';

abstract class _$ShippingCalculator
    extends $AsyncNotifier<ShippingCalculationResponse?> {
  FutureOr<ShippingCalculationResponse?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<ShippingCalculationResponse?>,
              ShippingCalculationResponse?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ShippingCalculationResponse?>,
                ShippingCalculationResponse?
              >,
              AsyncValue<ShippingCalculationResponse?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
