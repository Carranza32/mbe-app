import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/admin_pre_alert_model.dart';
import '../data/repositories/admin_pre_alerts_repository.dart';

part 'search_pre_alerts_provider.g.dart';

@riverpod
class SearchPreAlerts extends _$SearchPreAlerts {
  @override
  Future<List<AdminPreAlert>> build() async {
    return [];
  }

  /// Realizar búsqueda de pre-alertas
  /// [searchType] es opcional y se puede usar en el futuro cuando el backend lo soporte
  Future<void> search(String query, {String? searchType}) async {
    if (query.trim().isEmpty) {
      state = const AsyncData([]);
      return;
    }

    state = const AsyncLoading();

    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      final response = await repository.searchPreAlerts(
        query: query.trim(),
        perPage: 50, // Mostrar más resultados en búsqueda
        // searchType: searchType, // Preparado para cuando el backend lo soporte
      );

      state = AsyncData(response.data);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  /// Limpiar búsqueda
  void clear() {
    state = const AsyncData([]);
  }
}

