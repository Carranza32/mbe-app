// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_addresses_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider estable para las direcciones del usuario

@ProviderFor(userAddresses)
const userAddressesProvider = UserAddressesProvider._();

/// Provider estable para las direcciones del usuario

final class UserAddressesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AddressModel>>,
          List<AddressModel>,
          FutureOr<List<AddressModel>>
        >
    with
        $FutureModifier<List<AddressModel>>,
        $FutureProvider<List<AddressModel>> {
  /// Provider estable para las direcciones del usuario
  const UserAddressesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userAddressesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userAddressesHash();

  @$internal
  @override
  $FutureProviderElement<List<AddressModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AddressModel>> create(Ref ref) {
    return userAddresses(ref);
  }
}

String _$userAddressesHash() => r'4c7097634640e8413887ab5f4de58bea6a87090f';
