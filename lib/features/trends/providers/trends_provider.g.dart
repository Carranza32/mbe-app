// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trends_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(trends)
const trendsProvider = TrendsProvider._();

final class TrendsProvider
    extends
        $FunctionalProvider<
          AsyncValue<TrendsData>,
          TrendsData,
          FutureOr<TrendsData>
        >
    with $FutureModifier<TrendsData>, $FutureProvider<TrendsData> {
  const TrendsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trendsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trendsHash();

  @$internal
  @override
  $FutureProviderElement<TrendsData> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<TrendsData> create(Ref ref) {
    return trends(ref);
  }
}

String _$trendsHash() => r'c76df6af36f5d579083e25fbd0cfac9a92b4ec0e';
