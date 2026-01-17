// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pre_alert_stepper_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider para el paso actual del stepper de pre-alertas

@ProviderFor(PreAlertCurrentStep)
const preAlertCurrentStepProvider = PreAlertCurrentStepProvider._();

/// Provider para el paso actual del stepper de pre-alertas
final class PreAlertCurrentStepProvider
    extends $NotifierProvider<PreAlertCurrentStep, int> {
  /// Provider para el paso actual del stepper de pre-alertas
  const PreAlertCurrentStepProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preAlertCurrentStepProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preAlertCurrentStepHash();

  @$internal
  @override
  PreAlertCurrentStep create() => PreAlertCurrentStep();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$preAlertCurrentStepHash() =>
    r'c9245f6daf8a9ace6c363a74b6b5308e191230f9';

/// Provider para el paso actual del stepper de pre-alertas

abstract class _$PreAlertCurrentStep extends $Notifier<int> {
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
