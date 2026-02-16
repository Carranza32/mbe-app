import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../../core/design_system/ds_buttons.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../../../../l10n/app_localizations.dart';
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
  final List<AdminPreAlert> _scannedPackages = [];
  String? _expandedPackageId; // ID del paquete expandido actualmente
  int? _pickupPendingCount; // Total de paquetes pickup pendientes del cliente
  int?
  _deliveryPendingCount; // Total de paquetes delivery pendientes del cliente

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

  Widget _buildCameraSection(BuildContext context) {
    final containerDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );

    return Container(
      height: 280,
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      decoration: containerDecoration,
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
                icon: _isFlashOn ? Iconsax.flash_1 : Iconsax.flash_slash,
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
    );
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
        child: Stack(
          children: [
            // CONTENIDO SCROLLABLE
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // 1. HEADER
                  _buildHeader(context),

                  // 2. CÁMARA (o mensaje si no hay permiso)
                  _buildCameraSection(context),

                  // 3. INPUT MANUAL
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          hintText: AppLocalizations.of(context)!.adminEnterCodeManually,
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

                  const SizedBox(height: 24),

                  // 4. CONTENEDOR BLANCO CON LA INFORMACIÓN DEL PAQUETE
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
                          padding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _scannedPackages.isEmpty
                                        ? AppLocalizations.of(context)!.adminReadyToProcess
                                        : AppLocalizations.of(context)!.adminPackagesScanned,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: MBETheme.neutralGray.withOpacity(
                                        0.8,
                                      ),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  if (_scannedPackages.isNotEmpty)
                                    Row(
                                      children: [
                                        // Contador del tipo actual con progreso
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getDeliveryTypeColor()
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            _getProgressText(),
                                            style: TextStyle(
                                              color: _getDeliveryTypeColor(),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        // Contador del otro tipo (si existe)
                                        if (_getOtherTypeCount() > 0) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getOtherTypeColor()
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  _getOtherTypeIcon(),
                                                  size: 12,
                                                  color: _getOtherTypeColor(),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${_getOtherTypeCount()}',
                                                  style: TextStyle(
                                                    color: _getOtherTypeColor(),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                ],
                              ),
                              if (_scannedPackages.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      _scannedPackages.first.deliveryMethod ==
                                              'pickup'
                                          ? Iconsax.shop
                                          : Iconsax.truck,
                                      size: 14,
                                      color: MBETheme.neutralGray,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _scannedPackages.first.deliveryMethod ==
                                              'pickup'
                                          ? AppLocalizations.of(context)!.adminStoreDelivery
                                          : AppLocalizations.of(context)!.adminHomeDelivery,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: MBETheme.neutralGray,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Iconsax.user,
                                      size: 14,
                                      color: MBETheme.neutralGray,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        _scannedPackages.first.clientName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: MBETheme.neutralGray,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                // Barra de progreso
                                if (_getTotalPendingForCurrentType() > 0) ...[
                                  const SizedBox(height: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: LinearProgressIndicator(
                                          value: _getProgressValue(),
                                          minHeight: 8,
                                          backgroundColor: Colors.grey
                                              .withOpacity(0.2),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                _getDeliveryTypeColor(),
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _getProgressPercentageText(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: MBETheme.neutralGray
                                              .withOpacity(0.6),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                        _scannedPackages.isEmpty
                            ? SizedBox(height: 200, child: _buildEmptyState(context))
                            : _buildPackagesList(),
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
              bottom: 0,
              left: 0,
              right: 0,
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
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: DSButton.primary(
                    label: _scannedPackages.isEmpty
                        ? AppLocalizations.of(context)!.adminScanCode
                        : _isProcessing
                        ? AppLocalizations.of(context)!.adminProcessing
                        : '${AppLocalizations.of(context)!.adminProcessDelivery} (${_scannedPackages.length})',
                    fullWidth: true,
                    isLoading: _isProcessing,
                    onPressed: _scannedPackages.isEmpty || _isProcessing
                        ? null
                        : _processDelivery,
                  ),
                ),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.adminScanWithdrawal,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.adminScanAndProcess,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
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
            AppLocalizations.of(context)!.adminScanCodeToProcess,
            style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _scannedPackages.length,
      itemBuilder: (context, index) {
        final package = _scannedPackages[index];
        return _buildPackageListItem(context, package);
      },
    );
  }

  Widget _buildPackageListItem(BuildContext context, AdminPreAlert package) {
    final isExpanded = _expandedPackageId == package.id;
    final isPickup = package.deliveryMethod == 'pickup';

    return Dismissible(
      key: Key(package.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        setState(() {
          _scannedPackages.removeWhere((p) => p.id == package.id);
          if (_expandedPackageId == package.id) {
            _expandedPackageId = null;
          }
        });
        HapticFeedback.mediumImpact();
      },
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
                _expandedPackageId = package.id;
              } else {
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
            child: Icon(
              isPickup ? Iconsax.shop : Iconsax.truck,
              size: 20,
              color: isPickup ? Colors.blue : Colors.green,
            ),
          ),
          title: _buildCollapsedContent(package),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: (isPickup ? Colors.blue : Colors.green).withOpacity(0.8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Icon(
                isExpanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_2,
                color: MBETheme.brandBlack,
                size: 18,
              ),
            ],
          ),
          children: [_buildExpandedContent(context, package)],
        ),
      ),
    );
  }

  Widget _buildCollapsedContent(AdminPreAlert package) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Iconsax.code, size: 14, color: _getDeliveryTypeColor()),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                package.eboxCode.isNotEmpty
                    ? package.trackingNumber
                    : package.trackingNumber,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          package.clientName,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent(BuildContext context, AdminPreAlert package) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(Iconsax.user, l10n.adminClient, package.clientName),
        const SizedBox(height: 12),
        _buildDetailRow(Iconsax.box_1, l10n.adminEboxCode, package.eboxCode),
        if (package.rackNumber != null && package.segmentNumber != null) ...[
          const SizedBox(height: 12),
          _buildDetailRow(
            Iconsax.location,
            l10n.printOrderLocation,
            '${package.rackNumber}-${package.segmentNumber}',
          ),
        ],
        if (package.products != null && package.products!.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            l10n.adminProducts,
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
                  Icon(Iconsax.box, size: 16, color: MBETheme.neutralGray),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.productCategoryName ?? l10n.adminNoCategory,
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
                            _buildInfoChip('Cant: ${product.quantity}'),
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
                Icon(Iconsax.box_1, size: 16, color: MBETheme.neutralGray),
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
                  Icon(Iconsax.weight, size: 16, color: MBETheme.neutralGray),
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
              Text(
                l10n.adminTotalPrice,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
    );
  }

  Color _getDeliveryTypeColor() {
    if (_scannedPackages.isEmpty) return MBETheme.brandBlack;
    return _scannedPackages.first.deliveryMethod == 'pickup'
        ? Colors.blue
        : Colors.green;
  }

  Color _getOtherTypeColor() {
    if (_scannedPackages.isEmpty) return MBETheme.brandBlack;
    return _scannedPackages.first.deliveryMethod == 'pickup'
        ? Colors.green
        : Colors.blue;
  }

  IconData _getOtherTypeIcon() {
    if (_scannedPackages.isEmpty) return Iconsax.box;
    return _scannedPackages.first.deliveryMethod == 'pickup'
        ? Iconsax.truck
        : Iconsax.shop;
  }

  int _getTotalPendingForCurrentType() {
    if (_scannedPackages.isEmpty) return 0;
    final isPickup = _scannedPackages.first.deliveryMethod == 'pickup';
    return isPickup ? (_pickupPendingCount ?? 0) : (_deliveryPendingCount ?? 0);
  }

  int _getOtherTypeCount() {
    if (_scannedPackages.isEmpty) return 0;
    final isPickup = _scannedPackages.first.deliveryMethod == 'pickup';
    return isPickup ? (_deliveryPendingCount ?? 0) : (_pickupPendingCount ?? 0);
  }

  String _getProgressText() {
    if (_scannedPackages.isEmpty) return '0';
    final total = _getTotalPendingForCurrentType();
    final scanned = _scannedPackages.length;
    if (total == 0) return '$scanned';
    return '$scanned/$total';
  }

  double _getProgressValue() {
    final total = _getTotalPendingForCurrentType();
    if (total == 0) return 0.0;
    final scanned = _scannedPackages.length;
    return (scanned / total).clamp(0.0, 1.0);
  }

  String _getProgressPercentageText() {
    final total = _getTotalPendingForCurrentType();
    if (total == 0) return '0% completado';
    final scanned = _scannedPackages.length;
    final percentage = ((scanned / total) * 100).toStringAsFixed(0);
    return '$percentage% completado';
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

    // Verificar si el paquete ya fue escaneado
    if (_scannedPackages.any(
      (p) => p.eboxCode == code.trim() || p.trackingNumber == code.trim(),
    )) {
      HapticFeedback.vibrate();
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.adminPackageAlreadyScanned),
            backgroundColor: Colors.orange,
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
      return;
    }

    setState(() {
      _isProcessing = true;
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

      // Validar que sea del mismo cliente y mismo tipo de entrega
      if (_scannedPackages.isNotEmpty) {
        final firstPackage = _scannedPackages.first;

        // Validar mismo cliente
        if (package.customerId != firstPackage.customerId) {
          HapticFeedback.vibrate();
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Este paquete pertenece a otro cliente (${package.clientName}). Solo puedes escanear paquetes del mismo cliente.',
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

        // Validar mismo tipo de entrega
        if (package.deliveryMethod != firstPackage.deliveryMethod) {
          HapticFeedback.vibrate();
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.adminPackageTypeMismatch(
                    package.deliveryMethod == 'pickup' ? AppLocalizations.of(context)!.adminStoreDelivery : AppLocalizations.of(context)!.adminHomeDelivery,
                    firstPackage.deliveryMethod == 'pickup' ? AppLocalizations.of(context)!.adminStoreDelivery : AppLocalizations.of(context)!.adminHomeDelivery,
                  ),
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
      }

      // Si es el primer paquete, obtener los conteos del cliente
      if (_scannedPackages.isEmpty && package.customerId != null) {
        try {
          final repository = ref.read(adminPreAlertsRepositoryProvider);
          final counts = await repository.getCustomerPendingCounts(
            package.customerId!,
          );
          setState(() {
            _pickupPendingCount = counts.pickupPending;
            _deliveryPendingCount = counts.deliveryPending;
          });
        } catch (e) {
          // Si falla, continuar sin los conteos
          print('Error al obtener conteos del cliente: $e');
        }
      }

      // Agregar el paquete a la lista
      setState(() {
        _scannedPackages.add(package);
        _isProcessing = false;
        _expandedPackageId =
            package.id; // Expandir automáticamente el nuevo paquete
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
    if (_scannedPackages.isEmpty || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final isPickup = _scannedPackages.first.deliveryMethod == 'pickup';

      if (isPickup) {
        // Procesar Pickup - mostrar modal de firma
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PickupDeliveryModal(packages: _scannedPackages),
            fullscreenDialog: true,
          ),
        );

        if (result == true && mounted) {
          final count = _scannedPackages.length;
          // Limpiar y continuar escaneando
          setState(() {
            _scannedPackages.clear();
            _isProcessing = false;
            _expandedPackageId = null;
            _pickupPendingCount = null;
            _deliveryPendingCount = null;
          });
          _manualInputController.clear();
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$count entrega(s) procesada(s) correctamente'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
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
            builder: (context) =>
                DeliveryDispatchSheet(packages: _scannedPackages),
            fullscreenDialog: true,
          ),
        );

        if (result == true && mounted) {
          final count = _scannedPackages.length;
          // Limpiar y continuar escaneando
          setState(() {
            _scannedPackages.clear();
            _isProcessing = false;
            _expandedPackageId = null;
            _pickupPendingCount = null;
            _deliveryPendingCount = null;
          });
          _manualInputController.clear();
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$count despacho(s) procesado(s) correctamente'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
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
