// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_selection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PackageSelection)
const packageSelectionProvider = PackageSelectionProvider._();

final class PackageSelectionProvider
    extends $NotifierProvider<PackageSelection, Set<String>> {
  const PackageSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'packageSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$packageSelectionHash();

  @$internal
  @override
  PackageSelection create() => PackageSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$packageSelectionHash() => r'fd4a6f2c1c3027708ed0937306d87ddeb5ceac21';

abstract class _$PackageSelection extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
