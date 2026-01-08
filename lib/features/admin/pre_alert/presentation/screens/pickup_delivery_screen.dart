import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../core/design_system/ds_buttons.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../data/models/package_status.dart';
import '../../providers/admin_pre_alerts_provider.dart';
import '../widgets/package_list_item.dart';
import '../widgets/pickup_delivery_modal.dart';
import '../widgets/delivery_dispatch_sheet.dart';

class PickupDeliveryScreen extends ConsumerStatefulWidget {
  const PickupDeliveryScreen({super.key});

  @override
  ConsumerState<PickupDeliveryScreen> createState() =>
      _PickupDeliveryScreenState();
}

class _PickupDeliveryScreenState extends ConsumerState<PickupDeliveryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedPackageIds = {};
  String _searchQuery = '';
  String _deliveryType = 'pickup'; // 'pickup' o 'delivery'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alertsState = ref.watch(adminPreAlertsProvider);
    final allAlerts = alertsState.value ?? [];

    // Filtrar paquetes según el tipo de entrega
    final filteredPackages = allAlerts.where((alert) {
      // Debe estar en estado lista_retiro
      if (alert.status != PackageStatus.listaRetiro) return false;

      // Filtrar por tipo de entrega
      if (_deliveryType == 'pickup') {
        return alert.deliveryMethod == 'pickup';
      } else {
        return alert.deliveryMethod == 'delivery';
      }
    }).toList();

    // Filtrar por búsqueda si existe
    final searchResults = _searchQuery.isEmpty
        ? filteredPackages
        : filteredPackages.where((alert) {
            final query = _searchQuery.toLowerCase();
            return alert.trackingNumber.toLowerCase().contains(query) ||
                alert.eboxCode.toLowerCase().contains(query) ||
                alert.clientName.toLowerCase().contains(query) ||
                (alert.contactName?.toLowerCase().contains(query) ?? false) ||
                (alert.contactPhone?.contains(query) ?? false);
          }).toList();

    final selectedCount = _selectedPackageIds.length;
    final isSelectionMode = selectedCount > 0;

    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Procesar Entregas',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: MBETheme.brandBlack,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: MBETheme.brandBlack),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Selector de tipo de entrega
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _DeliveryTypeChip(
                    label: 'Pickup',
                    icon: Iconsax.shop,
                    isSelected: _deliveryType == 'pickup',
                    onTap: () {
                      setState(() {
                        _deliveryType = 'pickup';
                        _selectedPackageIds.clear();
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DeliveryTypeChip(
                    label: 'Delivery',
                    icon: Iconsax.truck,
                    isSelected: _deliveryType == 'delivery',
                    onTap: () {
                      setState(() {
                        _deliveryType = 'delivery';
                        _selectedPackageIds.clear();
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _deliveryType == 'pickup'
                    ? 'Buscar por nombre, teléfono, tracking o ebox...'
                    : 'Buscar por tracking o ebox...',
                prefixIcon: const Icon(Iconsax.search_normal),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Iconsax.close_circle),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Información de resultados
          if (searchResults.isNotEmpty || _searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Icon(
                    Iconsax.info_circle,
                    size: 16,
                    color: MBETheme.neutralGray,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _searchQuery.isEmpty
                        ? '${searchResults.length} paquete(s) disponible(s)'
                        : '${searchResults.length} resultado(s) encontrado(s)',
                    style: TextStyle(color: MBETheme.neutralGray, fontSize: 12),
                  ),
                ],
              ),
            ),

          // Lista de paquetes
          Expanded(
            child: alertsState.when(
              data: (_) {
                if (searchResults.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty
                              ? Iconsax.search_normal
                              : Iconsax.box_1,
                          size: 64,
                          color: MBETheme.neutralGray.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No se encontraron resultados'
                              : 'No hay paquetes disponibles',
                          style: TextStyle(
                            color: MBETheme.neutralGray.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Los paquetes deben estar en estado "Lista para Retiro"'
                              : 'Intenta con otros términos de búsqueda',
                          style: TextStyle(
                            color: MBETheme.neutralGray.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final package = searchResults[index];
                    final isSelected = _selectedPackageIds.contains(package.id);

                    return GestureDetector(
                      onTap: () => _toggleSelection(package.id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? MBETheme.brandBlack
                                : Colors.transparent,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Checkbox
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Checkbox(
                                value: isSelected,
                                onChanged: (_) => _toggleSelection(package.id),
                                activeColor: MBETheme.brandBlack,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                            // Información del paquete
                            Expanded(
                              child: PackageListItem(
                                package: package,
                                onTap: () => _toggleSelection(package.id),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Iconsax.danger,
                      size: 48,
                      color: MBETheme.brandRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar paquetes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    DSButton.primary(
                      label: 'Reintentar',
                      onPressed: () => ref.invalidate(adminPreAlertsProvider),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Barra de acciones
          if (isSelectionMode)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$selectedCount seleccionado(s)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: MBETheme.brandBlack,
                            ),
                          ),
                          TextButton(
                            onPressed: _clearSelection,
                            child: const Text(
                              'Limpiar',
                              style: TextStyle(color: MBETheme.brandRed),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: DSButton.primary(
                        label: _deliveryType == 'pickup'
                            ? 'Procesar Entrega'
                            : 'Despachar',
                        icon: _deliveryType == 'pickup'
                            ? Iconsax.receipt_item
                            : Iconsax.truck,
                        fullWidth: true,
                        onPressed: () => _showDeliveryModal(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _toggleSelection(String packageId) {
    setState(() {
      if (_selectedPackageIds.contains(packageId)) {
        _selectedPackageIds.remove(packageId);
      } else {
        _selectedPackageIds.add(packageId);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedPackageIds.clear();
    });
  }

  void _showDeliveryModal(BuildContext context) {
    if (_selectedPackageIds.isEmpty) return;

    final alertsState = ref.read(adminPreAlertsProvider);
    final allAlerts = alertsState.value ?? [];
    final selectedPackages = allAlerts
        .where((alert) => _selectedPackageIds.contains(alert.id))
        .toList();

    if (selectedPackages.isEmpty) return;

    if (_deliveryType == 'pickup') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PickupDeliveryModal(packages: selectedPackages),
          fullscreenDialog: true,
        ),
      ).then((result) {
        if (result == true) {
          _clearSelection();
          ref.invalidate(adminPreAlertsProvider);
        }
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DeliveryDispatchSheet(packages: selectedPackages),
          fullscreenDialog: true,
        ),
      ).then((result) {
        if (result == true) {
          _clearSelection();
          ref.invalidate(adminPreAlertsProvider);
        }
      });
    }
  }
}

class _DeliveryTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeliveryTypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? MBETheme.brandBlack : MBETheme.lightGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? MBETheme.brandBlack
                : MBETheme.neutralGray.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : MBETheme.brandBlack,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : MBETheme.brandBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
