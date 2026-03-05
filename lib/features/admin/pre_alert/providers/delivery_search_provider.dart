import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/delivery_search_response.dart';
import '../data/repositories/admin_pre_alerts_repository.dart';

part 'delivery_search_provider.g.dart';

/// Provider para buscar paquetes/clientes para entrega
@riverpod
class DeliverySearch extends _$DeliverySearch {
  @override
  Future<DeliverySearchResponse?> build() async {
    return null;
  }

  /// Buscar paquete por tracking/ebox code.
  /// Retorna el resultado directamente para evitar depender del estado
  /// (el provider es AutoDispose y puede no tener listeners).
  Future<DeliverySearchResponse?> searchPackage(String code) async {
    if (code.trim().isEmpty) {
      if (ref.mounted) state = const AsyncData(null);
      return null;
    }

    if (ref.mounted) state = const AsyncLoading();

    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      final result = await repository.searchForDelivery(
        type: 'package',
        code: code.trim(),
      );
      if (ref.mounted) state = AsyncData(result);
      return result;
    } catch (e, st) {
      if (ref.mounted) state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Buscar cliente por código de casillero (ej: SAL0101).
  /// Retorna la respuesta con deliverablePackages para validar escaneos.
  Future<DeliverySearchResponse?> searchCustomer(String code) async {
    if (code.trim().isEmpty) {
      if (ref.mounted) state = const AsyncData(null);
      return null;
    }

    if (ref.mounted) state = const AsyncLoading();

    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      final result = await repository.searchForDelivery(
        type: 'customer',
        code: code.trim(),
      );
      if (ref.mounted) state = AsyncData(result);
      return result;
    } catch (e, st) {
      if (ref.mounted) state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Limpiar resultados
  void clear() {
    state = const AsyncData(null);
  }
}
