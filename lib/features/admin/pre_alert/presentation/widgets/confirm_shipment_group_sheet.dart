import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../../core/design_system/ds_buttons.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../data/models/admin_pre_alert_model.dart';
import '../../data/models/shipping_provider_model.dart';
import '../../data/repositories/admin_pre_alerts_repository.dart';
import '../../data/helpers/export_file_helper.dart';
import '../../providers/shipping_providers_provider.dart';
import '../../providers/admin_pre_alerts_provider.dart';
import '../../providers/context_counts_provider.dart';
import '../widgets/context_filter_segmented.dart';
import 'scanned_packages_section.dart';

class ConfirmShipmentGroupSheet extends ConsumerStatefulWidget {
  const ConfirmShipmentGroupSheet({super.key});

  @override
  ConsumerState<ConfirmShipmentGroupSheet> createState() =>
      _ConfirmShipmentGroupSheetState();
}

class _ConfirmShipmentGroupSheetState
    extends ConsumerState<ConfirmShipmentGroupSheet> {
  late MobileScannerController _scannerController;
  final List<AdminPreAlert> _packages = [];
  bool _isProcessingCode = false;
  bool _isConfirming = false;

  ShippingProviderModel? _selectedOtherProvider;
  String? _expandedPackageId;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onScanOrSubmit(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return;

    setState(() => _isProcessingCode = true);
    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      final package = await repository.findPackageForShipment(trimmed);

      if (!mounted) return;

      if (package == null) {
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paquete no encontrado: $trimmed'),
            backgroundColor: MBETheme.brandRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isProcessingCode = false);
        return;
      }

      final alreadyInList = _packages.any((p) => p.id == package.id);
      if (alreadyInList) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${package.trackingNumber} ya está en la lista'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isProcessingCode = false);
        return;
      }

      setState(() {
        _packages.add(package);
        _isProcessingCode = false;
        _expandedPackageId = package.id;
      });
      _onPackagesChanged();

      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓  ${package.trackingNumber} · Total: ${_packages.length}',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessingCode = false);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: MBETheme.brandRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleScanDetection(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null && barcode.rawValue!.trim().isNotEmpty) {
        _onScanOrSubmit(barcode.rawValue!);
        break;
      }
    }
  }

  void _removePackage(String id) {
    setState(() {
      _packages.removeWhere((p) => p.id == id);
      if (_expandedPackageId == id) {
        _expandedPackageId =
            _packages.isNotEmpty ? _packages.first.id : null;
      }
    });
    _onPackagesChanged();
  }

  void _clearSelection() {
    setState(() {
      _packages.clear();
      _selectedOtherProvider = null;
      _expandedPackageId = null;
    });
  }

  /// True si hay al menos un paquete con delivery_method == 'delivery'
  bool get _hasDeliveryPackages =>
      _packages.any(
        (p) =>
            (p.deliveryMethod ?? '').toLowerCase() == 'delivery',
      );

  /// Al cambiar los paquetes: si todos son casillero, limpiar proveedor
  void _onPackagesChanged() {
    if (!_hasDeliveryPackages && _selectedOtherProvider != null) {
      setState(() => _selectedOtherProvider = null);
    }
  }

  Future<void> _confirmGroup() async {
    if (_packages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escanea al menos un paquete'),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }

    // Proveedor requerido solo si hay paquetes tipo delivery
    if (_hasDeliveryPackages && _selectedOtherProvider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecciona el proveedor de envío (paquetes domicilio)',
          ),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }

    setState(() => _isConfirming = true);
    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      final result = await repository.confirmShipmentGroup(
        packageIds: _packages.map((p) => p.id).toList(),
        providerType: _hasDeliveryPackages ? 'other' : 'boxful',
        shippingProviderId:
            _hasDeliveryPackages ? _selectedOtherProvider!.id : null,
      );

      if (!mounted) return;

      // Quitar de la lista solo los que pasaron ok; los fallidos quedan visibles
      final processedIdSet = result.processedIds.toSet();
      setState(() {
        _packages.removeWhere(
          (p) => processedIdSet.contains(int.tryParse(p.id)),
        );
      });

      if (result.hasSuccess) {
        ref.invalidate(adminPreAlertsProvider);
        ref.invalidate(contextCountsProvider);
        ref.invalidate(solicitudEnvioSubCountsProvider);
        ref.invalidate(confirmacionesSubCountsProvider);
        ref.invalidate(enCaminoSubCountsProvider);
      }

      // Mostrar mensaje de fallos si los hay
      if (result.hasFailures) {
        final failedMsgs = result.failed
            .map((f) => '• ${f.trackNumber ?? f.id}: ${f.error ?? "Error"}')
            .join('\n');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${result.failedCount} paquete(s) no pasaron:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(failedMsgs),
                ],
              ),
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
          ),
        );
      }

      // Si todos pasaron, mostrar diálogo éxito y ofrecer Excel
      if (!result.hasFailures) {
        final confirmedIds = result.processedIds.map((i) => i.toString()).toList();
        final wantExcel = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Iconsax.tick_circle,
                  color: Colors.green,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Grupo confirmado', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: const Text('¿Descargar Excel con los paquetes confirmados?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Sí, descargar'),
            ),
          ],
        ),
      );

        if (!mounted) return;
        if (wantExcel == true && confirmedIds.isNotEmpty) {
        try {
          final repository = ref.read(adminPreAlertsRepositoryProvider);
          final bytes = await repository.exportPreAlertsExcel(confirmedIds);
          if (!mounted) return;
          if (bytes.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se recibieron datos del Excel'),
                backgroundColor: MBETheme.brandRed,
              ),
            );
          } else {
            final now = DateTime.now();
            final name =
                'pre-alertas-${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.xlsx';
            await saveExportFile(bytes: bytes, filename: name);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Excel guardado: $name'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al exportar Excel: $e'),
              backgroundColor: MBETheme.brandRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        }

        if (!mounted) return;
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Grupo confirmado (${result.processedCount} paquete(s)). Pasan a Listos para salir.',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al confirmar: $e'),
          backgroundColor: MBETheme.brandRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final providersState = ref.watch(shippingProvidersProvider);
    final contextCountsState = ref.watch(contextCountsProvider);
    final countsMap = contextCountsState.value;
    final totalPackages =
        countsMap?[PackageContext.solicitudEnvio] ?? 0;

    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: MBETheme.brandBlack),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          'Confirmar grupo de envíos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: MBETheme.brandBlack,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Scanner
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: MobileScanner(
                            controller: _scannerController,
                            onDetect: _handleScanDetection,
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 220,
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white.withOpacity(0.7),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Iconsax.scan,
                              color: Colors.white.withOpacity(0.9),
                              size: 32,
                            ),
                          ),
                        ),
                        if (_isProcessingCode)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              color: Colors.black38,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Provider selector — requerido solo si hay paquetes tipo delivery
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: MBETheme.shadowMd,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: MBETheme.lightGray,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Iconsax.truck_fast,
                                size: 16,
                                color: MBETheme.brandBlack,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Proveedor de envío',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: MBETheme.brandBlack,
                                    ),
                                  ),
                                  if (!_hasDeliveryPackages && _packages.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        'No requerido (solo casilleros)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        providersState.when(
                          data: (providers) {
                            final others = providers
                                .where((p) => p.slug.toLowerCase() != 'boxful')
                                .toList();
                            if (others.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(MBESpacing.sm),
                                child: Text(
                                  'No hay proveedores disponibles',
                                  style: TextStyle(
                                    color: MBETheme.neutralGray,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            }
                            return DropdownButtonFormField<
                              ShippingProviderModel
                            >(
                              value: _selectedOtherProvider,
                              decoration: InputDecoration(
                                labelText: 'Proveedor',
                                hintText: _hasDeliveryPackages
                                    ? 'Selecciona el proveedor'
                                    : 'No necesario (casilleros)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                              ),
                              items: others
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _hasDeliveryPackages
                                  ? (v) =>
                                      setState(() => _selectedOtherProvider = v)
                                  : null,
                            );
                          },
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (e, _) => Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'Error al cargar proveedores: $e',
                              style: const TextStyle(
                                color: MBETheme.brandRed,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  ScannedPackagesSection(
                    packages: _packages,
                    onClear: _clearSelection,
                    onRemovePackage: (pkg) => _removePackage(pkg.id),
                    totalCount: totalPackages > 0 ? totalPackages : null,
                    emptyMessage: 'Escanea paquetes para agregar',
                    showLocation: true,
                    margin: EdgeInsets.zero,
                    expandedPackageId: _expandedPackageId,
                    onExpandedChanged: (id) =>
                        setState(() => _expandedPackageId = id),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom action bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                    flex: 2,
                    child: DSButton.primary(
                      label: _isConfirming
                          ? 'Confirmando...'
                          : 'Confirmar (${_packages.length})',
                      fullWidth: true,
                      icon: Iconsax.tick_circle,
                      isLoading: _isConfirming,
                      onPressed: (_packages.isEmpty ||
                              (_hasDeliveryPackages &&
                                  _selectedOtherProvider == null) ||
                              _isConfirming)
                          ? null
                          : _confirmGroup,
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
}
