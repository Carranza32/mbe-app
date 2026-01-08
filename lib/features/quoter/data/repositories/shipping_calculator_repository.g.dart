// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipping_calculator_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(shippingCalculatorRepository)
const shippingCalculatorRepositoryProvider =
    ShippingCalculatorRepositoryProvider._();

final class ShippingCalculatorRepositoryProvider
    extends
        $FunctionalProvider<
          ShippingCalculatorRepository,
          ShippingCalculatorRepository,
          ShippingCalculatorRepository
        >
    with $Provider<ShippingCalculatorRepository> {
  const ShippingCalculatorRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shippingCalculatorRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shippingCalculatorRepositoryHash();

  @$internal
  @override
  $ProviderElement<ShippingCalculatorRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ShippingCalculatorRepository create(Ref ref) {
    return shippingCalculatorRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShippingCalculatorRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShippingCalculatorRepository>(value),
    );
  }
}

String _$shippingCalculatorRepositoryHash() =>
    r'c2c9e4f5ac370b1b3ebc366dd80d400b96c49e99';
