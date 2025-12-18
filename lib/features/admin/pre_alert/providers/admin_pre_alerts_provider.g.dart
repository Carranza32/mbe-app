// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_pre_alerts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AdminPreAlerts)
const adminPreAlertsProvider = AdminPreAlertsProvider._();

final class AdminPreAlertsProvider
    extends $AsyncNotifierProvider<AdminPreAlerts, List<AdminPreAlert>> {
  const AdminPreAlertsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminPreAlertsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminPreAlertsHash();

  @$internal
  @override
  AdminPreAlerts create() => AdminPreAlerts();
}

String _$adminPreAlertsHash() => r'0d8e8f371c1ec37d59793cacb06e6a7a38d10843';

abstract class _$AdminPreAlerts extends $AsyncNotifier<List<AdminPreAlert>> {
  FutureOr<List<AdminPreAlert>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<AdminPreAlert>>, List<AdminPreAlert>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AdminPreAlert>>, List<AdminPreAlert>>,
              AsyncValue<List<AdminPreAlert>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
