// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DeliveryState)
const deliveryStateProvider = DeliveryStateProvider._();

final class DeliveryStateProvider
    extends $NotifierProvider<DeliveryState, UserDeliveryState> {
  const DeliveryStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deliveryStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deliveryStateHash();

  @$internal
  @override
  DeliveryState create() => DeliveryState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserDeliveryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserDeliveryState>(value),
    );
  }
}

String _$deliveryStateHash() => r'e43d3b05ce4fb8629dc16bf82d8d0b0a2fc88616';

abstract class _$DeliveryState extends $Notifier<UserDeliveryState> {
  UserDeliveryState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<UserDeliveryState, UserDeliveryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserDeliveryState, UserDeliveryState>,
              UserDeliveryState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
