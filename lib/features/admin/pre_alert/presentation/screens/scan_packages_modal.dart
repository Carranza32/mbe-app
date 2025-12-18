import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../../core/design_system/ds_buttons.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../data/models/package_status.dart';
import '../../providers/package_status_provider.dart';
import '../../data/models/admin_pre_alert_model.dart';
import '../../providers/admin_pre_alerts_provider.dart';
import '../../providers/package_selection_provider.dart';
import '../widgets/scan_input_field.dart';

class ScanPackagesModal extends HookConsumerWidget {
  const ScanPackagesModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanController = MobileScannerController();
    final textController = TextEditingController();
    final alertsState = ref.watch(adminPreAlertsProvider);
    final selectionState = ref.watch(packageSelectionProvider);
    final allAlerts = alertsState.value ?? [];
    final selectedAlerts = allAlerts
        .where((alert) => selectionState.contains(alert.id))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Escanear Paquetes...',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Iconsax.close_circle),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ScanInputField(
              controller: textController,
              onScanPressed: () => _handleScan(context, ref, scanController),
              onSubmitted: (value) => _addPackageByCode(context, ref, value),
            ),
          ),
          if (selectedAlerts.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: MBETheme.lightGray,
              child: Row(
                children: [
                  Text(
                    '${selectedAlerts.length} paquete(s) seleccionado(s)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      ref.read(packageSelectionProvider.notifier).clearSelection();
                    },
                    child: const Text('Limpiar'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: selectedAlerts.length,
                itemBuilder: (context, index) {
                  final alert = selectedAlerts[index];
                  return _SelectedPackageItem(
                    package: alert,
                    onRemove: () {
                      ref
                          .read(packageSelectionProvider.notifier)
                          .toggleSelection(alert.id);
                    },
                  );
                },
              ),
            ),
          ] else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.scan_barcode,
                      size: 64,
                      color: MBETheme.neutralGray,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Escanea o ingresa códigos de paquetes',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: MBETheme.neutralGray,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: DSButton.secondary(
                    label: 'Limpiar Selección',
                    onPressed: selectedAlerts.isEmpty
                        ? null
                        : () {
                            ref
                                .read(packageSelectionProvider.notifier)
                                .clearSelection();
                          },
                    fullWidth: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DSButton.primary(
                    label: 'Exportar (${selectedAlerts.length})',
                    onPressed: selectedAlerts.isEmpty
                        ? null
                        : () => _exportSelected(context, ref),
                    fullWidth: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleScan(
    BuildContext context,
    WidgetRef ref,
    MobileScannerController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Escaneando...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MobileScanner(
                    controller: controller,
                    onDetect: (capture) {
                      final barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty) {
                        final code = barcodes.first.rawValue;
                        if (code != null) {
                          Navigator.of(context).pop();
                          _addPackageByCode(context, ref, code);
                        }
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DSButton.secondary(
                label: 'Cerrar',
                onPressed: () {
                  controller.stop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addPackageByCode(
    BuildContext context,
    WidgetRef ref,
    String code,
  ) {
    final alertsState = ref.read(adminPreAlertsProvider);
    final allAlerts = alertsState.value ?? [];

    final package = allAlerts.firstWhere(
      (alert) =>
          alert.trackingNumber == code ||
          alert.eboxCode.toLowerCase() == code.toLowerCase(),
      orElse: () => throw Exception('Paquete no encontrado'),
    );

    ref.read(packageSelectionProvider.notifier).toggleSelection(package.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paquete ${package.trackingNumber} agregado'),
        backgroundColor: Colors.green,
      ),
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
        Navigator.of(context).pop();
      }
    }
  }
}

class _SelectedPackageItem extends StatelessWidget {
  final AdminPreAlert package;
  final VoidCallback onRemove;

  const _SelectedPackageItem({
    required this.package,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MBETheme.lightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MBETheme.neutralGray.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${package.trackingNumber}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${package.eboxCode} | ${package.clientName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: MBETheme.neutralGray,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Iconsax.close_circle, color: MBETheme.brandRed),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

