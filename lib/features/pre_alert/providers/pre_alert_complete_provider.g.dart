// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pre_alert_complete_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider para el estado de completar pre-alerta

@ProviderFor(PreAlertComplete)
const preAlertCompleteProvider = PreAlertCompleteFamily._();

/// Provider para el estado de completar pre-alerta
final class PreAlertCompleteProvider
    extends $NotifierProvider<PreAlertComplete, PreAlertCompleteState> {
  /// Provider para el estado de completar pre-alerta
  const PreAlertCompleteProvider._({
    required PreAlertCompleteFamily super.from,
    required PreAlert super.argument,
  }) : super(
         retry: null,
         name: r'preAlertCompleteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$preAlertCompleteHash();

  @override
  String toString() {
    return r'preAlertCompleteProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PreAlertComplete create() => PreAlertComplete();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreAlertCompleteState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PreAlertCompleteState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PreAlertCompleteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$preAlertCompleteHash() => r'135c59ba249dcf980c0ec002e6124f63ec9a7cae';

/// Provider para el estado de completar pre-alerta

final class PreAlertCompleteFamily extends $Family
    with
        $ClassFamilyOverride<
          PreAlertComplete,
          PreAlertCompleteState,
          PreAlertCompleteState,
          PreAlertCompleteState,
          PreAlert
        > {
  const PreAlertCompleteFamily._()
    : super(
        retry: null,
        name: r'preAlertCompleteProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider para el estado de completar pre-alerta

  PreAlertCompleteProvider call(PreAlert preAlert) =>
      PreAlertCompleteProvider._(argument: preAlert, from: this);

  @override
  String toString() => r'preAlertCompleteProvider';
}

/// Provider para el estado de completar pre-alerta

abstract class _$PreAlertComplete extends $Notifier<PreAlertCompleteState> {
  late final _$args = ref.$arg as PreAlert;
  PreAlert get preAlert => _$args;

  PreAlertCompleteState build(PreAlert preAlert);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<PreAlertCompleteState, PreAlertCompleteState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PreAlertCompleteState, PreAlertCompleteState>,
              PreAlertCompleteState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
