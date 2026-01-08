// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipping_providers_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(shippingProviders)
const shippingProvidersProvider = ShippingProvidersProvider._();

final class ShippingProvidersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ShippingProviderModel>>,
          List<ShippingProviderModel>,
          FutureOr<List<ShippingProviderModel>>
        >
    with
        $FutureModifier<List<ShippingProviderModel>>,
        $FutureProvider<List<ShippingProviderModel>> {
  const ShippingProvidersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shippingProvidersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shippingProvidersHash();

  @$internal
  @override
  $FutureProviderElement<List<ShippingProviderModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ShippingProviderModel>> create(Ref ref) {
    return shippingProviders(ref);
  }
}

String _$shippingProvidersHash() => r'c96e8061fa54f8a734c5333244a9c47866ac9ad4';
