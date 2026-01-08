import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../../core/design_system/ds_buttons.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../data/models/admin_pre_alert_model.dart';
import '../../data/models/package_status.dart';
import '../../data/models/reception_result.dart';
import '../../providers/reception_manager.dart';

class ReceptionScanScreen extends ConsumerStatefulWidget {
  const ReceptionScanScreen({super.key});

  @override
  ConsumerState<ReceptionScanScreen> createState() =>
      _ReceptionScanScreenState();
}

class _ReceptionScanScreenState extends ConsumerState<ReceptionScanScreen> {
  late MobileScannerController _scannerController;
  final TextEditingController _manualInputController = TextEditingController();
  bool _isFlashOn = false;
  final Set<String> _scannedPackageIds = {};
  final Map<String, AdminPreAlert> _scannedPackages = {};
  bool _isProcessing = false;

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
    final scannedCount = _scannedPackages.length;

    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Recepción de Paquetes',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: MBETheme.brandBlack,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: MBETheme.brandBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Indicador de progreso
          if (scannedCount > 0) _buildProgressIndicator(scannedCount),

          // Zona de cámara
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  child: MobileScanner(
                    controller: _scannerController,
                    onDetect: _handleScanDetection,
                  ),
                ),
                // Overlay de guía
                Center(
                  child: Container(
                    width: 250,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.scan,
                          color: Colors.white.withOpacity(0.8),
                          size: 40,
                        ),
                      ],
                    ),
                  ),
                ),
                // Controles de cámara
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.small(
                    backgroundColor: Colors.black54,
                    onPressed: () {
                      _scannerController.toggleTorch();
                      setState(() => _isFlashOn = !_isFlashOn);
                    },
                    child: Icon(
                      _isFlashOn ? Iconsax.flash_1 : Iconsax.flash_slash,
                      color: Colors.yellow,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Input manual
          Transform.translate(
            offset: const Offset(0, -24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                    hintText: 'Ingresar código ebox manualmente',
                    prefixIcon: const Icon(Iconsax.barcode, color: MBETheme.brandBlack),
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
          ),

          // Lista de paquetes escaneados
          Expanded(
            child: _scannedPackages.isEmpty
                ? Center(
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
                          'Escanea el código ebox de un paquete',
                          style: TextStyle(
                            color: MBETheme.neutralGray.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'El paquete será validado y agregado a la lista',
                          style: TextStyle(
                            color: MBETheme.neutralGray.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _scannedPackages.length,
                    itemBuilder: (context, index) {
                      final package = _scannedPackages.values.elementAt(index);
                      return _ScannedPackageCard(
                        package: package,
                        onRemove: () {
                          setState(() {
                            _scannedPackages.remove(package.id);
                            _scannedPackageIds.remove(package.id);
                          });
                        },
                      );
                    },
                  ),
          ),

          // Botón de finalizar
          if (_scannedPackages.isNotEmpty)
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
                child: DSButton.primary(
                  label: 'Finalizar Recepción (${_scannedPackages.length})',
                  fullWidth: true,
                  onPressed: _isProcessing ? null : _finalizeReception,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int scannedCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paquetes Escaneados',
                  style: TextStyle(
                    fontSize: 14,
                    color: MBETheme.neutralGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$scannedCount',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: MBETheme.brandBlack,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: MBETheme.brandBlack.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.tick_circle,
                  color: MBETheme.brandBlack,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Listo para recibir',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: MBETheme.brandBlack,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    // Limpiar input manual
    _manualInputController.clear();

    // Verificar si ya fue escaneado
    if (_scannedPackageIds.contains(code)) {
      HapticFeedback.vibrate();
      _showSnackBar('Este paquete ya fue escaneado', isError: true);
      return;
    }

    // Buscar paquete por ebox
    final receptionManager = ref.read(receptionManagerProvider.notifier);
    final package = await receptionManager.findPackageByEbox(code);

    if (package == null) {
      HapticFeedback.vibrate();
      _showSnackBar('Paquete no encontrado: $code', isError: true);
      return;
    }

    // Verificar que el paquete esté en un estado válido para recepción
    if (package.status != PackageStatus.listaParaRecibir) {
      HapticFeedback.vibrate();
      _showSnackBar(
        'El paquete no está listo para recibir. Estado: ${package.status.label}',
        isError: true,
      );
      return;
    }

    // Agregar a la lista
    setState(() {
      _scannedPackages[package.id] = package;
      _scannedPackageIds.add(code);
    });

    HapticFeedback.mediumImpact();
    _showSnackBar('Paquete escaneado: ${package.trackingNumber}', isError: false);
  }

  Future<void> _finalizeReception() async {
    if (_scannedPackages.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Recepción'),
        content: Text(
          '¿Deseas procesar la recepción de ${_scannedPackages.length} paquete(s)?\n\n'
          'Los paquetes cambiarán a estado "En Tienda" y se les asignará un rack automáticamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          DSButton.primary(
            label: 'Confirmar',
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
      final receptionManager = ref.read(receptionManagerProvider.notifier);
      final packageIds = _scannedPackages.keys.toList();
      final result = await receptionManager.processReception(
        packageIds: packageIds,
      );

      if (result != null && mounted) {
        // Mostrar mensaje de éxito con la ubicación asignada
        _showSuccessDialog(result);
      } else {
        if (mounted) {
          _showSnackBar('Error al procesar la recepción', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSuccessDialog(ReceptionResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Iconsax.tick_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            const Text('Recepción Exitosa'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${result.processedCount} paquete(s) procesado(s) exitosamente.',
              style: const TextStyle(fontSize: 16),
            ),
            if (result.failedCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                '${result.failedCount} paquete(s) fallaron.',
                style: TextStyle(
                  color: MBETheme.brandRed,
                  fontSize: 14,
                ),
              ),
            ],
            if (result.packages.isNotEmpty && 
                result.packages.first.rackNumber != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MBETheme.lightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ubicación Asignada:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Rack: ${result.packages.first.rackNumber}'),
                    Text('Segmento: ${result.packages.first.segmentNumber}'),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          DSButton.primary(
            label: 'Aceptar',
            fullWidth: true,
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              Navigator.of(context).pop(); // Volver a la lista
            },
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? MBETheme.brandRed : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _ScannedPackageCard extends StatelessWidget {
  final AdminPreAlert package;
  final VoidCallback onRemove;

  const _ScannedPackageCard({
    required this.package,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Icono de check
          const CircleAvatar(
            backgroundColor: Color(0xFFE8F5E9),
            radius: 20,
            child: Icon(Icons.check, size: 20, color: Colors.green),
          ),
          const SizedBox(width: 12),
          // Información del paquete
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.provider.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '#${package.trackingNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (package.eboxCode.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ebox: ${package.eboxCode}',
                    style: TextStyle(
                      fontSize: 12,
                      color: MBETheme.neutralGray,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Botón eliminar
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: MBETheme.brandRed,
            ),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

