// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider para buscar paquetes/clientes para entrega

@ProviderFor(DeliverySearch)
const deliverySearchProvider = DeliverySearchProvider._();

/// Provider para buscar paquetes/clientes para entrega
final class DeliverySearchProvider
    extends $AsyncNotifierProvider<DeliverySearch, DeliverySearchResponse?> {
  /// Provider para buscar paquetes/clientes para entrega
  const DeliverySearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deliverySearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deliverySearchHash();

  @$internal
  @override
  DeliverySearch create() => DeliverySearch();
}

String _$deliverySearchHash() => r'58d8ca6af18be5f317444bbd6c2fbbdb23049e43';

/// Provider para buscar paquetes/clientes para entrega

abstract class _$DeliverySearch
    extends $AsyncNotifier<DeliverySearchResponse?> {
  FutureOr<DeliverySearchResponse?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<DeliverySearchResponse?>,
              DeliverySearchResponse?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<DeliverySearchResponse?>,
                DeliverySearchResponse?
              >,
              AsyncValue<DeliverySearchResponse?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
