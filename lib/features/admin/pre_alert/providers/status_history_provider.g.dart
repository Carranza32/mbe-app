// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(statusHistory)
const statusHistoryProvider = StatusHistoryFamily._();

final class StatusHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StatusHistoryItem>>,
          List<StatusHistoryItem>,
          FutureOr<List<StatusHistoryItem>>
        >
    with
        $FutureModifier<List<StatusHistoryItem>>,
        $FutureProvider<List<StatusHistoryItem>> {
  const StatusHistoryProvider._({
    required StatusHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'statusHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$statusHistoryHash();

  @override
  String toString() {
    return r'statusHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<StatusHistoryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<StatusHistoryItem>> create(Ref ref) {
    final argument = this.argument as String;
    return statusHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StatusHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$statusHistoryHash() => r'd19f3a07ab59f02c91de7e6cac790abcf9c2c606';

final class StatusHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<StatusHistoryItem>>, String> {
  const StatusHistoryFamily._()
    : super(
        retry: null,
        name: r'statusHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StatusHistoryProvider call(String packageId) =>
      StatusHistoryProvider._(argument: packageId, from: this);

  @override
  String toString() => r'statusHistoryProvider';
}
