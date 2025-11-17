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
    extends $AsyncNotifierProvider<PreAlerts, PreAlertsResponse> {
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

String _$preAlertsHash() => r'8a0fa545c9065bb895a0384fdeb317d6cf8251c4';

abstract class _$PreAlerts extends $AsyncNotifier<PreAlertsResponse> {
  FutureOr<PreAlertsResponse> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<PreAlertsResponse>, PreAlertsResponse>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PreAlertsResponse>, PreAlertsResponse>,
              AsyncValue<PreAlertsResponse>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
