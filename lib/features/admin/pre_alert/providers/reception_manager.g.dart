// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reception_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReceptionManager)
const receptionManagerProvider = ReceptionManagerProvider._();

final class ReceptionManagerProvider
    extends $AsyncNotifierProvider<ReceptionManager, void> {
  const ReceptionManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'receptionManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$receptionManagerHash();

  @$internal
  @override
  ReceptionManager create() => ReceptionManager();
}

String _$receptionManagerHash() => r'8f9f7292b19f7b775e368753cc465374e95f6319';

abstract class _$ReceptionManager extends $AsyncNotifier<void> {
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
