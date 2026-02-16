// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main_scaffold_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MainScaffoldKey)
const mainScaffoldKeyProvider = MainScaffoldKeyProvider._();

final class MainScaffoldKeyProvider
    extends $NotifierProvider<MainScaffoldKey, GlobalKey<ScaffoldState>?> {
  const MainScaffoldKeyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mainScaffoldKeyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mainScaffoldKeyHash();

  @$internal
  @override
  MainScaffoldKey create() => MainScaffoldKey();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GlobalKey<ScaffoldState>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GlobalKey<ScaffoldState>?>(value),
    );
  }
}

String _$mainScaffoldKeyHash() => r'9b7960fef3fe6355488e98a1c415c63e8d795f13';

abstract class _$MainScaffoldKey extends $Notifier<GlobalKey<ScaffoldState>?> {
  GlobalKey<ScaffoldState>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<GlobalKey<ScaffoldState>?, GlobalKey<ScaffoldState>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GlobalKey<ScaffoldState>?, GlobalKey<ScaffoldState>?>,
              GlobalKey<ScaffoldState>?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
