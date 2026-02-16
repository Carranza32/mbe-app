import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/network/api_exception.dart';
import '../../data/models/locker_retrieval_model.dart';
import '../../providers/locker_retrieval_provider.dart';

class LockerRetrievalSearchSheet extends ConsumerStatefulWidget {
  final int storeId;
  final String storeName;
  final void Function(LockerRetrievalSearchItem item) onSelectItem;

  const LockerRetrievalSearchSheet({
    super.key,
    required this.storeId,
    required this.storeName,
    required this.onSelectItem,
  });

  @override
  ConsumerState<LockerRetrievalSearchSheet> createState() =>
      _LockerRetrievalSearchSheetState();
}

class _LockerRetrievalSearchSheetState
    extends ConsumerState<LockerRetrievalSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<LockerRetrievalSearchItem> _results = [];
  bool _searching = false;
  String? _error;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _searchController.text.trim();
    if (q.length < 2) {
      setState(() {
        _error = 'Escribe al menos 2 caracteres (código de casillero o DUI)';
        _hasSearched = true;
        _results = [];
      });
      return;
    }
    setState(() {
      _error = null;
      _searching = true;
      _hasSearched = true;
    });
    try {
      final repo = ref.read(lockerRetrievalRepositoryProvider);
      final list = await repo.search(storeId: widget.storeId, search: q);
      if (mounted) {
        setState(() {
          _results = list;
          _searching = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _results = [];
          _searching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al buscar. Intenta de nuevo.';
          _results = [];
          _searching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Iconsax.close_circle),
                  color: MBETheme.brandBlack,
                ),
                Expanded(
                  child: Text(
                    'Buscar en ${widget.storeName}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: MBETheme.brandBlack,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Código casillero o DUI (mín. 2 caracteres)',
                      prefixIcon: const Icon(
                        Iconsax.search_normal_1,
                        color: MBETheme.brandBlack,
                      ),
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
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _searching ? null : _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MBETheme.brandRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _searching
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(AppLocalizations.of(context)!.adminSearch),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.search_normal_1,
              size: 56,
              color: MBETheme.neutralGray.withOpacity(0.6),
            ),
            const SizedBox(height: 12),
            Text(
              'Escribe código de casillero o DUI y pulsa Buscar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: MBETheme.neutralGray,
              ),
            ),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.warning_2, size: 48, color: MBETheme.brandRed),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: MBETheme.neutralGray),
              ),
            ],
          ),
        ),
      );
    }
    if (_results.isEmpty) {
      return const Center(
        child: Text(
          'Sin resultados. Verifica el código o DUI.',
          style: TextStyle(color: MBETheme.neutralGray),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final item = _results[index];
        return _ResultTile(
          item: item,
          onTap: () => widget.onSelectItem(item),
        );
      },
    );
  }
}

class _ResultTile extends StatelessWidget {
  final LockerRetrievalSearchItem item;
  final VoidCallback onTap;

  const _ResultTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: MBETheme.brandRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Iconsax.box_1,
                  color: MBETheme.brandRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.customerNameMasked,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: MBETheme.brandBlack,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Casillero ${item.physicalLockerCode}'
                          '${item.lockerCode != null ? ' · ${item.lockerCode}' : ''}',
                      style: TextStyle(
                        fontSize: 13,
                        color: MBETheme.neutralGray,
                      ),
                    ),
                    if (item.pieceCount > 1)
                      Text(
                        '${item.pieceCount} piezas',
                        style: TextStyle(
                          fontSize: 12,
                          color: MBETheme.neutralGray,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Iconsax.arrow_right_3, color: MBETheme.neutralGray),
            ],
          ),
        ),
      ),
    );
  }
}
