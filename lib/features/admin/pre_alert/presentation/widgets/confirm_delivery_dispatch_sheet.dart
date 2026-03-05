import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../../core/design_system/ds_buttons.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../data/models/admin_pre_alert_model.dart';
import '../../data/models/shipping_provider_model.dart';
import '../../data/repositories/admin_pre_alerts_repository.dart';
import '../../providers/delivery_manager.dart';
import '../../providers/shipping_providers_provider.dart';
import '../../providers/admin_pre_alerts_provider.dart';
import '../../providers/context_counts_provider.dart';
import '../widgets/context_filter_segmented.dart';
import 'scanned_packages_section.dart';
import 'signature_capture_widget.dart';

/// Sheet "Confirmar salida" para el sub-tab **Listos para salir**.
/// Escanear paquetes (find-for-dispatch), elegir proveedor, guía externa si aplica, firma opcional, confirmar → En Camino.
class ConfirmDeliveryDispatchSheet extends ConsumerStatefulWidget {
  const ConfirmDeliveryDispatchSheet({super.key});

  @override
  ConsumerState<ConfirmDeliveryDispatchSheet> createState() =>
      _ConfirmDeliveryDispatchSheetState();
}

class _ConfirmDeliveryDispatchSheetState
    extends ConsumerState<ConfirmDeliveryDispatchSheet> {
  late MobileScannerController _scannerController;
  final List<AdminPreAlert> _packages = [];
  final _trackingController = TextEditingController();
  bool _isProcessingCode = false;
  bool _isConfirming = false;
  bool _hasSignature = false;

  ShippingProviderModel? _selectedProvider;
  String? _expandedPackageId;
  final GlobalKey<SignatureCaptureWidgetState> _signatureKey =
      GlobalKey<SignatureCaptureWidgetState>();

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
    _trackingController.dispose();
    super.dispose();
  }

  Future<void> _onScanOrSubmit(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return;

    setState(() => _isProcessingCode = true);
    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      final package = await repository.findPackageForDispatch(trimmed);

      if (!mounted) return;

      if (package == null) {
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Paquete no encontrado o no está en Listos para salir: $trimmed',
            ),
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

      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Paquete escaneado · ${package.trackingNumber}. Total: ${_packages.length}',
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

  void _removePackage(String id) {
    setState(() {
      _packages.removeWhere((p) => p.id == id);
      if (_expandedPackageId == id) {
        _expandedPackageId = _packages.isNotEmpty ? _packages.first.id : null;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _packages.clear();
      _selectedProvider = null;
      _hasSignature = false;
      _expandedPackageId = null;
    });
    _signatureKey.currentState?.clear();
  }

  bool get _isBoxful => _selectedProvider?.slug.toLowerCase() == 'boxful';
  bool get _trackingRequired => !_isBoxful;

  void _handleScanDetection(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null && barcode.rawValue!.trim().isNotEmpty) {
        _onScanOrSubmit(barcode.rawValue!);
        break;
      }
    }
  }

  Future<void> _confirmDispatch() async {
    if (_packages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.adminScanAtLeastOne),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }

    setState(() => _isConfirming = true);

    String? signatureBase64;
    final signatureState = _signatureKey.currentState;
    if (signatureState != null && signatureState.hasSignature) {
      signatureBase64 = await signatureState.captureSignature();
      if (signatureBase64 != null && signatureBase64.isNotEmpty) {
        if (!signatureBase64.startsWith('data:')) {
          signatureBase64 = 'data:image/png;base64,$signatureBase64';
        }
      }
    }

    try {
      final deliveryManager = ref.read(deliveryManagerProvider.notifier);
      final success = await deliveryManager.processDeliveryDispatch(
        packageIds: _packages.map((p) => p.id).toList(),
        signatureBase64: signatureBase64,
      );

      if (!mounted) return;

      if (success) {
        ref.invalidate(adminPreAlertsProvider);
        ref.invalidate(contextCountsProvider);
        ref.invalidate(solicitudEnvioSubCountsProvider);
        ref.invalidate(confirmacionesSubCountsProvider);
        ref.invalidate(enCaminoSubCountsProvider);
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Salida confirmada (${_packages.length} paquete(s)). Pasan a En Camino.',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        throw Exception(AppLocalizations.of(context)!.adminDispatchError);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
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
        countsMap?[PackageContext.confirmacionesDeEnvio] ?? 0;

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
          'Confirmar salida',
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

                  // Lista de paquetes escaneados (misma vista que Procesar Envío)
                  ScannedPackagesSection(
                    packages: _packages,
                    onClear: _clearSelection,
                    onRemovePackage: (pkg) => _removePackage(pkg.id),
                    totalCount: totalPackages > 0 ? totalPackages : null,
                    emptyMessage: 'Escanea paquetes listos para salir',
                    showLocation: true,
                    margin: EdgeInsets.zero,
                    expandedPackageId: _expandedPackageId,
                    onExpandedChanged: (id) =>
                        setState(() => _expandedPackageId = id),
                  ),

                  const SizedBox(height: 20),

                  // Firma del proveedor (debajo de la lista; al firmar se habilita Confirmar)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: MBETheme.shadowMd,
                    ),
                    child: SignatureCaptureWidget(
                      key: _signatureKey,
                      title: 'Firma del proveedor *',
                      onSignatureChanged: (has) {
                        setState(() => _hasSignature = has);
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Barra inferior: Limpiar + Confirmar salida (habilitado solo con firma)
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
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DSButton.primary(
                      label: _isConfirming
                          ? 'Confirmando...'
                          : 'Confirmar salida (${_packages.length})',
                      fullWidth: true,
                      icon: Iconsax.truck_fast,
                      isLoading: _isConfirming,
                      onPressed: _canConfirm ? _confirmDispatch : null,
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

  bool get _canConfirm {
    if (_packages.isEmpty || _isConfirming) {
      return false;
    }
    return _hasSignature;
  }
}
