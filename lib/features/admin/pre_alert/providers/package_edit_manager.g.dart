// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_edit_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PackageEditManager)
const packageEditManagerProvider = PackageEditManagerProvider._();

final class PackageEditManagerProvider
    extends $AsyncNotifierProvider<PackageEditManager, void> {
  const PackageEditManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'packageEditManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$packageEditManagerHash();

  @$internal
  @override
  PackageEditManager create() => PackageEditManager();
}

String _$packageEditManagerHash() =>
    r'c656366783ada02552c055a21944808d123ec301';

abstract class _$PackageEditManager extends $AsyncNotifier<void> {
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
