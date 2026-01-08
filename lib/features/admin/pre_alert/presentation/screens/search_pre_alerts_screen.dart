import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../data/models/admin_pre_alert_model.dart';
import '../../providers/search_pre_alerts_provider.dart';
import '../../providers/recent_searches_provider.dart';
import '../widgets/package_list_item.dart';
import '../widgets/package_edit_modal.dart';

enum SearchType {
  all,
  tracking,
  packageCode,
  lockerCode,
  customerName,
  provider,
}

extension SearchTypeExtension on SearchType {
  String get label {
    switch (this) {
      case SearchType.all:
        return 'Todo';
      case SearchType.tracking:
        return 'Tracking';
      case SearchType.packageCode:
        return 'Código Ebox';
      case SearchType.lockerCode:
        return 'Casillero';
      case SearchType.customerName:
        return 'Cliente';
      case SearchType.provider:
        return 'Proveedor';
    }
  }
}

class SearchPreAlertsScreen extends ConsumerStatefulWidget {
  const SearchPreAlertsScreen({super.key});

  @override
  ConsumerState<SearchPreAlertsScreen> createState() =>
      _SearchPreAlertsScreenState();
}

class _SearchPreAlertsScreenState extends ConsumerState<SearchPreAlertsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _hasSearched = false;
  SearchType _selectedSearchType = SearchType.all;

  @override
  void initState() {
    super.initState();
    // Auto-focus en el campo de búsqueda
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _hasSearched = false;
      });
      ref.read(searchPreAlertsProvider.notifier).clear();
      return;
    }

    setState(() {
      _hasSearched = true;
    });

    // Guardar búsqueda reciente
    ref.read(recentSearchesProvider.notifier).addSearch(query);

    // Debounce: esperar 500ms después de que el usuario deje de escribir
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text.trim() == query.trim() && mounted) {
        ref.read(searchPreAlertsProvider.notifier).search(query);
      }
    });
  }

  void _searchFromRecent(String query) {
    _searchController.text = query;
    _performSearch(query);
    _searchFocusNode.requestFocus();
  }

  void _showPackageDetail(AdminPreAlert package) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PackageEditModal(package: package),
    ).then((result) {
      if (result == true) {
        // Si se guardó algo, refrescar la búsqueda
        if (_searchController.text.trim().isNotEmpty) {
          ref
              .read(searchPreAlertsProvider.notifier)
              .search(_searchController.text.trim());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchPreAlertsProvider);
    final recentSearchesState = ref.watch(recentSearchesProvider);

    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Buscar',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: MBETheme.brandBlack,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Campo de búsqueda y selector de tipo
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Campo de búsqueda
                Container(
                  decoration: BoxDecoration(
                    color: MBETheme.lightGray,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText:
                          'Buscar por tracking, código ebox, casillero o cliente...',
                      hintStyle: TextStyle(
                        color: MBETheme.neutralGray.withOpacity(0.6),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Iconsax.search_normal,
                        color: MBETheme.neutralGray,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Iconsax.close_circle,
                                color: MBETheme.neutralGray,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _hasSearched = false;
                                });
                                ref
                                    .read(searchPreAlertsProvider.notifier)
                                    .clear();
                                _searchFocusNode.requestFocus();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: _performSearch,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _performSearch(value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // Selector de tipo de búsqueda
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: SearchType.values.map((type) {
                      final isSelected = _selectedSearchType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(type.label),
                          onSelected: (selected) {
                            setState(() {
                              _selectedSearchType = type;
                            });
                            // Si hay texto, buscar de nuevo con el nuevo tipo
                            if (_searchController.text.trim().isNotEmpty) {
                              _performSearch(_searchController.text.trim());
                            }
                          },
                          selectedColor: MBETheme.brandBlack.withOpacity(0.1),
                          checkmarkColor: MBETheme.brandBlack,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? MBETheme.brandBlack
                                : MBETheme.neutralGray,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: 13,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? MBETheme.brandBlack
                                : Colors.grey[300]!,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Resultados o búsquedas recientes
          Expanded(
            child: _hasSearched
                ? _buildResults(searchState)
                : _buildInitialState(recentSearchesState),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(AsyncValue<List<String>> recentSearchesState) {
    return recentSearchesState.when(
      data: (recentSearches) {
        if (recentSearches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.search_normal,
                  size: 64,
                  color: MBETheme.neutralGray.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Busca paquetes',
                  style: TextStyle(
                    color: MBETheme.neutralGray.withOpacity(0.8),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Busca por número de tracking, código ebox, código de casillero o nombre del cliente',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MBETheme.neutralGray.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header de búsquedas recientes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Búsquedas Recientes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: MBETheme.brandBlack,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(recentSearchesProvider.notifier).clearAll();
                    },
                    child: Text(
                      'Limpiar todo',
                      style: TextStyle(
                        color: MBETheme.brandRed,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Lista de búsquedas recientes
              ...recentSearches.map((search) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Iconsax.clock,
                      color: MBETheme.neutralGray,
                      size: 20,
                    ),
                    title: Text(
                      search,
                      style: TextStyle(
                        color: MBETheme.brandBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Iconsax.close_circle,
                        color: MBETheme.neutralGray.withOpacity(0.6),
                        size: 20,
                      ),
                      onPressed: () {
                        ref
                            .read(recentSearchesProvider.notifier)
                            .removeSearch(search);
                      },
                    ),
                    onTap: () => _searchFromRecent(search),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error: ${error.toString()}')),
    );
  }

  Widget _buildResults(AsyncValue<List<AdminPreAlert>> searchState) {
    return searchState.when(
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.search_normal_1,
                  size: 64,
                  color: MBETheme.neutralGray.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No se encontraron resultados',
                  style: TextStyle(
                    color: MBETheme.neutralGray.withOpacity(0.8),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Intenta con otros términos de búsqueda',
                  style: TextStyle(
                    color: MBETheme.neutralGray.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contador de resultados
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  Icon(Iconsax.document, size: 16, color: MBETheme.neutralGray),
                  const SizedBox(width: 8),
                  Text(
                    '${results.length} resultado${results.length != 1 ? 's' : ''} encontrado${results.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      color: MBETheme.neutralGray,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Lista de resultados
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final package = results[index];
                  return PackageListItem(
                    package: package,
                    onTap: () => _showPackageDetail(package),
                    showLocation: true, // Siempre mostrar ubicación en búsqueda
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.danger, size: 48, color: MBETheme.brandRed),
            const SizedBox(height: 16),
            Text(
              'Error al buscar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_searchController.text.trim().isNotEmpty) {
                  ref
                      .read(searchPreAlertsProvider.notifier)
                      .search(_searchController.text.trim());
                }
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
