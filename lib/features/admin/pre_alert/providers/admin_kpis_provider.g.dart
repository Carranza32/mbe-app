// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_kpis_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminKPIs)
const adminKPIsProvider = AdminKPIsProvider._();

final class AdminKPIsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AdminKPIs>,
          AdminKPIs,
          FutureOr<AdminKPIs>
        >
    with $FutureModifier<AdminKPIs>, $FutureProvider<AdminKPIs> {
  const AdminKPIsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminKPIsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminKPIsHash();

  @$internal
  @override
  $FutureProviderElement<AdminKPIs> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AdminKPIs> create(Ref ref) {
    return adminKPIs(ref);
  }
}

String _$adminKPIsHash() => r'3ec25a5845556d4368a6ad3143da0bf7cfc16507';
