// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_categories_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(productCategories)
const productCategoriesProvider = ProductCategoriesFamily._();

final class ProductCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProductCategory>>,
          List<ProductCategory>,
          FutureOr<List<ProductCategory>>
        >
    with
        $FutureModifier<List<ProductCategory>>,
        $FutureProvider<List<ProductCategory>> {
  const ProductCategoriesProvider._({
    required ProductCategoriesFamily super.from,
    required ({String? search, int perPage}) super.argument,
  }) : super(
         retry: null,
         name: r'productCategoriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productCategoriesHash();

  @override
  String toString() {
    return r'productCategoriesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<ProductCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProductCategory>> create(Ref ref) {
    final argument = this.argument as ({String? search, int perPage});
    return productCategories(
      ref,
      search: argument.search,
      perPage: argument.perPage,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProductCategoriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productCategoriesHash() => r'5f601d4cd3cfcdc3fdc17ca05b55daf79d7f34f0';

final class ProductCategoriesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<ProductCategory>>,
          ({String? search, int perPage})
        > {
  const ProductCategoriesFamily._()
    : super(
        retry: null,
        name: r'productCategoriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProductCategoriesProvider call({String? search, int perPage = 50}) =>
      ProductCategoriesProvider._(
        argument: (search: search, perPage: perPage),
        from: this,
      );

  @override
  String toString() => r'productCategoriesProvider';
}

@ProviderFor(AllProductCategories)
const allProductCategoriesProvider = AllProductCategoriesProvider._();

final class AllProductCategoriesProvider
    extends
        $AsyncNotifierProvider<AllProductCategories, List<ProductCategory>> {
  const AllProductCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allProductCategoriesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allProductCategoriesHash();

  @$internal
  @override
  AllProductCategories create() => AllProductCategories();
}

String _$allProductCategoriesHash() =>
    r'4c0362bd34aabc2a4a493444b48df09fcdd673b3';

abstract class _$AllProductCategories
    extends $AsyncNotifier<List<ProductCategory>> {
  FutureOr<List<ProductCategory>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<ProductCategory>>, List<ProductCategory>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ProductCategory>>,
                List<ProductCategory>
              >,
              AsyncValue<List<ProductCategory>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
