import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/admin_pre_alerts_repository.dart';
import '../presentation/widgets/context_filter_segmented.dart';

part 'context_counts_provider.g.dart';

@riverpod
class ContextCounts extends _$ContextCounts {
  @override
  Future<Map<PackageContext, int>> build() async {
    final repository = ref.read(adminPreAlertsRepositoryProvider);
    final counts = <PackageContext, int>{};

    try {
      final futures = [
        repository.getPreAlerts(
          statusFilter: 'lista_para_recepcionar',
          perPage: 1,
          page: 1,
        ),
        repository.getPreAlerts(
          statusFilter: 'disponible_para_retiro',
          perPage: 1,
          page: 1,
        ),
        repository.getPreAlerts(
          statusFilter: 'solicitud_recoleccion',
          deliveryMethod: 'delivery',
          perPage: 1,
          page: 1,
        ),
        repository.getPreAlerts(
          statusFilter: 'solicitud_recoleccion',
          deliveryMethod: 'locker',
          perPage: 1,
          page: 1,
        ),
        repository.getPreAlerts(
          statusFilter: 'confirmada_recoleccion',
          deliveryMethod: 'delivery',
          perPage: 1,
          page: 1,
        ),
        repository.getPreAlerts(
          statusFilter: 'confirmada_recoleccion',
          deliveryMethod: 'locker',
          perPage: 1,
          page: 1,
        ),
        repository.getPreAlerts(
          statusFilter: 'en_ruta',
          deliveryMethod: 'delivery',
          perPage: 1,
          page: 1,
        ),
        repository.getPreAlerts(
          statusFilter: 'en_ruta',
          deliveryMethod: 'locker',
          perPage: 1,
          page: 1,
        ),
        repository.getPreAlerts(statusFilter: 'entregado', perPage: 1, page: 1),
      ];

      final results = await Future.wait(futures);
      final solDomicilio = results[2].total;
      final solCasillero = results[3].total;
      final confDomicilio = results[4].total;
      final confCasillero = results[5].total;
      final enRutaDomicilio = results[6].total;
      final enRutaCasillero = results[7].total;

      counts[PackageContext.porRecibir] = results[0].total;
      counts[PackageContext.disponibles] = results[1].total;
      counts[PackageContext.solicitudEnvio] = solDomicilio + solCasillero;
      counts[PackageContext.confirmacionesDeEnvio] =
          confDomicilio + confCasillero;
      counts[PackageContext.enCamino] = enRutaDomicilio + enRutaCasillero;
      counts[PackageContext.entregado] = results[8].total;

      return counts;
    } catch (e) {
      return {
        for (final ctx in PackageContext.values) ctx: 0,
      };
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Sub-counts Domicilio | Casillero para Solicitud envío
@riverpod
class SolicitudEnvioSubCounts extends _$SolicitudEnvioSubCounts {
  @override
  Future<Map<DeliveryMethodSubContext, int>> build() async {
    final repository = ref.read(adminPreAlertsRepositoryProvider);
    try {
      final domicilio = await repository.getPreAlerts(
        statusFilter: 'solicitud_recoleccion',
        deliveryMethod: 'delivery',
        perPage: 1,
        page: 1,
      );
      final casillero = await repository.getPreAlerts(
        statusFilter: 'solicitud_recoleccion',
        deliveryMethod: 'locker',
        perPage: 1,
        page: 1,
      );
      return {
        DeliveryMethodSubContext.domicilio: domicilio.total,
        DeliveryMethodSubContext.casillero: casillero.total,
      };
    } catch (e) {
      return {
        DeliveryMethodSubContext.domicilio: 0,
        DeliveryMethodSubContext.casillero: 0,
      };
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Sub-counts Domicilio | Casillero para Confirmaciones de envío
@riverpod
class ConfirmacionesSubCounts extends _$ConfirmacionesSubCounts {
  @override
  Future<Map<DeliveryMethodSubContext, int>> build() async {
    final repository = ref.read(adminPreAlertsRepositoryProvider);
    try {
      final domicilio = await repository.getPreAlerts(
        statusFilter: 'confirmada_recoleccion',
        deliveryMethod: 'delivery',
        perPage: 1,
        page: 1,
      );
      final casillero = await repository.getPreAlerts(
        statusFilter: 'confirmada_recoleccion',
        deliveryMethod: 'locker',
        perPage: 1,
        page: 1,
      );
      return {
        DeliveryMethodSubContext.domicilio: domicilio.total,
        DeliveryMethodSubContext.casillero: casillero.total,
      };
    } catch (e) {
      return {
        DeliveryMethodSubContext.domicilio: 0,
        DeliveryMethodSubContext.casillero: 0,
      };
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Sub-counts Domicilio | Casillero para En camino
@riverpod
class EnCaminoSubCounts extends _$EnCaminoSubCounts {
  @override
  Future<Map<DeliveryMethodSubContext, int>> build() async {
    final repository = ref.read(adminPreAlertsRepositoryProvider);
    try {
      final domicilio = await repository.getPreAlerts(
        statusFilter: 'en_ruta',
        deliveryMethod: 'delivery',
        perPage: 1,
        page: 1,
      );
      final casillero = await repository.getPreAlerts(
        statusFilter: 'en_ruta',
        deliveryMethod: 'locker',
        perPage: 1,
        page: 1,
      );
      return {
        DeliveryMethodSubContext.domicilio: domicilio.total,
        DeliveryMethodSubContext.casillero: casillero.total,
      };
    } catch (e) {
      return {
        DeliveryMethodSubContext.domicilio: 0,
        DeliveryMethodSubContext.casillero: 0,
      };
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
