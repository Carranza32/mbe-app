import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// --- TUS IMPORTS (Asegúrate que las rutas sean correctas) ---
import '../../../../../core/design_system/ds_buttons.dart';
import '../../../../../config/theme/mbe_theme.dart';
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
  final Map<String, AdminPreAlert> _scannedPackages = {}; // Paquetes escaneados que no están en la lista
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

  String _getDynamicTitle() {
    switch (widget.mode) {
      case PackageContext.porRecibir:
        return 'Recepción';
      case PackageContext.enBodega:
        return 'Ubicación';
      case PackageContext.paraEntregar:
        return 'Entrega';
      default:
        return 'Escanear';
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
    final allAvailablePackages = [
      ...allAlerts,
      ..._scannedPackages.values,
    ];

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
        child: Column(
          children: [
            // 1. HEADER LIMPIO
            _buildElegantHeader(context),

            // 2. CÁMARA (Ahora es independiente y limpia)
            Expanded(
              flex: 4,
              child: Container(
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
                        onDetect: (capture) => _handleScanDetection(capture),
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
            ),

            Expanded(
              flex: 5,
              child: Stack(
                clipBehavior: Clip
                    .none, // IMPORTANTE: Permite que el input flote hacia arriba
                children: [
                  // CAPA 1: EL CONTENEDOR BLANCO CON LA LISTA
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
                        // Padding superior extra (45) para que el texto no choque con el Input
                        Padding(
                          padding: const EdgeInsets.fromLTRB(28, 25, 28, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Contador y texto
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Listos para procesar",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: MBETheme.neutralGray.withOpacity(0.8),
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
                                      backgroundColor: Colors.grey.withOpacity(0.2),
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
                                      color: MBETheme.neutralGray.withOpacity(0.6),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: selectedAlerts.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
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
                                        if (_scannedPackages.containsKey(packageId)) {
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
                        ),

                        // Botón Footer
                        SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: DSButton.primary(
                              label: selectedAlerts.isEmpty
                                  ? 'Cerrar'
                                  : 'Procesar Recepción (${selectedAlerts.length})',
                              fullWidth: true,
                              onPressed: selectedAlerts.isEmpty
                                  ? () {
                                      // Solo cerrar, mantener la selección
                                      Navigator.pop(context);
                                    }
                                  : () => _processReception(context, ref, selectedAlerts),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // CAPA 2: EL INPUT FLOTANTE
                  // Al estar después en el Stack, se pinta ENCIMA del contenedor blanco.
                  // 'top: -28' lo sube justo a la mitad del borde.
                  Positioned(
                    top: -40,
                    left: 20,
                    right: 20,
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
                ],
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
          children: [
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
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDynamicTitle(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
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
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                ),
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
          children: [
            _buildExpandedContent(package),
          ],
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
            Icon(
              Iconsax.code,
              size: 14,
              color: _getAccentColor(),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                package.eboxCode.isNotEmpty
                    ? package.eboxCode
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
  Widget _buildExpandedContent(AdminPreAlert package) {
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
                label: 'Tienda',
                value: package.store,
                color: _getAccentColor(),
              ),
            ),
            const SizedBox(width: 8),
            // Cantidad de productos
            Expanded(
              child: _buildInfoChip(
                icon: Iconsax.box_1,
                label: 'Productos',
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
                  label: 'Peso',
                  value: '${package.totalWeight!.toStringAsFixed(2)} ${package.weightType ?? ''}',
                  color: _getAccentColor(),
                ),
              ),
            if (package.totalWeight != null) const SizedBox(width: 8),
            // Precio total
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                          'Precio Total',
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
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
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
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
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

  Widget _buildEmptyState() {
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
            "Listo para escanear",
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

    final packageIds = selectedAlerts.map((a) => a.id).toList();
    
    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      final result = await repository.processReception(
        packageIds: packageIds,
      );

      if (context.mounted) {
        // Limpiar selección solo después de procesar exitosamente
        ref.read(packageSelectionProvider.notifier).clearSelection();
        
        // Limpiar paquetes escaneados
        setState(() {
          _scannedPackages.clear();
        });
        
        // Refrescar lista
        ref.invalidate(adminPreAlertsProvider);
        
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
    }
  }
}
