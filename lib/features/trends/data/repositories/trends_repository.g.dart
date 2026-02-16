// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trends_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(trendsRepository)
const trendsRepositoryProvider = TrendsRepositoryProvider._();

final class TrendsRepositoryProvider
    extends
        $FunctionalProvider<
          TrendsRepository,
          TrendsRepository,
          TrendsRepository
        >
    with $Provider<TrendsRepository> {
  const TrendsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trendsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trendsRepositoryHash();

  @$internal
  @override
  $ProviderElement<TrendsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TrendsRepository create(Ref ref) {
    return trendsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrendsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrendsRepository>(value),
    );
  }
}

String _$trendsRepositoryHash() => r'b6527fa9972dd64b99a1014f49af3da6a6d4e58a';
