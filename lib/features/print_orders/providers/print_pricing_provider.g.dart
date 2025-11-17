// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_pricing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PrintPricing)
const printPricingProvider = PrintPricingProvider._();

final class PrintPricingProvider
    extends $NotifierProvider<PrintPricing, PriceCalculation> {
  const PrintPricingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'printPricingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$printPricingHash();

  @$internal
  @override
  PrintPricing create() => PrintPricing();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PriceCalculation value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PriceCalculation>(value),
    );
  }
}

String _$printPricingHash() => r'd98588ce5a2133c6fbdadaa1364bb21192e04226';

abstract class _$PrintPricing extends $Notifier<PriceCalculation> {
  PriceCalculation build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PriceCalculation, PriceCalculation>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PriceCalculation, PriceCalculation>,
              PriceCalculation,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
