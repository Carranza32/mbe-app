// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirmation_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ConfirmationStateNotifier)
const confirmationStateProvider = ConfirmationStateNotifierProvider._();

final class ConfirmationStateNotifierProvider
    extends $NotifierProvider<ConfirmationStateNotifier, ConfirmationState> {
  const ConfirmationStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'confirmationStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$confirmationStateNotifierHash();

  @$internal
  @override
  ConfirmationStateNotifier create() => ConfirmationStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConfirmationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConfirmationState>(value),
    );
  }
}

String _$confirmationStateNotifierHash() =>
    r'57c639564bbecd1a7b0dfab8a3fb04e1852a6a18';

abstract class _$ConfirmationStateNotifier
    extends $Notifier<ConfirmationState> {
  ConfirmationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ConfirmationState, ConfirmationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConfirmationState, ConfirmationState>,
              ConfirmationState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
