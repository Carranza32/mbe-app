// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateOrder)
const createOrderProvider = CreateOrderProvider._();

final class CreateOrderProvider
    extends $NotifierProvider<CreateOrder, CreateOrderState> {
  const CreateOrderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createOrderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createOrderHash();

  @$internal
  @override
  CreateOrder create() => CreateOrder();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateOrderState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateOrderState>(value),
    );
  }
}

String _$createOrderHash() => r'aa767a37db031beaa3114bf53ef81dab091e5b31';

abstract class _$CreateOrder extends $Notifier<CreateOrderState> {
  CreateOrderState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CreateOrderState, CreateOrderState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CreateOrderState, CreateOrderState>,
              CreateOrderState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
