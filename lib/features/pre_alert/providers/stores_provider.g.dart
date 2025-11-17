// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stores_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Stores)
const storesProvider = StoresProvider._();

final class StoresProvider extends $AsyncNotifierProvider<Stores, List<Store>> {
  const StoresProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storesHash();

  @$internal
  @override
  Stores create() => Stores();
}

String _$storesHash() => r'4953aa4b4939f8fb5c50bc2916539f9d8a17fd42';

abstract class _$Stores extends $AsyncNotifier<List<Store>> {
  FutureOr<List<Store>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Store>>, List<Store>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Store>>, List<Store>>,
              AsyncValue<List<Store>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
