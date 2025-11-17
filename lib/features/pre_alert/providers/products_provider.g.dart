// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Products)
const productsProvider = ProductsProvider._();

final class ProductsProvider
    extends $AsyncNotifierProvider<Products, List<Product>> {
  const ProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productsHash();

  @$internal
  @override
  Products create() => Products();
}

String _$productsHash() => r'e3293b0e4b7e31201aa98bd5ec84f69bb4efb0bd';

abstract class _$Products extends $AsyncNotifier<List<Product>> {
  FutureOr<List<Product>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Product>>, List<Product>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Product>>, List<Product>>,
              AsyncValue<List<Product>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
