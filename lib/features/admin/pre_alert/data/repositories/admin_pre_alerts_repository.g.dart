// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_pre_alerts_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminPreAlertsRepository)
const adminPreAlertsRepositoryProvider = AdminPreAlertsRepositoryProvider._();

final class AdminPreAlertsRepositoryProvider
    extends
        $FunctionalProvider<
          AdminPreAlertsRepository,
          AdminPreAlertsRepository,
          AdminPreAlertsRepository
        >
    with $Provider<AdminPreAlertsRepository> {
  const AdminPreAlertsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminPreAlertsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminPreAlertsRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminPreAlertsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdminPreAlertsRepository create(Ref ref) {
    return adminPreAlertsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminPreAlertsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminPreAlertsRepository>(value),
    );
  }
}

String _$adminPreAlertsRepositoryHash() =>
    r'06b832bacd5dd1c243ecc49dbbe683f3a9f0128c';
