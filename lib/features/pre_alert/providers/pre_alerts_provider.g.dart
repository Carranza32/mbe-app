// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pre_alerts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PreAlerts)
const preAlertsProvider = PreAlertsProvider._();

final class PreAlertsProvider
    extends $AsyncNotifierProvider<PreAlerts, List<PreAlert>> {
  const PreAlertsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preAlertsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preAlertsHash();

  @$internal
  @override
  PreAlerts create() => PreAlerts();
}

String _$preAlertsHash() => r'8d8fe4f83c9d4fdc9c0a51ca9d83154ca6c32813';

abstract class _$PreAlerts extends $AsyncNotifier<List<PreAlert>> {
  FutureOr<List<PreAlert>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<PreAlert>>, List<PreAlert>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<PreAlert>>, List<PreAlert>>,
              AsyncValue<List<PreAlert>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(hasPendingActions)
const hasPendingActionsProvider = HasPendingActionsProvider._();

final class HasPendingActionsProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  const HasPendingActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasPendingActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasPendingActionsHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasPendingActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasPendingActionsHash() => r'de4166aaa5cc099f5ad8a07f87e23607654b9486';

@ProviderFor(pendingActionsCount)
const pendingActionsCountProvider = PendingActionsCountProvider._();

final class PendingActionsCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  const PendingActionsCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingActionsCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingActionsCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return pendingActionsCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$pendingActionsCountHash() =>
    r'26d332392b94974aa5c96f1bfe61676b05f7c706';
