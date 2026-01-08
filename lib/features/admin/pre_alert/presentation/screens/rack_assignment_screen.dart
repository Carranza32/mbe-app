import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../core/design_system/ds_buttons.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../data/models/package_status.dart';
import '../../providers/admin_pre_alerts_provider.dart';
import '../widgets/package_list_item.dart';
import '../widgets/rack_assignment_modal.dart';

class RackAssignmentScreen extends ConsumerStatefulWidget {
  const RackAssignmentScreen({super.key});

  @override
  ConsumerState<RackAssignmentScreen> createState() =>
      _RackAssignmentScreenState();
}

class _RackAssignmentScreenState extends ConsumerState<RackAssignmentScreen> {
  final Set<String> _selectedPackageIds = {};

  @override
  Widget build(BuildContext context) {
    final alertsState = ref.watch(adminPreAlertsProvider);
    final allAlerts = alertsState.value ?? [];

    // Filtrar solo paquetes en estado "en_tienda"
    final packagesInStore = allAlerts
        .where((alert) => alert.status == PackageStatus.enTienda)
        .toList();

    final selectedCount = _selectedPackageIds.length;
    final isSelectionMode = selectedCount > 0;

    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Asignar Rack',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: MBETheme.brandBlack,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: MBETheme.brandBlack),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isSelectionMode)
            TextButton(
              onPressed: _clearSelection,
              child: const Text(
                'Limpiar',
                style: TextStyle(color: MBETheme.brandRed),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Información de filtro
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Icon(
                  Iconsax.info_circle,
                  color: MBETheme.brandBlack,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mostrando paquetes en estado "En Tienda" (${packagesInStore.length})',
                    style: TextStyle(
                      color: MBETheme.neutralGray,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de paquetes
          Expanded(
            child: alertsState.when(
              data: (_) {
                if (packagesInStore.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.box_1,
                          size: 64,
                          color: MBETheme.neutralGray.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay paquetes en tienda',
                          style: TextStyle(
                            color: MBETheme.neutralGray.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Los paquetes deben estar en estado "En Tienda" para asignar rack',
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
                  itemCount: packagesInStore.length,
                  itemBuilder: (context, index) {
                    final package = packagesInStore[index];
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
                            // Indicador de rack actual si existe
                            if (package.rackNumber != null ||
                                package.segmentNumber != null)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: MBETheme.lightGray,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (package.rackNumber != null)
                                        Text(
                                          'Rack: ${package.rackNumber}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      if (package.segmentNumber != null)
                                        Text(
                                          'Seg: ${package.segmentNumber}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: MBETheme.neutralGray,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
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
                      onPressed: () =>
                          ref.invalidate(adminPreAlertsProvider),
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
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: DSButton.primary(
                        label: 'Asignar Rack',
                        icon: Iconsax.location,
                        fullWidth: true,
                        onPressed: () => _showAssignRackModal(context),
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

  void _showAssignRackModal(BuildContext context) {
    if (_selectedPackageIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => RackAssignmentModal(
        packageIds: _selectedPackageIds.toList(),
        packageCount: _selectedPackageIds.length,
      ),
    ).then((result) {
      if (result == true) {
        // Limpiar selección después de asignar exitosamente
        _clearSelection();
        // Refrescar la lista
        ref.invalidate(adminPreAlertsProvider);
      }
    });
  }
}

