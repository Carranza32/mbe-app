// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Orders)
const ordersProvider = OrdersProvider._();

final class OrdersProvider
    extends $AsyncNotifierProvider<Orders, OrdersResponse> {
  const OrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ordersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ordersHash();

  @$internal
  @override
  Orders create() => Orders();
}

String _$ordersHash() => r'4e6eb3b16547e1727775e0a0282abd4e8ccd1728';

abstract class _$Orders extends $AsyncNotifier<OrdersResponse> {
  FutureOr<OrdersResponse> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<OrdersResponse>, OrdersResponse>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<OrdersResponse>, OrdersResponse>,
              AsyncValue<OrdersResponse>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
