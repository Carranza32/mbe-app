// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DeliveryManager)
const deliveryManagerProvider = DeliveryManagerProvider._();

final class DeliveryManagerProvider
    extends $AsyncNotifierProvider<DeliveryManager, void> {
  const DeliveryManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deliveryManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deliveryManagerHash();

  @$internal
  @override
  DeliveryManager create() => DeliveryManager();
}

String _$deliveryManagerHash() => r'ffd4214298960a4250629547cd7d6b38ab252033';

abstract class _$DeliveryManager extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
