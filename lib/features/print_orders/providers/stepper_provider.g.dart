// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stepper_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider para el paso actual del stepper

@ProviderFor(CurrentStep)
const currentStepProvider = CurrentStepProvider._();

/// Provider para el paso actual del stepper
final class CurrentStepProvider extends $NotifierProvider<CurrentStep, int> {
  /// Provider para el paso actual del stepper
  const CurrentStepProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentStepProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentStepHash();

  @$internal
  @override
  CurrentStep create() => CurrentStep();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$currentStepHash() => r'121182bb66d39ccfa9c4eee5f85978ce143e5a06';

/// Provider para el paso actual del stepper

abstract class _$CurrentStep extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
