import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../../core/design_system/ds_buttons.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../providers/rack_assignment_manager.dart';

class RackAssignmentModal extends ConsumerStatefulWidget {
  final List<String> packageIds;
  final int packageCount;

  const RackAssignmentModal({
    super.key,
    required this.packageIds,
    required this.packageCount,
  });

  @override
  ConsumerState<RackAssignmentModal> createState() =>
      _RackAssignmentModalState();
}

class _RackAssignmentModalState extends ConsumerState<RackAssignmentModal> {
  final TextEditingController _rackController = TextEditingController();
  final TextEditingController _segmentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _changeToReadyForPickup = false;
  bool _showRackScanner = false;
  bool _showSegmentScanner = false;
  late MobileScannerController _rackScannerController;
  late MobileScannerController _segmentScannerController;

  @override
  void initState() {
    super.initState();
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
    _rackController.dispose();
    _segmentController.dispose();
    _rackScannerController.dispose();
    _segmentScannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Asignar Rack y Segmento',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.close_circle),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.packageCount} paquete(s) seleccionado(s)',
                  style: TextStyle(
                    color: MBETheme.neutralGray,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // Input Rack
                Text(
                  'Rack *',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: MBETheme.brandBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _rackController,
                        decoration: InputDecoration(
                          hintText: 'Ej: A-12',
                          prefixIcon: const Icon(Iconsax.box),
                          suffixIcon: IconButton(
                            icon: const Icon(Iconsax.scan_barcode),
                            onPressed: () {
                              setState(() {
                                _showRackScanner = !_showRackScanner;
                                if (_showRackScanner) {
                                  _showSegmentScanner = false;
                                }
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el número de rack';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                if (_showRackScanner) ...[
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: MBETheme.neutralGray),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          MobileScanner(
                            controller: _rackScannerController,
                            onDetect: (capture) {
                              final barcodes = capture.barcodes;
                              for (final barcode in barcodes) {
                                if (barcode.rawValue != null) {
                                  setState(() {
                                    _rackController.text = barcode.rawValue!;
                                    _showRackScanner = false;
                                  });
                                  break;
                                }
                              }
                            },
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                setState(() => _showRackScanner = false);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Input Segmento
                Text(
                  'Segmento *',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: MBETheme.brandBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _segmentController,
                        decoration: InputDecoration(
                          hintText: 'Ej: 3-5',
                          prefixIcon: const Icon(Iconsax.location),
                          suffixIcon: IconButton(
                            icon: const Icon(Iconsax.scan_barcode),
                            onPressed: () {
                              setState(() {
                                _showSegmentScanner = !_showSegmentScanner;
                                if (_showSegmentScanner) {
                                  _showRackScanner = false;
                                }
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el número de segmento';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                if (_showSegmentScanner) ...[
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: MBETheme.neutralGray),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          MobileScanner(
                            controller: _segmentScannerController,
                            onDetect: (capture) {
                              final barcodes = capture.barcodes;
                              for (final barcode in barcodes) {
                                if (barcode.rawValue != null) {
                                  setState(() {
                                    _segmentController.text = barcode.rawValue!;
                                    _showSegmentScanner = false;
                                  });
                                  break;
                                }
                              }
                            },
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                setState(() => _showSegmentScanner = false);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Checkbox para cambiar estado
                CheckboxListTile(
                  value: _changeToReadyForPickup,
                  onChanged: (value) {
                    setState(() {
                      _changeToReadyForPickup = value ?? false;
                    });
                  },
                  title: const Text('Marcar como "Listo para Retiro"'),
                  subtitle: const Text(
                    'Cambiará el estado de los paquetes a "Lista para Retiro" después de asignar el rack',
                  ),
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: 24),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DSButton.primary(
                        label: _isLoading ? 'Asignando...' : 'Asignar',
                        fullWidth: true,
                        onPressed: _isLoading ? null : _assignRack,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _assignRack() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final rackManager = ref.read(rackAssignmentManagerProvider.notifier);
      final success = await rackManager.assignRack(
        packageIds: widget.packageIds,
        rackNumber: _rackController.text.trim(),
        segmentNumber: _segmentController.text.trim(),
        changeToReadyForPickup: _changeToReadyForPickup,
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Rack asignado exitosamente a ${widget.packageCount} paquete(s)',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al asignar rack'),
              backgroundColor: MBETheme.brandRed,
            ),
          );
        }
      }
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

