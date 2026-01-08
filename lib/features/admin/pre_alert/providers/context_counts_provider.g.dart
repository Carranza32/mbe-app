// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context_counts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ContextCounts)
const contextCountsProvider = ContextCountsProvider._();

final class ContextCountsProvider
    extends $AsyncNotifierProvider<ContextCounts, Map<PackageContext, int>> {
  const ContextCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contextCountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contextCountsHash();

  @$internal
  @override
  ContextCounts create() => ContextCounts();
}

String _$contextCountsHash() => r'2422aa8dd6725d72afffb95b2e5e768007a93851';

abstract class _$ContextCounts
    extends $AsyncNotifier<Map<PackageContext, int>> {
  FutureOr<Map<PackageContext, int>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Map<PackageContext, int>>,
              Map<PackageContext, int>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<PackageContext, int>>,
                Map<PackageContext, int>
              >,
              AsyncValue<Map<PackageContext, int>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
