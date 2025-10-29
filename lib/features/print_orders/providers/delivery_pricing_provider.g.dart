// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_pricing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DeliveryPricing)
const deliveryPricingProvider = DeliveryPricingProvider._();

final class DeliveryPricingProvider
    extends $NotifierProvider<DeliveryPricing, DeliveryPricingResult> {
  const DeliveryPricingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deliveryPricingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deliveryPricingHash();

  @$internal
  @override
  DeliveryPricing create() => DeliveryPricing();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeliveryPricingResult value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeliveryPricingResult>(value),
    );
  }
}

String _$deliveryPricingHash() => r'44ad0070b024562c3528f35389ff4a7bcc727598';

abstract class _$DeliveryPricing extends $Notifier<DeliveryPricingResult> {
  DeliveryPricingResult build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DeliveryPricingResult, DeliveryPricingResult>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DeliveryPricingResult, DeliveryPricingResult>,
              DeliveryPricingResult,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
