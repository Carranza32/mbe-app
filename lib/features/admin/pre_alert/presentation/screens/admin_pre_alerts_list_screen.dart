import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../core/design_system/ds_buttons.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../data/models/package_status.dart';
import '../../providers/admin_pre_alerts_provider.dart';
import '../../providers/package_selection_provider.dart';
import '../../providers/package_status_provider.dart';
import '../widgets/status_filter_chips.dart';
import '../widgets/package_list_item.dart';
import 'scan_packages_modal.dart';

class AdminPreAlertsListScreen extends ConsumerStatefulWidget {
  const AdminPreAlertsListScreen({super.key});

  @override
  ConsumerState<AdminPreAlertsListScreen> createState() =>
      _AdminPreAlertsListScreenState();
}

class _AdminPreAlertsListScreenState
    extends ConsumerState<AdminPreAlertsListScreen> {
  PackageStatus? selectedFilter;

  @override
  Widget build(BuildContext context) {
    final alertsState = ref.watch(adminPreAlertsProvider);
    final selectionState = ref.watch(packageSelectionProvider);
    final selectedCount = selectionState.length;

    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Paquetes Para Envío',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: MBETheme.brandBlack,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.import_1),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Importar Pre-Alertas')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          StatusFilterChips(
            selectedStatus: selectedFilter,
            onStatusSelected: (status) {
              setState(() {
                selectedFilter = status;
              });
              if (status == null) {
                ref.invalidate(adminPreAlertsProvider);
              } else {
                ref.read(adminPreAlertsProvider.notifier).filterByStatus(status);
              }
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: DSButton.secondary(
                    label: 'Escanear Paquetes',
                    icon: Iconsax.scan_barcode,
                    onPressed: () => _showScanModal(context, ref),
                    fullWidth: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DSButton.primary(
                    label: 'Exportar (${selectedCount})',
                    icon: Iconsax.export,
                    onPressed: selectedCount > 0
                        ? () => _exportSelected(context, ref)
                        : null,
                    fullWidth: true,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: alertsState.when(
              data: (alerts) {
                if (alerts.isEmpty) {
                  return const Center(
                    child: Text('No hay paquetes disponibles'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(adminPreAlertsProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: alerts.length,
                    itemBuilder: (context, index) {
                      return PackageListItem(
                        package: alerts[index],
                      );
                    },
                  ),
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
        ],
      ),
    );
  }

  void _showScanModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ScanPackagesModal(),
    );
  }

  Future<void> _exportSelected(BuildContext context, WidgetRef ref) async {
    final selection = ref.read(packageSelectionProvider);
    if (selection.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Paquetes'),
        content: Text(
          '¿Exportar ${selection.length} paquete(s) seleccionado(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          DSButton.primary(
            label: 'Exportar',
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final statusManager = ref.read(packageStatusManagerProvider.notifier);
    final success = await statusManager.updateStatus(
      packageIds: selection.toList(),
      newStatus: PackageStatus.exported,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '${selection.length} paquete(s) exportado(s) exitosamente'
                : 'Error al exportar paquetes',
          ),
          backgroundColor: success ? Colors.green : MBETheme.brandRed,
        ),
      );

      if (success) {
        ref.read(packageSelectionProvider.notifier).clearSelection();
      }
    }
  }
}

