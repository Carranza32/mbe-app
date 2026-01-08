// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_pre_alert_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreatePreAlert)
const createPreAlertProvider = CreatePreAlertProvider._();

final class CreatePreAlertProvider
    extends $NotifierProvider<CreatePreAlert, CreatePreAlertState> {
  const CreatePreAlertProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createPreAlertProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createPreAlertHash();

  @$internal
  @override
  CreatePreAlert create() => CreatePreAlert();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreatePreAlertState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreatePreAlertState>(value),
    );
  }
}

String _$createPreAlertHash() => r'743e3aca13c33dbdcca438921435b362607cc0d9';

abstract class _$CreatePreAlert extends $Notifier<CreatePreAlertState> {
  CreatePreAlertState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CreatePreAlertState, CreatePreAlertState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CreatePreAlertState, CreatePreAlertState>,
              CreatePreAlertState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
