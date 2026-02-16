// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warehouse_locations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WarehouseLocations)
const warehouseLocationsProvider = WarehouseLocationsFamily._();

final class WarehouseLocationsProvider
    extends
        $AsyncNotifierProvider<WarehouseLocations, List<WarehouseLocation>> {
  const WarehouseLocationsProvider._({
    required WarehouseLocationsFamily super.from,
    required ({
      int storeId,
      bool availableOnly,
      String? rackNumber,
      int? warehouseId,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'warehouseLocationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$warehouseLocationsHash();

  @override
  String toString() {
    return r'warehouseLocationsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  WarehouseLocations create() => WarehouseLocations();

  @override
  bool operator ==(Object other) {
    return other is WarehouseLocationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$warehouseLocationsHash() =>
    r'de40639f6ded7174008cd36da415a0a75d03f821';

final class WarehouseLocationsFamily extends $Family
    with
        $ClassFamilyOverride<
          WarehouseLocations,
          AsyncValue<List<WarehouseLocation>>,
          List<WarehouseLocation>,
          FutureOr<List<WarehouseLocation>>,
          ({
            int storeId,
            bool availableOnly,
            String? rackNumber,
            int? warehouseId,
          })
        > {
  const WarehouseLocationsFamily._()
    : super(
        retry: null,
        name: r'warehouseLocationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WarehouseLocationsProvider call({
    required int storeId,
    bool availableOnly = false,
    String? rackNumber,
    int? warehouseId,
  }) => WarehouseLocationsProvider._(
    argument: (
      storeId: storeId,
      availableOnly: availableOnly,
      rackNumber: rackNumber,
      warehouseId: warehouseId,
    ),
    from: this,
  );

  @override
  String toString() => r'warehouseLocationsProvider';
}

abstract class _$WarehouseLocations
    extends $AsyncNotifier<List<WarehouseLocation>> {
  late final _$args =
      ref.$arg
          as ({
            int storeId,
            bool availableOnly,
            String? rackNumber,
            int? warehouseId,
          });
  int get storeId => _$args.storeId;
  bool get availableOnly => _$args.availableOnly;
  String? get rackNumber => _$args.rackNumber;
  int? get warehouseId => _$args.warehouseId;

  FutureOr<List<WarehouseLocation>> build({
    required int storeId,
    bool availableOnly = false,
    String? rackNumber,
    int? warehouseId,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      storeId: _$args.storeId,
      availableOnly: _$args.availableOnly,
      rackNumber: _$args.rackNumber,
      warehouseId: _$args.warehouseId,
    );
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<WarehouseLocation>>,
              List<WarehouseLocation>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<WarehouseLocation>>,
                List<WarehouseLocation>
              >,
              AsyncValue<List<WarehouseLocation>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
