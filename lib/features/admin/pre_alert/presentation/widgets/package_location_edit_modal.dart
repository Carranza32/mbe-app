import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../../core/design_system/ds_buttons.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../data/models/admin_pre_alert_model.dart';
import '../../data/models/warehouse_location_model.dart';
import '../../data/repositories/admin_pre_alerts_repository.dart';
import '../../providers/warehouse_locations_provider.dart';

class PackageLocationEditModal extends ConsumerStatefulWidget {
  final AdminPreAlert package;

  const PackageLocationEditModal({super.key, required this.package});

  @override
  ConsumerState<PackageLocationEditModal> createState() =>
      _PackageLocationEditModalState();
}

class _PackageLocationEditModalState
    extends ConsumerState<PackageLocationEditModal> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _showRackScanner = false;
  bool _showSegmentScanner = false;

  String? _selectedRack;
  String? _selectedSegment;
  late MobileScannerController _rackScannerController;
  late MobileScannerController _segmentScannerController;

  @override
  void initState() {
    super.initState();
    // Normalizar valores del paquete
    // Asegurarse de que el rack esté en mayúsculas y sin espacios
    if (widget.package.rackNumber != null && widget.package.rackNumber!.isNotEmpty) {
      _selectedRack = widget.package.rackNumber!.trim().toUpperCase();
    } else {
      _selectedRack = null;
    }
    
    // Normalizar segmento a formato de 2 dígitos (01, 02, etc.)
    if (widget.package.segmentNumber != null && widget.package.segmentNumber!.isNotEmpty) {
      final segment = widget.package.segmentNumber!.trim();
      // Si es un solo dígito, agregar el 0 al inicio
      _selectedSegment = segment.length == 1 ? '0$segment' : segment.padLeft(2, '0');
    } else {
      _selectedSegment = null;
    }
    
    _rackScannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
    _segmentScannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _rackScannerController.dispose();
    _segmentScannerController.dispose();
    super.dispose();
  }

  void _handleRackScan(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final scannedValue = barcode.rawValue!.trim().toUpperCase();
        // Limpiar el valor escaneado (puede venir como "RACK-A" o solo "A")
        final rackValue = scannedValue.replaceAll('RACK', '').replaceAll('-', '').trim();
        
        HapticFeedback.lightImpact();
        setState(() {
          _selectedRack = rackValue;
          _showRackScanner = false;
          // Limpiar segmento cuando cambia el rack
          _selectedSegment = null;
        });
        break;
      }
    }
  }

  void _handleSegmentScan(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final scannedValue = barcode.rawValue!.trim();
        // Limpiar el valor escaneado (puede venir como "SEG-01" o solo "01")
        final segmentValue = scannedValue.replaceAll('SEG', '').replaceAll('-', '').trim();
        final normalizedSegment = segmentValue.padLeft(2, '0');
        
        HapticFeedback.lightImpact();
        
        // Buscar el segmento en todas las ubicaciones para encontrar su rack
        final storeId = widget.package.storeId ?? 1;
        final locationsAsync = ref.read(warehouseLocationsProvider(
          storeId: storeId,
          availableOnly: false,
        ));
        
        locationsAsync.whenData((locations) {
          // Buscar el segmento en todas las ubicaciones
          final location = locations.firstWhere(
            (loc) => loc.segmentNumber == normalizedSegment,
            orElse: () => WarehouseLocation(
              rackNumber: _selectedRack ?? 'A',
              segmentNumber: normalizedSegment,
              isAvailable: true,
            ),
          );
          
          if (mounted) {
            setState(() {
              _selectedRack = location.rackNumber;
              _selectedSegment = location.segmentNumber;
              _showSegmentScanner = false;
            });
          }
        });
        
        // Si no hay datos aún, usar el rack actual o por defecto
        if (!locationsAsync.hasValue) {
          if (mounted) {
            setState(() {
              _selectedSegment = normalizedSegment;
              if (_selectedRack == null) {
                _selectedRack = 'A'; // Rack por defecto
              }
              _showSegmentScanner = false;
            });
          }
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final storeId = widget.package.storeId ?? 1;

    // Obtener todas las ubicaciones
    final allLocationsState = ref.watch(warehouseLocationsProvider(
      storeId: storeId,
      availableOnly: false,
    ));

    // Obtener ubicaciones del rack seleccionado (si hay uno)
    final rackLocationsState = _selectedRack != null
        ? ref.watch(warehouseLocationsProvider(
            storeId: storeId,
            availableOnly: false,
            rackNumber: _selectedRack!,
          ))
        : null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Editar Ubicación',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: MBETheme.brandBlack,
                      ),
                    ),
                    Text(
                      widget.package.trackingNumber,
                      style: TextStyle(
                        color: MBETheme.neutralGray.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey[100],
                    child: const Icon(
                      Iconsax.close_circle,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Ubicación en Bodega'),
                    const SizedBox(height: 16),
                    
                    // Rack con dropdown y escáner
                    allLocationsState.when(
                      data: (locations) => _buildRackSelector(locations),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, stack) => _buildErrorState(
                        'Error al cargar racks: ${error.toString()}',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Segmento con dropdown y escáner
                    if (_selectedRack != null)
                      rackLocationsState?.when(
                        data: (locations) => _buildSegmentSelector(locations),
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, stack) => _buildErrorState(
                          'Error al cargar segmentos: ${error.toString()}',
                        ),
                      ) ?? const SizedBox.shrink(),
                    
                    if (_selectedRack == null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: MBETheme.lightGray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.info_circle,
                              color: MBETheme.brandBlack.withValues(alpha: 0.7),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Selecciona un rack para ver los segmentos disponibles',
                                style: TextStyle(
                                  color: MBETheme.neutralGray,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Escáner de rack (si está activo)
                    if (_showRackScanner) ...[
                      const SizedBox(height: 16),
                      _buildScanner(
                        controller: _rackScannerController,
                        onDetect: _handleRackScan,
                        onClose: () => setState(() => _showRackScanner = false),
                        label: 'Escaneando Rack',
                      ),
                    ],
                    
                    // Escáner de segmento (si está activo)
                    if (_showSegmentScanner) ...[
                      const SizedBox(height: 16),
                      _buildScanner(
                        controller: _segmentScannerController,
                        onDetect: _handleSegmentScan,
                        onClose: () => setState(() => _showSegmentScanner = false),
                        label: 'Escaneando Segmento',
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: MBETheme.lightGray,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.info_circle,
                            color: MBETheme.brandBlack.withValues(alpha: 0.7),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'La ubicación se actualizará inmediatamente después de guardar',
                              style: TextStyle(
                                color: MBETheme.neutralGray,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomInset),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: DSButton.primary(
              label: _isLoading ? 'Guardando...' : 'Guardar Ubicación',
              fullWidth: true,
              icon: Iconsax.tick_circle,
              onPressed: (_isLoading) ? null : _saveLocation,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: MBETheme.neutralGray.withValues(alpha: 0.7),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildRackSelector(List<WarehouseLocation> locations) {
    // Obtener racks únicos
    final racks = locations.map((loc) => loc.rackNumber).toSet().toList()..sort();
    
    // Asegurar que el rack seleccionado esté en la lista (si existe)
    String? validRack = _selectedRack;
    if (_selectedRack != null && !racks.contains(_selectedRack)) {
      // Si el rack no está en la lista, agregarlo temporalmente
      racks.add(_selectedRack!);
      racks.sort();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rack *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: MBETheme.brandBlack,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Dropdown de racks
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButtonFormField<String>(
                  value: validRack,
                  decoration: InputDecoration(
                    labelText: 'Seleccionar Rack',
                    labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    icon: const Icon(Iconsax.location, color: Colors.black87, size: 20),
                    border: InputBorder.none,
                  ),
                  items: racks.map((rack) {
                    return DropdownMenuItem(
                      value: rack,
                      child: Text(
                        rack,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRack = value;
                        // Limpiar segmento cuando cambia el rack
                        _selectedSegment = null;
                      });
                    }
                  },
                  validator: (value) {
                    if (_selectedRack == null || _selectedRack!.isEmpty) {
                      return 'Requerido';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Botón de escaneo
            Container(
              decoration: BoxDecoration(
                color: MBETheme.brandBlack,
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                icon: Icon(
                  _showRackScanner ? Iconsax.scan_barcode : Iconsax.scan,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _showRackScanner = !_showRackScanner;
                    if (_showRackScanner) {
                      _showSegmentScanner = false;
                    }
                  });
                },
                tooltip: 'Escanear Rack',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSegmentSelector(List<WarehouseLocation> locations) {
    // Obtener segmentos únicos del rack seleccionado
    final segments = locations
        .where((loc) => loc.rackNumber == _selectedRack)
        .map((loc) => loc.segmentNumber)
        .toSet()
        .toList()
      ..sort();
    
    // Asegurar que el segmento seleccionado esté en la lista (si existe)
    String? validSegment = _selectedSegment;
    if (_selectedSegment != null && !segments.contains(_selectedSegment)) {
      // Si el segmento no está en la lista, agregarlo temporalmente
      segments.add(_selectedSegment!);
      segments.sort();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Segmento *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: MBETheme.brandBlack,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Dropdown de segmentos
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButtonFormField<String>(
                  value: validSegment,
                  decoration: InputDecoration(
                    labelText: 'Seleccionar Segmento',
                    labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    icon: const Icon(Iconsax.location, color: Colors.black87, size: 20),
                    border: InputBorder.none,
                  ),
                  items: segments.map((segment) {
                    final location = locations.firstWhere(
                      (loc) => loc.segmentNumber == segment && loc.rackNumber == _selectedRack,
                      orElse: () => WarehouseLocation(
                        rackNumber: _selectedRack!,
                        segmentNumber: segment,
                        isAvailable: true,
                      ),
                    );
                    return DropdownMenuItem(
                      value: segment,
                      child: Row(
                        children: [
                          Text(
                            segment,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!location.isAvailable)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Ocupado',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange[800],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSegment = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (_selectedSegment == null || _selectedSegment!.isEmpty) {
                      return 'Requerido';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Botón de escaneo (aunque la búsqueda por segmento aún no esté en la API)
            Container(
              decoration: BoxDecoration(
                color: MBETheme.brandBlack,
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                icon: Icon(
                  _showSegmentScanner ? Iconsax.scan_barcode : Iconsax.scan,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _showSegmentScanner = !_showSegmentScanner;
                    if (_showSegmentScanner) {
                      _showRackScanner = false;
                    }
                  });
                },
                tooltip: 'Escanear Segmento',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Iconsax.danger, color: Colors.red[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanner({
    required MobileScannerController controller,
    required Function(BarcodeCapture) onDetect,
    required VoidCallback onClose,
    required String label,
  }) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MBETheme.brandBlack, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            MobileScanner(
        controller: controller,
              onDetect: onDetect,
            ),
            // Overlay con guía
            Center(
              child: Container(
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            // Botón cerrar
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onClose,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveLocation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRack == null || _selectedSegment == null) return;
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      await repository.updatePackageLocation(
        packageId: widget.package.id,
        rackNumber: _selectedRack!.trim().toUpperCase(),
        segmentNumber: _selectedSegment!.trim().padLeft(2, '0'),
      );

      if (!mounted) return;

      // Invalidar providers para refrescar datos
      ref.invalidate(warehouseLocationsProvider(
        storeId: widget.package.storeId ?? 1,
        availableOnly: false,
      ));

      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ubicación actualizada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: MBETheme.brandRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
