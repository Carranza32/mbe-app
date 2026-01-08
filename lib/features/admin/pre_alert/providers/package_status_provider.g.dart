// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PackageStatusManager)
const packageStatusManagerProvider = PackageStatusManagerProvider._();

final class PackageStatusManagerProvider
    extends $AsyncNotifierProvider<PackageStatusManager, void> {
  const PackageStatusManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'packageStatusManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$packageStatusManagerHash();

  @$internal
  @override
  PackageStatusManager create() => PackageStatusManager();
}

String _$packageStatusManagerHash() =>
    r'f3f6874e6823b26f86b48398cdc0ddecf502ddbd';

abstract class _$PackageStatusManager extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
