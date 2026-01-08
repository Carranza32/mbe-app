// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_pre_alerts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchPreAlerts)
const searchPreAlertsProvider = SearchPreAlertsProvider._();

final class SearchPreAlertsProvider
    extends $AsyncNotifierProvider<SearchPreAlerts, List<AdminPreAlert>> {
  const SearchPreAlertsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchPreAlertsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchPreAlertsHash();

  @$internal
  @override
  SearchPreAlerts create() => SearchPreAlerts();
}

String _$searchPreAlertsHash() => r'874e7ca0cad3e59786f4bb0a2766bd769e1cc638';

abstract class _$SearchPreAlerts extends $AsyncNotifier<List<AdminPreAlert>> {
  FutureOr<List<AdminPreAlert>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<AdminPreAlert>>, List<AdminPreAlert>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AdminPreAlert>>, List<AdminPreAlert>>,
              AsyncValue<List<AdminPreAlert>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
