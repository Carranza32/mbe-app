import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/pre_alert_model.dart';
import '../data/repositories/pre_alerts_repository.dart';

part 'pre_alerts_provider.g.dart';

@riverpod
class PreAlerts extends _$PreAlerts {
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<PreAlert> _allItems = [];

  @override
  Future<List<PreAlert>> build() async {
    // Evitar múltiples llamadas simultáneas
    if (_isLoadingMore) {
      // Si ya está cargando, retornar los items actuales
      return _allItems;
    }
    
    _currentPage = 1;
    _hasMore = true;
    _allItems = [];
    return await _loadPage(1);
  }

  Future<List<PreAlert>> _loadPage(int page) async {
    if (_isLoadingMore && page > 1) return _allItems;

    _isLoadingMore = true;
    try {
      final repository = ref.read(preAlertsRepositoryProvider);
      final response = await repository.getPreAlerts(
        page: page,
        perPage: 15,
      );

      if (page == 1) {
        _allItems = List.from(response.data);
      } else {
        _allItems = [..._allItems, ...response.data];
      }

      _currentPage = response.currentPage;
      _hasMore = response.hasMorePages;

      // Debug: imprimir información de la respuesta
      print(
        '📦 Cargados ${response.data.length} pre-alertas de ${response.total} totales',
      );
      print('📄 Página ${response.currentPage} de ${response.lastPage}');

      return List.from(_allItems);
    } catch (e, stackTrace) {
      // Si hay error, lanzarlo para que se muestre en el estado
      print('❌ Error al cargar pre-alertas: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    final currentState = state.value;
    if (currentState == null) return;

    final nextPage = _currentPage + 1;
    await _loadPage(nextPage);

    state = AsyncData([..._allItems]);
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _hasMore = true;
    _allItems = [];
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
}

// Provider para detectar si hay pre-alertas que requieren acción
@riverpod
bool hasPendingActions(Ref ref) {
  final preAlertsState = ref.watch(preAlertsProvider);
  
  return preAlertsState.when(
    data: (preAlerts) {
      return preAlerts.any((preAlert) => preAlert.requiresAction);
    },
    loading: () => false,
    error: (_, __) => false,
  );
}

// Provider para obtener el número de pre-alertas que requieren acción
@riverpod
int pendingActionsCount(Ref ref) {
  final preAlertsState = ref.watch(preAlertsProvider);
  
  return preAlertsState.when(
    data: (preAlerts) {
      return preAlerts.where((preAlert) => preAlert.requiresAction).length;
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
}
