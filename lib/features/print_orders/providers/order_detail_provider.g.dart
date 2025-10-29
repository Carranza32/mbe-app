// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OrderDetail)
const orderDetailProvider = OrderDetailFamily._();

final class OrderDetailProvider
    extends $AsyncNotifierProvider<OrderDetail, PrintOrderDetail> {
  const OrderDetailProvider._({
    required OrderDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'orderDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderDetailHash();

  @override
  String toString() {
    return r'orderDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  OrderDetail create() => OrderDetail();

  @override
  bool operator ==(Object other) {
    return other is OrderDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderDetailHash() => r'af882f124b257276a79d3fba93ffdf8daafe93a0';

final class OrderDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          OrderDetail,
          AsyncValue<PrintOrderDetail>,
          PrintOrderDetail,
          FutureOr<PrintOrderDetail>,
          String
        > {
  const OrderDetailFamily._()
    : super(
        retry: null,
        name: r'orderDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OrderDetailProvider call(String orderNumber) =>
      OrderDetailProvider._(argument: orderNumber, from: this);

  @override
  String toString() => r'orderDetailProvider';
}

abstract class _$OrderDetail extends $AsyncNotifier<PrintOrderDetail> {
  late final _$args = ref.$arg as String;
  String get orderNumber => _$args;

  FutureOr<PrintOrderDetail> build(String orderNumber);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<AsyncValue<PrintOrderDetail>, PrintOrderDetail>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PrintOrderDetail>, PrintOrderDetail>,
              AsyncValue<PrintOrderDetail>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
