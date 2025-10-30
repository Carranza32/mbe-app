// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_processor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OrderProcessor)
const orderProcessorProvider = OrderProcessorProvider._();

final class OrderProcessorProvider
    extends $NotifierProvider<OrderProcessor, OrderProcessingState> {
  const OrderProcessorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderProcessorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderProcessorHash();

  @$internal
  @override
  OrderProcessor create() => OrderProcessor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrderProcessingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrderProcessingState>(value),
    );
  }
}

String _$orderProcessorHash() => r'ea902bff4ec415674be6e9e0fbe8ca181a6a9c57';

abstract class _$OrderProcessor extends $Notifier<OrderProcessingState> {
  OrderProcessingState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<OrderProcessingState, OrderProcessingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OrderProcessingState, OrderProcessingState>,
              OrderProcessingState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
