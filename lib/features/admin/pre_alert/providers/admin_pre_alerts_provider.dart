import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/admin_pre_alert_model.dart';
import '../data/models/package_status.dart';
import '../data/repositories/admin_pre_alerts_repository.dart';
import '../presentation/widgets/context_filter_segmented.dart';

part 'admin_pre_alerts_provider.g.dart';

@riverpod
class AdminPreAlerts extends _$AdminPreAlerts {
  String? _currentStatusFilter;
  String? _currentDeliveryMethod;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<AdminPreAlert> _allItems = [];

  @override
  Future<List<AdminPreAlert>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _allItems = [];

    if (_currentStatusFilter == null) {
      _currentStatusFilter = PackageContext.porRecibir.statusFilter;
      _currentDeliveryMethod = null;
    }

    return await _loadPage(1);
  }

  Future<List<AdminPreAlert>> _loadPage(int page) async {
    if (_isLoadingMore && page > 1) return _allItems;

    _isLoadingMore = true;
    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      final response = await repository.getPreAlerts(
        statusFilter: _currentStatusFilter,
        deliveryMethod: _currentDeliveryMethod,
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

      return List.from(_allItems);
    } catch (e, stackTrace) {
      print('❌ Error al cargar paquetes: $e');
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

  /// Filtrar por contexto. Cuando tiene sub-pills (solicitudEnvio, confirmacionesDeEnvio, enCamino), usar deliveryMethodSub
  void filterByContext(
    PackageContext context, {
    DeliveryMethodSubContext? deliveryMethodSub,
  }) {
    _currentStatusFilter = context.statusFilter;
    if (ContextFilterSegmented.hasSubPills(context) &&
        deliveryMethodSub != null) {
      _currentDeliveryMethod = deliveryMethodSub.deliveryMethod;
    } else {
      _currentDeliveryMethod = null;
    }
    state = const AsyncLoading();
    ref.invalidateSelf();
  }

  void filterByStatus(PackageStatus? status) {
    _currentStatusFilter = status?.key;
    _currentDeliveryMethod = null;
    ref.invalidateSelf();
  }

  void search(String query) {
    if (query.isEmpty) {
      ref.invalidateSelf();
      return;
    }
    final lowerQuery = query.toLowerCase();
    final filtered = _allItems.where((p) {
      return p.trackingNumber.toLowerCase().contains(lowerQuery) ||
          p.eboxCode.toLowerCase().contains(lowerQuery) ||
          p.clientName.toLowerCase().contains(lowerQuery) ||
          p.provider.toLowerCase().contains(lowerQuery);
    }).toList();
    state = AsyncData(filtered);
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
