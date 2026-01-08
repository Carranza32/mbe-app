import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../../core/design_system/ds_buttons.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../data/models/admin_pre_alert_model.dart';
import '../../data/models/package_status.dart';
import '../../data/repositories/admin_pre_alerts_repository.dart';
import '../widgets/pickup_delivery_modal.dart';
import '../widgets/delivery_dispatch_sheet.dart';

class QuickDeliveryScanModal extends ConsumerStatefulWidget {
  const QuickDeliveryScanModal({super.key});

  @override
  ConsumerState<QuickDeliveryScanModal> createState() =>
      _QuickDeliveryScanModalState();
}

class _QuickDeliveryScanModalState
    extends ConsumerState<QuickDeliveryScanModal> {
  late MobileScannerController _scannerController;
  final TextEditingController _manualInputController = TextEditingController();
  bool _isFlashOn = false;
  bool _isProcessing = false;
  AdminPreAlert? _scannedPackage;
  bool _isPackageExpanded = false;

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.95,
        decoration: const BoxDecoration(
          color: Color(0xFFF9F9F9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            _buildHeader(context),
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
                        onDetect: _handleScanDetection,
                      ),
                      Container(color: Colors.black.withOpacity(0.1)),
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
                clipBehavior: Clip.none,
                children: [
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(28, 25, 28, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _scannedPackage == null
                                    ? "Listos para procesar"
                                    : "Paquete Escaneado",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: MBETheme.neutralGray.withOpacity(0.8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (_scannedPackage != null)
                                Text(
                                  '1/1',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: MBETheme.neutralGray,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _scannedPackage == null
                              ? _buildEmptyState()
                              : _buildPackageInfo(),
                        ),
                        SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: DSButton.primary(
                              label: _scannedPackage == null
                                  ? 'Escanear Código'
                                  : _isProcessing
                                  ? 'Procesando...'
                                  : 'Procesar Entrega',
                              fullWidth: true,
                              onPressed:
                                  _scannedPackage == null || _isProcessing
                                  ? null
                                  : _processDelivery,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Input manual redondo (como en recepción)
                  Positioned(
                    top: -24,
                    left: 24,
                    right: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: MBETheme.shadowMd,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: TextField(
                        controller: _manualInputController,
                        decoration: InputDecoration(
                          hintText: 'Ingresar código manualmente',
                          prefixIcon: const Icon(
                            Iconsax.barcode,
                            color: MBETheme.brandBlack,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            _processCode(value.trim());
                          }
                        },
                      ),
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

  Widget _buildHeader(BuildContext context) {
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
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Escanear retiro',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Escanea y procesa entregas',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
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
            "Escanea un código para procesar",
            style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageInfo() {
    final package = _scannedPackage!;
    final isPickup = package.deliveryMethod == 'pickup';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta principal colapsable
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header de la tarjeta (siempre visible)
                InkWell(
                  onTap: () {
                    setState(() {
                      _isPackageExpanded = !_isPackageExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (isPickup ? Colors.blue : Colors.green)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (isPickup ? Colors.blue : Colors.green)
                            .withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isPickup ? Colors.blue : Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPickup ? Iconsax.shop : Iconsax.truck,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPickup
                                    ? 'Entrega en Tienda'
                                    : 'Entrega a Domicilio',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                package.trackingNumber,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _isPackageExpanded
                              ? Iconsax.arrow_up_2
                              : Iconsax.arrow_down_2,
                          color: MBETheme.brandBlack,
                        ),
                      ],
                    ),
                  ),
                ),
                // Contenido expandible
                if (_isPackageExpanded)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          Iconsax.user,
                          'Cliente',
                          package.clientName,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Iconsax.box_1,
                          'Ebox Code',
                          package.eboxCode,
                        ),
                        if (package.rackNumber != null &&
                            package.segmentNumber != null) ...[
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            Iconsax.location,
                            'Ubicación',
                            '${package.rackNumber}-${package.segmentNumber}',
                          ),
                        ],
                        if (package.products != null &&
                            package.products!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 12),
                          Text(
                            'Productos',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: MBETheme.brandBlack,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...package.products!.map((product) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Iconsax.box,
                                    size: 16,
                                    color: MBETheme.neutralGray,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.productCategoryName ??
                                              'Sin categoría',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (product.description != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            product.description!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: MBETheme.neutralGray,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            _buildInfoChip(
                                              'Cant: ${product.quantity}',
                                            ),
                                            if (product.weight != null) ...[
                                              const SizedBox(width: 8),
                                              _buildInfoChip(
                                                'Peso: ${product.weight!.toStringAsFixed(2)} ${product.weightType ?? 'LB'}',
                                              ),
                                            ],
                                            const SizedBox(width: 8),
                                            _buildInfoChip(
                                              '\$${product.price.toStringAsFixed(2)}',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Iconsax.box_1,
                                  size: 16,
                                  color: MBETheme.neutralGray,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Productos: ${package.productCount}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: MBETheme.neutralGray,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            if (package.totalWeight != null) ...[
                              Row(
                                children: [
                                  Icon(
                                    Iconsax.weight,
                                    size: 16,
                                    color: MBETheme.neutralGray,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Peso: ${package.totalWeight!.toStringAsFixed(2)} ${package.weightType ?? 'LB'}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: MBETheme.neutralGray,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: MBETheme.brandBlack.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Precio Total',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '\$${package.total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: MBETheme.brandBlack,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: MBETheme.neutralGray),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: MBETheme.neutralGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: MBETheme.lightGray,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: MBETheme.brandBlack,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

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
    if (code.trim().isEmpty || _isProcessing) return;

    setState(() {
      _scannedPackage = null;
      _isProcessing = true;
      _isPackageExpanded = false;
    });

    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      final package = await repository.findPackageByEbox(code.trim());

      if (package == null) {
        HapticFeedback.vibrate();
        if (mounted) {
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
        }
        _manualInputController.clear();
        setState(() => _isProcessing = false);
        return;
      }

      // Validar que el paquete esté en estado "Lista para Retiro" o "Confirmada Recolección"
      if (package.status != PackageStatus.listaRetiro &&
          package.status != PackageStatus.confirmadaRecoleccion) {
        HapticFeedback.vibrate();
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Este paquete no está listo para retiro. Estado actual: ${package.status.label}',
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(20),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        _manualInputController.clear();
        setState(() => _isProcessing = false);
        return;
      }

      setState(() {
        _scannedPackage = package;
        _isProcessing = false;
        _isPackageExpanded = true; // Expandir automáticamente al escanear
      });
      _manualInputController.clear();
      HapticFeedback.mediumImpact();
    } catch (e) {
      HapticFeedback.vibrate();
      if (mounted) {
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
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _processDelivery() async {
    if (_scannedPackage == null || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final package = _scannedPackage!;
      final isPickup = package.deliveryMethod == 'pickup';

      if (isPickup) {
        // Procesar Pickup - mostrar modal de firma
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PickupDeliveryModal(packages: [package]),
            fullscreenDialog: true,
          ),
        );

        if (result == true && mounted) {
          // Limpiar y continuar escaneando
          setState(() {
            _scannedPackage = null;
            _isProcessing = false;
            _isPackageExpanded = false;
          });
          _manualInputController.clear();
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Entrega procesada correctamente'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          setState(() => _isProcessing = false);
        }
      } else {
        // Procesar Delivery - mostrar modal de proveedor
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeliveryDispatchSheet(packages: [package]),
            fullscreenDialog: true,
          ),
        );

        if (result == true && mounted) {
          // Limpiar y continuar escaneando
          setState(() {
            _scannedPackage = null;
            _isProcessing = false;
            _isPackageExpanded = false;
          });
          _manualInputController.clear();
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Despacho procesado correctamente'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          setState(() => _isProcessing = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      setState(() => _isProcessing = false);
    }
  }
}
