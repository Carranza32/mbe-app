// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'addresses_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(addresses)
const addressesProvider = AddressesProvider._();

final class AddressesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AddressModel>>,
          List<AddressModel>,
          FutureOr<List<AddressModel>>
        >
    with
        $FutureModifier<List<AddressModel>>,
        $FutureProvider<List<AddressModel>> {
  const AddressesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addressesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addressesHash();

  @$internal
  @override
  $FutureProviderElement<List<AddressModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AddressModel>> create(Ref ref) {
    return addresses(ref);
  }
}

String _$addressesHash() => r'0826b72466d4f34a7512086850d8a82eb85d5810';
