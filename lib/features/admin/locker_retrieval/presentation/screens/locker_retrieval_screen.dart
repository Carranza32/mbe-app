import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../../../../core/design_system/ds_buttons.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/services/app_preferences.dart';
import '../../data/models/admin_store_model.dart';
import '../../data/models/locker_retrieval_model.dart';
import '../../providers/locker_retrieval_provider.dart';
import '../widgets/locker_pickup_list_item.dart';
import 'create_pickup_screen.dart';
import 'locker_retrieval_detail_screen.dart';
import 'locker_retrieval_scan_modal.dart';
import 'locker_retrieval_search_sheet.dart';

class LockerRetrievalScreen extends ConsumerStatefulWidget {
  const LockerRetrievalScreen({super.key});

  @override
  ConsumerState<LockerRetrievalScreen> createState() =>
      _LockerRetrievalScreenState();
}

class _LockerRetrievalScreenState extends ConsumerState<LockerRetrievalScreen>
    with SingleTickerProviderStateMixin {
  List<AdminStoreModel> _stores = [];
  AdminStoreModel? _selectedStore;
  bool _loadingStores = true;
  String? _storesError;
  late TabController _tabController;
  final ScrollController _pendingScrollController = ScrollController();
  final ScrollController _deliveredScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStores();
    _pendingScrollController.addListener(_onPendingScroll);
    _deliveredScrollController.addListener(_onDeliveredScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pendingScrollController.dispose();
    _deliveredScrollController.dispose();
    super.dispose();
  }

  void _onPendingScroll() {
    if (_pendingScrollController.position.pixels >=
        _pendingScrollController.position.maxScrollExtent * 0.85) {
      final notifier = ref.read(lockerPendingPickupsProvider.notifier);
      if (notifier.hasMore && !notifier.isLoadingMore) {
        notifier.loadMore();
      }
    }
  }

  void _onDeliveredScroll() {
    if (_deliveredScrollController.position.pixels >=
        _deliveredScrollController.position.maxScrollExtent * 0.85) {
      final notifier = ref.read(lockerDeliveredPickupsProvider.notifier);
      if (notifier.hasMore && !notifier.isLoadingMore) {
        notifier.loadMore();
      }
    }
  }

  Future<void> _loadStores() async {
    setState(() {
      _loadingStores = true;
      _storesError = null;
    });
    try {
      final repo = ref.read(lockerRetrievalRepositoryProvider);
      final list = await repo.getStores();
      final savedId = await getLockerRetrievalStoreId();
      AdminStoreModel? initial;
      if (list.isNotEmpty) {
        if (savedId != null) {
          try {
            initial = list.firstWhere((s) => s.id == savedId);
          } catch (_) {
            initial = list.first;
          }
        } else {
          initial = list.first;
        }
        await setLockerRetrievalStoreId(initial.id);
      }
      if (mounted) {
        setState(() {
          _stores = list;
          _selectedStore = initial;
          _loadingStores = false;
        });
        // Cargar listas de pendientes/entregados después del build (no durante).
        final storeIdToLoad = initial?.id;
        if (storeIdToLoad != null) {
          final id = storeIdToLoad;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ref.read(lockerPendingPickupsProvider.notifier).load(id);
            ref.read(lockerDeliveredPickupsProvider.notifier).load(id);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _storesError = e is ApiException
              ? e.message
              : AppLocalizations.of(context)!.adminErrorLoadingStores;
          _loadingStores = false;
        });
      }
    }
  }

  void _onStoreChanged(AdminStoreModel? v) {
    if (v == null) return;
    setState(() => _selectedStore = v);
    setLockerRetrievalStoreId(v.id);
    ref.invalidate(lockerRetrievalCountsProvider(v.id));
    // Ejecutar load fuera del ciclo de build (el dropdown puede disparar durante build).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(lockerPendingPickupsProvider.notifier).load(v.id);
      ref.read(lockerDeliveredPickupsProvider.notifier).load(v.id);
    });
  }

  void _openScan() {
    if (_selectedStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.adminSelectStoreFirst),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LockerRetrievalScanModal(
        onTokenScanned: (token) => _fetchByTokenAndGoToDetail(ctx, token),
      ),
    );
  }

  Future<void> _fetchByTokenAndGoToDetail(
    BuildContext sheetContext,
    String token,
  ) async {
    Navigator.of(sheetContext).pop();
    try {
      final repo = ref.read(lockerRetrievalRepositoryProvider);
      final detail = await repo.getRetrievalByToken(token);
      if (!mounted) return;
      final cleanToken = _extractToken(token);
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (ctx) =>
              LockerRetrievalDetailScreen(detail: detail, token: cleanToken),
        ),
      );
      if (result == true && mounted && _selectedStore != null) {
        ref.invalidate(lockerRetrievalCountsProvider(_selectedStore!.id));
        ref.read(lockerPendingPickupsProvider.notifier).refresh();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: MBETheme.brandRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _openSearch() {
    if (_selectedStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.adminSelectStoreFirst),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LockerRetrievalSearchSheet(
        storeId: _selectedStore!.id,
        storeName: _selectedStore!.name,
        onSelectItem: (item) async {
          Navigator.of(ctx).pop();
          await _fetchByTokenAndGoToDetail(context, item.pickupToken);
        },
      ),
    );
  }

  void _onPendingItemTap(LockerPickupItem item) {
    _fetchByTokenAndGoToDetail(context, item.pickupToken);
  }

  static String _extractToken(String value) {
    final trimmed = value.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.queryParameters.containsKey('token')) {
      return uri.queryParameters['token']!.trim();
    }
    return trimmed;
  }

  void _openCreatePickup() {
    if (_stores.isEmpty) return;
    Navigator.of(context)
        .push<bool>(
          MaterialPageRoute<bool>(
            builder: (context) => CreatePickupScreen(
              stores: _stores,
              initialStore: _selectedStore,
            ),
          ),
        )
        .then((created) {
          if (created == true && mounted && _selectedStore != null) {
            ref.invalidate(lockerRetrievalCountsProvider(_selectedStore!.id));
            ref.read(lockerPendingPickupsProvider.notifier).refresh();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final showFAB =
        !_loadingStores && _storesError == null && _stores.isNotEmpty;

    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.adminLockerPickup,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: MBETheme.brandBlack,
            fontSize: 20,
          ),
        ),
      ),
      body: _loadingStores
          ? const Center(child: CircularProgressIndicator())
          : _storesError != null
          ? _buildErrorBody()
          : _buildContent(),
      floatingActionButton: showFAB ? _buildCreatePickupFAB() : null,
    );
  }

  Widget _buildCreatePickupFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFFED1C24), Color(0xFFB91419)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFED1C24).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _openCreatePickup,
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Iconsax.add_circle, color: Colors.white),
        label: const Text(
          'Crear retiro',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildErrorBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.warning_2,
              size: 64,
              color: MBETheme.brandRed.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 16),
            Text(
              _storesError!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: MBETheme.neutralGray),
            ),
            const SizedBox(height: 24),
            DSButton.primary(
              label: AppLocalizations.of(context)!.adminReintentar,
              onPressed: _loadStores,
              icon: Iconsax.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_stores.isEmpty) {
      return Center(
        child: Text(
          'No tienes tiendas asignadas.',
          style: TextStyle(fontSize: 16, color: MBETheme.neutralGray),
        ),
      );
    }

    final storeId = _selectedStore!.id;
    final countsAsync = ref.watch(lockerRetrievalCountsProvider(storeId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Selector de tienda
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: MBETheme.shadowMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.preAlertStoreLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: MBETheme.neutralGray,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<AdminStoreModel>(
                  value: _selectedStore,
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: MBETheme.lightGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: _stores
                      .map(
                        (s) => DropdownMenuItem<AdminStoreModel>(
                          value: s,
                          child: Text(
                            s.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _onStoreChanged,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Acciones rápidas
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Iconsax.scan_barcode,
                  title: 'Escanear QR',
                  onTap: _openScan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Iconsax.search_normal_1,
                  title: AppLocalizations.of(context)!.adminSearch,
                  onTap: _openSearch,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tabs con totales
        Container(
          color: Colors.white,
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: MBETheme.brandRed,
                unselectedLabelColor: MBETheme.neutralGray,
                indicatorColor: MBETheme.brandRed,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(
                    text: countsAsync.when(
                      data: (c) => 'Pendientes (${c.pending})',
                      loading: () => 'Pendientes (…)',
                      error: (_, __) => 'Pendientes',
                    ),
                  ),
                  Tab(
                    text: countsAsync.when(
                      data: (c) => '${AppLocalizations.of(context)!.adminDelivered} (${c.delivered})',
                      loading: () => '${AppLocalizations.of(context)!.adminDelivered} (…)',
                      error: (_, __) => AppLocalizations.of(context)!.adminDelivered,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Listas (la carga se dispara en addPostFrameCallback tras cargar tiendas / al cambiar tienda)
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _BuildPendingList(
                scrollController: _pendingScrollController,
                onItemTap: _onPendingItemTap,
              ),
              _BuildDeliveredList(scrollController: _deliveredScrollController),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: MBETheme.brandRed, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: MBETheme.brandBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuildPendingList extends ConsumerWidget {
  final ScrollController scrollController;
  final void Function(LockerPickupItem) onItemTap;

  const _BuildPendingList({
    required this.scrollController,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(lockerPendingPickupsProvider);
    final notifier = ref.read(lockerPendingPickupsProvider.notifier);

    return asyncList.when(
      data: (list) => _listBody(
        context: context,
        list: list,
        scrollController: scrollController,
        hasMore: notifier.hasMore,
        emptyMessage: 'No hay retiros pendientes',
        isPending: true,
        onItemTap: onItemTap,
        onRefresh: () =>
            ref.read(lockerPendingPickupsProvider.notifier).refresh(),
      ),
      loading: () => _shimmerList(context),
      error: (err, _) => _errorBody(err),
    );
  }
}

class _BuildDeliveredList extends ConsumerWidget {
  final ScrollController scrollController;

  const _BuildDeliveredList({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(lockerDeliveredPickupsProvider);
    final notifier = ref.read(lockerDeliveredPickupsProvider.notifier);

    return asyncList.when(
      data: (list) => _listBody(
        context: context,
        list: list,
        scrollController: scrollController,
        hasMore: notifier.hasMore,
        emptyMessage: AppLocalizations.of(context)!.adminNoDeliveries,
        isPending: false,
        onItemTap: null,
        onRefresh: () =>
            ref.read(lockerDeliveredPickupsProvider.notifier).refresh(),
      ),
      loading: () => _shimmerList(context),
      error: (err, _) => _errorBody(err),
    );
  }
}

Widget _listBody({
  required BuildContext context,
  required List<LockerPickupItem> list,
  required ScrollController scrollController,
  required bool hasMore,
  required String emptyMessage,
  required bool isPending,
  required void Function(LockerPickupItem)? onItemTap,
  required Future<void> Function() onRefresh,
}) {
  final emptyWidget = Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Iconsax.box_1,
          size: 56,
          color: MBETheme.neutralGray.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 12),
        Text(
          emptyMessage,
          style: TextStyle(fontSize: 14, color: MBETheme.neutralGray),
        ),
      ],
    ),
  );

  if (list.isEmpty) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: MBETheme.brandRed,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.4),
          emptyWidget,
        ],
      ),
    );
  }

  return RefreshIndicator(
    onRefresh: onRefresh,
    color: MBETheme.brandRed,
    child: ListView.builder(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: list.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == list.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final item = list[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: LockerPickupListItem(
            item: item,
            isPending: isPending,
            onTap: onItemTap != null ? () => onItemTap(item) : null,
          ),
        );
      },
    ),
  );
}

Widget _shimmerList(BuildContext context) {
  return ListView(
    padding: const EdgeInsets.all(20),
    children: List.generate(
      5,
      (_) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: MBETheme.shadowMd,
          ),
          child: Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: MBETheme.brandRed,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _errorBody(Object err) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.warning_2, size: 48, color: MBETheme.brandRed),
          const SizedBox(height: 12),
          Text(
            err.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: MBETheme.neutralGray),
          ),
        ],
      ),
    ),
  );
}
