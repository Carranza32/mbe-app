// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pre_alerts_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(preAlertsRepository)
const preAlertsRepositoryProvider = PreAlertsRepositoryProvider._();

final class PreAlertsRepositoryProvider
    extends
        $FunctionalProvider<
          PreAlertsRepository,
          PreAlertsRepository,
          PreAlertsRepository
        >
    with $Provider<PreAlertsRepository> {
  const PreAlertsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preAlertsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preAlertsRepositoryHash();

  @$internal
  @override
  $ProviderElement<PreAlertsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PreAlertsRepository create(Ref ref) {
    return preAlertsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreAlertsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PreAlertsRepository>(value),
    );
  }
}

String _$preAlertsRepositoryHash() =>
    r'a63bf9fd74b020e16067edb2eb5d9ea88c8fe161';
