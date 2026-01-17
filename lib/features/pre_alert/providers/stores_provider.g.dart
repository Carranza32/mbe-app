// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stores_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider para obtener las tiendas disponibles para el cliente

@ProviderFor(customerStores)
const customerStoresProvider = CustomerStoresProvider._();

/// Provider para obtener las tiendas disponibles para el cliente

final class CustomerStoresProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StoreModel>>,
          List<StoreModel>,
          FutureOr<List<StoreModel>>
        >
    with $FutureModifier<List<StoreModel>>, $FutureProvider<List<StoreModel>> {
  /// Provider para obtener las tiendas disponibles para el cliente
  const CustomerStoresProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customerStoresProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customerStoresHash();

  @$internal
  @override
  $FutureProviderElement<List<StoreModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<StoreModel>> create(Ref ref) {
    return customerStores(ref);
  }
}

String _$customerStoresHash() => r'c1cf06b0eef9c32f3f3a67b40a30a02bf8febfad';

/// Provider que convierte StoreModel a Store para el dropdown

@ProviderFor(allStores)
const allStoresProvider = AllStoresProvider._();

/// Provider que convierte StoreModel a Store para el dropdown

final class AllStoresProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Store>>,
          List<Store>,
          FutureOr<List<Store>>
        >
    with $FutureModifier<List<Store>>, $FutureProvider<List<Store>> {
  /// Provider que convierte StoreModel a Store para el dropdown
  const AllStoresProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allStoresProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allStoresHash();

  @$internal
  @override
  $FutureProviderElement<List<Store>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Store>> create(Ref ref) {
    return allStores(ref);
  }
}

String _$allStoresHash() => r'a4ad07baf8d20a761154bec4fafc639f801257de';
