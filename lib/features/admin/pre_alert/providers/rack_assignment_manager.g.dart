// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rack_assignment_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RackAssignmentManager)
const rackAssignmentManagerProvider = RackAssignmentManagerProvider._();

final class RackAssignmentManagerProvider
    extends $AsyncNotifierProvider<RackAssignmentManager, void> {
  const RackAssignmentManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rackAssignmentManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rackAssignmentManagerHash();

  @$internal
  @override
  RackAssignmentManager create() => RackAssignmentManager();
}

String _$rackAssignmentManagerHash() =>
    r'001b1072f8d78bd8f86c56aeeb63f545c04bd719';

abstract class _$RackAssignmentManager extends $AsyncNotifier<void> {
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
