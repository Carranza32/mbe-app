// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CompleteProfile)
const completeProfileProvider = CompleteProfileProvider._();

final class CompleteProfileProvider
    extends $NotifierProvider<CompleteProfile, CompleteProfileState> {
  const CompleteProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'completeProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$completeProfileHash();

  @$internal
  @override
  CompleteProfile create() => CompleteProfile();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CompleteProfileState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CompleteProfileState>(value),
    );
  }
}

String _$completeProfileHash() => r'9bd2df4c6a38e024f99b9d450049da849ea3dfbf';

abstract class _$CompleteProfile extends $Notifier<CompleteProfileState> {
  CompleteProfileState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CompleteProfileState, CompleteProfileState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CompleteProfileState, CompleteProfileState>,
              CompleteProfileState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
