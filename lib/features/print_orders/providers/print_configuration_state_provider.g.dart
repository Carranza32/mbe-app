// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_configuration_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PrintConfigurationState)
const printConfigurationStateProvider = PrintConfigurationStateProvider._();

final class PrintConfigurationStateProvider
    extends $NotifierProvider<PrintConfigurationState, UserPrintConfiguration> {
  const PrintConfigurationStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'printConfigurationStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$printConfigurationStateHash();

  @$internal
  @override
  PrintConfigurationState create() => PrintConfigurationState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserPrintConfiguration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserPrintConfiguration>(value),
    );
  }
}

String _$printConfigurationStateHash() =>
    r'82fe2071f0f6e5adc041683f83acb7355978d151';

abstract class _$PrintConfigurationState
    extends $Notifier<UserPrintConfiguration> {
  UserPrintConfiguration build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<UserPrintConfiguration, UserPrintConfiguration>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserPrintConfiguration, UserPrintConfiguration>,
              UserPrintConfiguration,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
