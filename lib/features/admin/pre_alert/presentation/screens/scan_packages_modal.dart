import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// --- TUS IMPORTS (Asegúrate que las rutas sean correctas) ---
import '../../../../../core/design_system/ds_buttons.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../data/models/admin_pre_alert_model.dart';
import '../../data/repositories/admin_pre_alerts_repository.dart';
import '../../providers/admin_pre_alerts_provider.dart';
import '../../providers/package_selection_provider.dart';
import '../../providers/context_counts_provider.dart';
import '../widgets/context_filter_segmented.dart';
import '../widgets/scan_input_field.dart';

class ScanPackagesModal extends ConsumerStatefulWidget {
  final PackageContext? mode;

  const ScanPackagesModal({super.key, this.mode});

  @override
  ConsumerState<ScanPackagesModal> createState() => _ScanPackagesModalState();
}

class _ScanPackagesModalState extends ConsumerState<ScanPackagesModal> {
  late MobileScannerController _scannerController;
  final TextEditingController _manualInputController = TextEditingController();
  bool _isFlashOn = false;
  bool _isProcessingReception = false;
  final Map<String, AdminPreAlert> _scannedPackages =
      {}; // Paquetes escaneados que no están en la lista
  String? _expandedPackageId; // ID del paquete expandido actualmente

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  String _getDynamicTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (widget.mode) {
      case PackageContext.porRecibir:
        return l10n.adminContextReception;
      case PackageContext.enBodega:
        return l10n.adminContextLocation;
      case PackageContext.paraEntregar:
        return l10n.adminContextDelivery;
      default:
        return l10n.adminContextScan;
    }
  }

  Color _getAccentColor() {
    switch (widget.mode) {
      case PackageContext.porRecibir:
        return Colors.blue;
      case PackageContext.enBodega:
        return Colors.amber;
      case PackageContext.paraEntregar:
        return Colors.green;
      default:
        return MBETheme.brandBlack;
    }
  }

  @override
  Widget build(BuildContext context) {
    final alertsState = ref.watch(adminPreAlertsProvider);
    final selectionState = ref.watch(packageSelectionProvider);
    final allAlerts = alertsState.value ?? [];
    final contextCountsState = ref.watch(contextCountsProvider);

    // Combinar paquetes de la lista con paquetes escaneados
    final allAvailablePackages = [...allAlerts, ..._scannedPackages.values];

    // Obtener paquetes seleccionados (de la lista o escaneados)
    final selectedAlerts = allAvailablePackages
        .where((alert) => selectionState.contains(alert.id))
        .toList()
        .reversed
        .toList();

    // Obtener el total de paquetes según el modo
    int totalPackages = 0;
    if (widget.mode != null && contextCountsState.hasValue) {
      totalPackages = contextCountsState.value![widget.mode!] ?? 0;
    } else {
      // Si no hay modo o no se ha cargado, usar la lista actual
      totalPackages = allAlerts.length;
    }

    final selectedCount = selectedAlerts.length;
    final progress = totalPackages > 0 ? selectedCount / totalPackages : 0.0;

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.95,
        decoration: const BoxDecoration(
          color: Color(0xFFF9F9F9), // Fondo gris muy suave
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Stack(
          children: [
            // CONTENIDO SCROLLABLE
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // 1. HEADER LIMPIO
                  _buildElegantHeader(context),

                  // 2. CÁMARA
                  Container(
                    height: 280,
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        children: [
                          MobileScanner(
                            controller: _scannerController,
                            onDetect: (capture) =>
                                _handleScanDetection(capture),
                          ),
                          // Overlay oscuro sutil
                          Container(color: Colors.black.withOpacity(0.1)),

                          // Guía visual central
                          Center(
                            child: Container(
                              width: 280,
                              height: 160,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.8),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Iconsax.scan,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 40,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Botón Flash
                          Positioned(
                            top: 7,
                            right: 7,
                            child: _buildGlassButton(
                              icon: _isFlashOn
                                  ? Iconsax.flash_1
                                  : Iconsax.flash_slash,
                              color: _isFlashOn ? Colors.yellow : Colors.white,
                              onTap: () {
                                _scannerController.toggleTorch();
                                setState(() => _isFlashOn = !_isFlashOn);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. INPUT FLOTANTE (dentro del scroll)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ScanInputField(
                      controller: _manualInputController,
                      onSubmitted: (val) => _processCode(val),
                      onScanPressed: () {
                        // Lógica opcional si tocan el botón del scanner manual
                        if (_manualInputController.text.isNotEmpty) {
                          _processCode(_manualInputController.text);
                        }
                      },
                      mode: widget.mode,
                      isLoading: false,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 4. CONTENEDOR BLANCO CON LA LISTA
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Padding superior
                        Padding(
                          padding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Contador y texto
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.adminReadyToProcess,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: MBETheme.neutralGray.withOpacity(
                                        0.8,
                                      ),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getAccentColor().withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "$selectedCount / $totalPackages",
                                      style: TextStyle(
                                        color: _getAccentColor(),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Barra de progreso
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 8,
                                      backgroundColor: Colors.grey.withOpacity(
                                        0.2,
                                      ),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getAccentColor(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${(progress * 100).toStringAsFixed(0)}% completado",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: MBETheme.neutralGray.withOpacity(
                                        0.6,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Lista de paquetes
                        selectedAlerts.isEmpty
                            ? SizedBox(height: 200, child: _buildEmptyState(context))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                itemCount: selectedAlerts.length,
                                itemBuilder: (context, index) {
                                  final package = selectedAlerts[index];
                                  return _buildElegantListItem(
                                    context,
                                    package,
                                    () {
                                      final packageId = package.id;
                                      // Remover de selección
                                      ref
                                          .read(
                                            packageSelectionProvider.notifier,
                                          )
                                          .toggleSelection(packageId);
                                      // Si estaba en escaneados, removerlo también
                                      if (_scannedPackages.containsKey(
                                        packageId,
                                      )) {
                                        setState(() {
                                          _scannedPackages.remove(packageId);
                                        });
                                      }
                                      // Si estaba expandido, cerrarlo
                                      if (_expandedPackageId == packageId) {
                                        setState(() {
                                          _expandedPackageId = null;
                                        });
                                      }
                                    },
                                  );
                                },
                              ),

                        // Espacio inferior para el botón fijo
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // BOTÓN FIJO EN LA PARTE INFERIOR
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: DSButton.primary(
                    label: selectedAlerts.isEmpty
                        ? AppLocalizations.of(context)!.preAlertClose
                        : _isProcessingReception
                        ? AppLocalizations.of(context)!.adminProcessing
                        : '${AppLocalizations.of(context)!.adminContextReception} (${selectedAlerts.length})',
                    fullWidth: true,
                    isLoading: _isProcessingReception,
                    onPressed: selectedAlerts.isEmpty
                        ? () {
                            Navigator.pop(context);
                          }
                        : _isProcessingReception
                        ? null
                        : () => _processReception(context, ref, selectedAlerts),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildElegantHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDynamicTitle(context),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 20, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildElegantListItem(
    BuildContext context,
    AdminPreAlert package,
    VoidCallback onRemove,
  ) {
    final isExpanded = _expandedPackageId == package.id;

    return Dismissible(
      key: Key(package.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.redAccent.withOpacity(0.1),
        child: const Icon(Icons.delete, color: Colors.redAccent),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ExpansionTile(
          key: ValueKey('expansion_${package.id}_$_expandedPackageId'),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              if (expanded) {
                // Si se expande este, contraer todos los demás
                _expandedPackageId = package.id;
              } else {
                // Si se contrae y es el que estaba expandido, limpiar
                if (_expandedPackageId == package.id) {
                  _expandedPackageId = null;
                }
              }
            });
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
              ],
            ),
            child: Icon(Iconsax.box, size: 20, color: _getAccentColor()),
          ),
          title: _buildCollapsedContent(package),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: _getAccentColor().withOpacity(0.8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Icon(
                isExpanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_2,
                color: _getAccentColor(),
                size: 18,
              ),
            ],
          ),
          children: [_buildExpandedContent(context, package)],
        ),
      ),
    );
  }

  // Contenido cuando está contraído (solo lo necesario)
  Widget _buildCollapsedContent(AdminPreAlert package) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Código del paquete
        Row(
          children: [
            Icon(Iconsax.code, size: 14, color: _getAccentColor()),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                package.eboxCode.isNotEmpty
                    ? package.trackingNumber
                    : package.trackingNumber,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Tienda y Productos en una línea
        Row(
          children: [
            Icon(Iconsax.shop, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                package.store,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.withOpacity(0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Icon(Iconsax.box_1, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '${package.productCount}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Contenido cuando está expandido (todos los detalles)
  Widget _buildExpandedContent(BuildContext context, AdminPreAlert package) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        const SizedBox(height: 12),
        // Grid de información completa
        Row(
          children: [
            // Tienda
            Expanded(
              child: _buildInfoChip(
                icon: Iconsax.shop,
                label: AppLocalizations.of(context)!.preAlertStoreLabel,
                value: package.store,
                color: _getAccentColor(),
              ),
            ),
            const SizedBox(width: 8),
            // Cantidad de productos
            Expanded(
              child: _buildInfoChip(
                icon: Iconsax.box_1,
                label: AppLocalizations.of(context)!.adminProducts,
                value: '${package.productCount}',
                color: _getAccentColor(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Peso (si está disponible)
            if (package.totalWeight != null)
              Expanded(
                child: _buildInfoChip(
                  icon: Iconsax.weight,
                  label: AppLocalizations.of(context)!.adminWeight,
                  value:
                      '${package.totalWeight!.toStringAsFixed(2)} ${package.weightType ?? ''}',
                  color: _getAccentColor(),
                ),
              ),
            if (package.totalWeight != null) const SizedBox(width: 8),
            // Precio total
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _getAccentColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.dollar_circle,
                          size: 14,
                          color: _getAccentColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context)!.adminTotalPrice,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${package.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getAccentColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Información adicional si está disponible
        if (package.provider.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
            ),
            child: Row(
              children: [
                Icon(Iconsax.truck, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Proveedor: ${package.provider}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.scan_barcode,
            size: 60,
            color: Colors.grey.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.adminReadyToScan,
            style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 16),
          ),
        ],
      ),
    );
  }

  // --- LÓGICA DE NEGOCIO ---
  void _handleScanDetection(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _processCode(barcode.rawValue!);
        break;
      }
    }
  }

  Future<void> _processCode(String code) async {
    if (code.trim().isEmpty) return;

    try {
      // Buscar en la API usando find-by-ebox
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      final package = await repository.findPackageByEbox(code.trim());

      // Obtener la lista actual para verificar si el paquete ya está en ella
      final alertsState = ref.read(adminPreAlertsProvider);
      final allAlerts = alertsState.value ?? [];

      if (package == null) {
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Código no encontrado: $code"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 2),
          ),
        );
        _manualInputController.clear();
        return;
      }

      final isAlreadySelected = ref
          .read(packageSelectionProvider)
          .contains(package.id);

      if (isAlreadySelected) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${package.trackingNumber} ya está en la lista"),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 1),
          ),
        );
        _manualInputController.clear();
        return;
      }

      // Agregar el paquete a la lista de escaneados si no está en allAlerts
      if (!allAlerts.any((alert) => alert.id == package.id)) {
        setState(() {
          _scannedPackages[package.id] = package;
        });
      }

      ref.read(packageSelectionProvider.notifier).toggleSelection(package.id);

      // Expandir automáticamente el paquete recién escaneado
      setState(() {
        _expandedPackageId = package.id;
      });

      HapticFeedback.mediumImpact();
      _manualInputController.clear();
    } catch (e) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al buscar código: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _processReception(
    BuildContext context,
    WidgetRef ref,
    List<AdminPreAlert> selectedAlerts,
  ) async {
    if (selectedAlerts.isEmpty) return;
    if (_isProcessingReception) return;

    setState(() => _isProcessingReception = true);
    final packageIds = selectedAlerts.map((a) => a.id).toList();

    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      final result = await repository.processReception(packageIds: packageIds);

      if (context.mounted) {
        // Limpiar selección solo después de procesar exitosamente
        ref.read(packageSelectionProvider.notifier).clearSelection();

        // Limpiar paquetes escaneados
        setState(() {
          _scannedPackages.clear();
        });

        // Refrescar lista y contadores
        ref.invalidate(adminPreAlertsProvider);
        ref.invalidate(contextCountsProvider);

        // Cerrar modal
        Navigator.pop(context);

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${result.processedCount} paquete(s) recibido(s) correctamente',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar recepción: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingReception = false);
      }
    }
  }
}
