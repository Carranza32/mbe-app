import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../core/network/api_service.dart';
import '../data/models/locker_retrieval_model.dart';
import '../data/repositories/locker_retrieval_repository.dart';

final lockerRetrievalRepositoryProvider = Provider<LockerRetrievalRepository>(
  (ref) => LockerRetrievalRepository(ref.read(apiServiceProvider)),
);

/// Contadores (pendientes / entregados) para la tienda seleccionada.
final lockerRetrievalCountsProvider =
    FutureProvider.family<LockerRetrievalCounts, int>((ref, storeId) async {
      if (storeId <= 0) {
        return LockerRetrievalCounts(pending: 0, delivered: 0);
      }
      final repo = ref.read(lockerRetrievalRepositoryProvider);
      return repo.getCounts(storeId);
    });

/// Lista paginada de retiros pendientes. Arg: storeId.
class LockerPendingPickupsNotifier
    extends AsyncNotifier<List<LockerPickupItem>> {
  int _storeId = 0;
  int _page = 1;
  bool _hasMore = true;
  bool _loadingMore = false;
  List<LockerPickupItem> _list = [];

  @override
  Future<List<LockerPickupItem>> build() async {
    // storeId se pasa por override en el widget; aquí no tenemos family.
    // Usamos un provider que recibe storeId y lo guardamos en el notifier vía provider override.
    return [];
  }

  Future<List<LockerPickupItem>> _fetchPage(int storeId, int page) async {
    final repo = ref.read(lockerRetrievalRepositoryProvider);
    final res = await repo.getPickups(
      storeId: storeId,
      status: lockerStatusPending,
      page: page,
      perPage: 15,
    );
    if (page == 1) {
      _list = List.from(res.data);
    } else {
      _list = [..._list, ...res.data];
    }
    _page = res.currentPage;
    _hasMore = res.hasMorePages;
    return List.from(_list);
  }

  Future<void> load(int storeId) async {
    if (storeId <= 0) return;
    _storeId = storeId;
    _page = 1;
    _hasMore = true;
    _list = [];
    state = const AsyncLoading();
    state = AsyncData(await _fetchPage(storeId, 1));
  }

  Future<void> loadMore() async {
    if (!_hasMore || _loadingMore || _storeId <= 0) return;
    _loadingMore = true;
    try {
      final updated = await _fetchPage(_storeId, _page + 1);
      state = AsyncData(updated);
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> refresh() async {
    if (_storeId > 0) load(_storeId);
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _loadingMore;
}

/// Lista paginada de retiros entregados. Arg: storeId.
class LockerDeliveredPickupsNotifier
    extends AsyncNotifier<List<LockerPickupItem>> {
  int _storeId = 0;
  int _page = 1;
  bool _hasMore = true;
  bool _loadingMore = false;
  List<LockerPickupItem> _list = [];

  @override
  Future<List<LockerPickupItem>> build() async => [];

  Future<List<LockerPickupItem>> _fetchPage(int storeId, int page) async {
    final repo = ref.read(lockerRetrievalRepositoryProvider);
    final res = await repo.getPickups(
      storeId: storeId,
      status: lockerStatusDelivered,
      page: page,
      perPage: 15,
    );
    if (page == 1) {
      _list = List.from(res.data);
    } else {
      _list = [..._list, ...res.data];
    }
    _page = res.currentPage;
    _hasMore = res.hasMorePages;
    return List.from(_list);
  }

  Future<void> load(int storeId) async {
    if (storeId <= 0) return;
    _storeId = storeId;
    _page = 1;
    _hasMore = true;
    _list = [];
    state = const AsyncLoading();
    state = AsyncData(await _fetchPage(storeId, 1));
  }

  Future<void> loadMore() async {
    if (!_hasMore || _loadingMore || _storeId <= 0) return;
    _loadingMore = true;
    try {
      final updated = await _fetchPage(_storeId, _page + 1);
      state = AsyncData(updated);
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> refresh() async {
    if (_storeId > 0) load(_storeId);
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _loadingMore;
}

final lockerPendingPickupsProvider =
    AsyncNotifierProvider<LockerPendingPickupsNotifier, List<LockerPickupItem>>(
      LockerPendingPickupsNotifier.new,
    );

final lockerDeliveredPickupsProvider =
    AsyncNotifierProvider<
      LockerDeliveredPickupsNotifier,
      List<LockerPickupItem>
    >(LockerDeliveredPickupsNotifier.new);

// Helpers para usar desde la UI
const String lockerStatusPending = 'pending';
const String lockerStatusDelivered = 'delivered';
