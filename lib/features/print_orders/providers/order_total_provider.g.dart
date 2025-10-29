// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_total_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OrderTotalCalculator)
const orderTotalCalculatorProvider = OrderTotalCalculatorProvider._();

final class OrderTotalCalculatorProvider
    extends $NotifierProvider<OrderTotalCalculator, OrderTotal> {
  const OrderTotalCalculatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderTotalCalculatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderTotalCalculatorHash();

  @$internal
  @override
  OrderTotalCalculator create() => OrderTotalCalculator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrderTotal value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrderTotal>(value),
    );
  }
}

String _$orderTotalCalculatorHash() =>
    r'4ae23e6bba63a73f6a2083734c5798203dbce7ec';

abstract class _$OrderTotalCalculator extends $Notifier<OrderTotal> {
  OrderTotal build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<OrderTotal, OrderTotal>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OrderTotal, OrderTotal>,
              OrderTotal,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
