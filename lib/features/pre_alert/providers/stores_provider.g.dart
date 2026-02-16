// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stores_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider para obtener las tiendas MBE (para recoger paquetes)
/// Usa el endpoint GET /api/v1/stores

@ProviderFor(mbeStores)
const mbeStoresProvider = MbeStoresProvider._();

/// Provider para obtener las tiendas MBE (para recoger paquetes)
/// Usa el endpoint GET /api/v1/stores

final class MbeStoresProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StoreModel>>,
          List<StoreModel>,
          FutureOr<List<StoreModel>>
        >
    with $FutureModifier<List<StoreModel>>, $FutureProvider<List<StoreModel>> {
  /// Provider para obtener las tiendas MBE (para recoger paquetes)
  /// Usa el endpoint GET /api/v1/stores
  const MbeStoresProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mbeStoresProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mbeStoresHash();

  @$internal
  @override
  $FutureProviderElement<List<StoreModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<StoreModel>> create(Ref ref) {
    return mbeStores(ref);
  }
}

String _$mbeStoresHash() => r'29796ef4d14c22451672efa2316f3e4ddfef2032';

/// Provider para obtener los proveedores (tiendas) disponibles para el cliente
/// Usa el endpoint GET /api/v1/providers
/// Por defecto solo devuelve proveedores activos, ordenados por order y luego por name

@ProviderFor(customerStores)
const customerStoresProvider = CustomerStoresProvider._();

/// Provider para obtener los proveedores (tiendas) disponibles para el cliente
/// Usa el endpoint GET /api/v1/providers
/// Por defecto solo devuelve proveedores activos, ordenados por order y luego por name

final class CustomerStoresProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StoreModel>>,
          List<StoreModel>,
          FutureOr<List<StoreModel>>
        >
    with $FutureModifier<List<StoreModel>>, $FutureProvider<List<StoreModel>> {
  /// Provider para obtener los proveedores (tiendas) disponibles para el cliente
  /// Usa el endpoint GET /api/v1/providers
  /// Por defecto solo devuelve proveedores activos, ordenados por order y luego por name
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

String _$customerStoresHash() => r'c9cd155d042e20665b86d2a1aa6e8eb2d9f9444e';

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
