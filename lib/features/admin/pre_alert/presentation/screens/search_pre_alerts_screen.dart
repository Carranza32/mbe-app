import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../../../../core/design_system/ds_buttons.dart';
import '../../data/models/admin_pre_alert_model.dart';
import '../../data/models/delivery_search_response.dart';
import '../../providers/delivery_search_provider.dart';
import '../widgets/pickup_delivery_modal.dart';
import '../widgets/delivery_dispatch_sheet.dart';
import '../widgets/package_list_item.dart';

class SearchPreAlertsScreen extends ConsumerStatefulWidget {
  const SearchPreAlertsScreen({super.key});

  @override
  ConsumerState<SearchPreAlertsScreen> createState() =>
      _SearchPreAlertsScreenState();
}

class _SearchPreAlertsScreenState extends ConsumerState<SearchPreAlertsScreen> {
  MobileScannerController? _scannerController;
  final TextEditingController _lockerInputController = TextEditingController();
  final TextEditingController _packageInputController = TextEditingController();
  bool _isFlashOn = false;
  bool _isSearchingCustomer = false;
  bool _isProcessingPackage = false;
  final List<AdminPreAlert> _scannedPackages = [];
  DeliverySearchResponse? _lastSearchResult;
  String? _lastScannedCode;
  DateTime? _lastScannedAt;

  List<AdminPreAlert> get _deliverablePackages =>
      _lastSearchResult?.deliverablePackages ?? [];

  bool get _hasCustomer =>
      _lastSearchResult != null && _lastSearchResult!.type == 'customer';

  @override
  void initState() {
    super.initState();
    _initScanner();
  }

  void _initScanner() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _lockerInputController.dispose();
    _packageInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Entregar Paquetes',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: MBETheme.brandBlack,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildLockerSearch()),
              if (_hasCustomer) ...[
                SliverToBoxAdapter(child: _buildCustomerCard()),
                SliverToBoxAdapter(child: _buildCamera()),
                if (_deliverablePackages.isNotEmpty) ...[
                  SliverToBoxAdapter(child: _buildProgressCard()),
                  SliverToBoxAdapter(child: _buildDeliverableList()),
                ],
              ] else
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          if (_scannedPackages.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildProcessButton(),
            ),
        ],
      ),
    );
  }

  // ─── Locker search ────────────────────────────────────────────────────────────

  Widget _buildLockerSearch() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBERadius.large),
        boxShadow: MBETheme.shadowMd,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _lockerInputController,
              decoration: InputDecoration(
                hintText: 'Código de casillero (ej. SAL0101)',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                prefixIcon: const Icon(
                  Iconsax.user_search,
                  color: MBETheme.brandBlack,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 14,
                ),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) _searchByLocker(v.trim());
              },
            ),
          ),
          GestureDetector(
            onTap: _isSearchingCustomer
                ? null
                : () {
                    final text = _lockerInputController.text.trim();
                    if (text.isNotEmpty) _searchByLocker(text);
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: _isSearchingCustomer
                    ? Colors.grey[300]
                    : MBETheme.brandBlack,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isSearchingCustomer
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Iconsax.search_normal_1,
                      color: Colors.white,
                      size: 18,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Customer card ────────────────────────────────────────────────────────────

  Widget _buildCustomerCard() {
    final customer = _lastSearchResult!.customer;
    final totals = _lastSearchResult!.totalsByStatus;

    final pills = <_StatusPillData>[
      if ((totals['entregado'] ?? 0) > 0)
        _StatusPillData(
          'Entregado',
          totals['entregado']!,
          const Color(0xFF10B981),
        ),
      if ((totals['disponible_para_retiro'] ?? 0) > 0)
        _StatusPillData(
          'Disponible',
          totals['disponible_para_retiro']!,
          const Color(0xFFF59E0B),
        ),
      if ((totals['en_ruta'] ?? 0) > 0)
        _StatusPillData('En Ruta', totals['en_ruta']!, const Color(0xFF6366F1)),
      if ((totals['solicitud_recoleccion'] ?? 0) > 0)
        _StatusPillData(
          'Sol. Retiro',
          totals['solicitud_recoleccion']!,
          const Color(0xFF3B82F6),
        ),
      if ((totals['confirmada_recoleccion'] ?? 0) > 0)
        _StatusPillData(
          'Conf. Recolección',
          totals['confirmada_recoleccion']!,
          const Color(0xFF8B5CF6),
        ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBERadius.large),
        boxShadow: MBETheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: MBETheme.brandBlack,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(
                      customer.name.isNotEmpty
                          ? customer.name[0].toUpperCase()
                          : 'C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: MBETheme.brandBlack,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Iconsax.box,
                            size: 12,
                            color: MBETheme.neutralGray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            customer.code,
                            style: TextStyle(
                              fontSize: 12,
                              color: MBETheme.neutralGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    _lastSearchResult = null;
                    _scannedPackages.clear();
                    _lockerInputController.clear();
                    _packageInputController.clear();
                  }),
                  child: Text(
                    'Cambiar',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: MBETheme.brandRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (pills.isNotEmpty) ...[
            Divider(height: 1, color: Colors.grey[100]),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: pills
                    .map(
                      (p) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: p.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: p.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${p.label}: ${p.count}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: p.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Lista de paquetes a entregar (tarjetas completas) ────────────────────────

  Widget _buildDeliverableList() {
    final total = _deliverablePackages.length;
    if (total == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Iconsax.box_tick, size: 18, color: MBETheme.brandBlack),
                const SizedBox(width: 8),
                Text(
                  'Paquetes a entregar ($total)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: MBETheme.brandBlack,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Escanea cada paquete para seleccionarlo',
            style: TextStyle(fontSize: 12, color: MBETheme.neutralGray),
          ),
          const SizedBox(height: 12),
          ..._deliverablePackages.map((pkg) {
            final isScanned = _scannedPackages.any(
              (s) =>
                  s.id == pkg.id ||
                  s.eboxCode == pkg.eboxCode ||
                  s.trackingNumber == pkg.trackingNumber,
            );
            return PackageListItem(
              package: pkg,
              showLocation: true,
              showSelectionCheckbox: false,
              isSelectedOverride: isScanned,
              selectedBorderColor: MBETheme.brandRed,
            );
          }),
        ],
      ),
    );
  }

  // ─── Camera ───────────────────────────────────────────────────────────────────

  Widget _buildCamera() {
    return Container(
      height: 180,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBERadius.xxl),
        boxShadow: MBETheme.shadowMd,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MBERadius.xxl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_scannerController != null)
              MobileScanner(
                controller: _scannerController!,
                onDetect: _handleScanDetection,
              ),
            Container(color: Colors.black.withOpacity(0.06)),
            Center(
              child: Container(
                width: 200,
                height: 90,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.85),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.scan,
                      color: Colors.white.withOpacity(0.9),
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Escanea el paquete',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  _scannerController?.toggleTorch();
                  setState(() => _isFlashOn = !_isFlashOn);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.42),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Icon(
                    _isFlashOn ? Iconsax.flash_1 : Iconsax.flash_slash,
                    color: _isFlashOn ? Colors.yellow : Colors.white,
                    size: 17,
                  ),
                ),
              ),
            ),
            if (_isProcessingPackage)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Manual package input ─────────────────────────────────────────────────────

  Widget _buildManualPackageInput() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBERadius.large),
        boxShadow: MBETheme.shadowMd,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _packageInputController,
              decoration: InputDecoration(
                hintText: 'O escribe el código del paquete',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                prefixIcon: const Icon(
                  Iconsax.barcode,
                  color: MBETheme.brandBlack,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 14,
                ),
              ),
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) _processPackageCode(v.trim());
              },
            ),
          ),
          GestureDetector(
            onTap: _isProcessingPackage
                ? null
                : () {
                    final text = _packageInputController.text.trim();
                    if (text.isNotEmpty) _processPackageCode(text);
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: _isProcessingPackage
                    ? Colors.grey[300]
                    : MBETheme.brandBlack,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isProcessingPackage
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Iconsax.send_1, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Progress card (siempre visible cuando hay paquetes a entregar) ────────────

  Widget _buildProgressCard() {
    final total = _deliverablePackages.length;
    final scanned = _scannedPackages.length;
    final progress = total > 0 ? scanned / total : 1.0;
    final percent = (progress * 100).round();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBERadius.large),
        boxShadow: MBETheme.shadowSm,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso de entrega',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: MBETheme.neutralGray,
                ),
              ),
              Row(
                children: [
                  Text(
                    '$scanned / $total',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: MBETheme.brandBlack,
                    ),
                  ),
                  if (scanned > 0) ...[
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => setState(() => _scannedPackages.clear()),
                      child: Text(
                        'Limpiar',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: MBETheme.brandRed,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.grey[100],
              valueColor: const AlwaysStoppedAnimation<Color>(
                MBETheme.brandRed,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$percent% completado',
              style: TextStyle(fontSize: 11, color: MBETheme.neutralGray),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Empty state ──────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(Iconsax.user_search, size: 38, color: Colors.grey[350]),
          ),
          const SizedBox(height: 20),
          Text(
            'Busca un cliente por casillero',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: MBETheme.neutralGray,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ingresa el código de casillero (ej. SAL0101)\npara ver los paquetes disponibles',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // ─── Process button ───────────────────────────────────────────────────────────

  Widget _buildProcessButton() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: DSButton.primary(
          label: 'Procesar entrega (${_scannedPackages.length})',
          icon: Iconsax.box_tick,
          fullWidth: true,
          onPressed: _processScannedDelivery,
        ),
      ),
    );
  }

  // ─── Logic ────────────────────────────────────────────────────────────────────

  Future<void> _searchByLocker(String code) async {
    if (code.trim().isEmpty || _isSearchingCustomer) return;
    setState(() => _isSearchingCustomer = true);

    try {
      final result = await ref
          .read(deliverySearchProvider.notifier)
          .searchCustomer(code.trim());
      if (!mounted) return;

      if (result == null || result.type != 'customer') {
        HapticFeedback.vibrate();
        _showSnackbar('Cliente no encontrado: $code', Colors.redAccent);
        return;
      }

      if (result.deliverablePackages.isEmpty) {
        HapticFeedback.vibrate();
        _showSnackbar('No hay paquetes listos para entregar', Colors.orange);
      }

      setState(() {
        _lastSearchResult = result;
        _scannedPackages.clear();
        _isSearchingCustomer = false;
      });
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.vibrate();
      final msg = e.toString().contains('disposed')
          ? 'Error de conexión. Intenta de nuevo.'
          : 'Error: ${e.toString()}';
      _showSnackbar(msg, Colors.redAccent);
      setState(() => _isSearchingCustomer = false);
    }
  }

  void _handleScanDetection(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue == null) continue;
      final code = barcode.rawValue!.trim();
      if (code.isEmpty) continue;
      if (!_hasCustomer) return;
      if (_isProcessingPackage) return;
      final now = DateTime.now();
      if (_lastScannedCode == code &&
          _lastScannedAt != null &&
          now.difference(_lastScannedAt!).inMilliseconds < 2000) {
        return;
      }
      _lastScannedCode = code;
      _lastScannedAt = now;
      _processPackageCode(code);
      break;
    }
  }

  Future<void> _processPackageCode(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty || _isProcessingPackage || !_hasCustomer) return;

    if (_scannedPackages.any(
      (p) => p.eboxCode == trimmed || p.trackingNumber == trimmed,
    )) {
      HapticFeedback.vibrate();
      _showSnackbar('Este paquete ya fue escaneado', Colors.orange);
      _packageInputController.clear();
      return;
    }

    final matches = _deliverablePackages
        .where((p) => p.eboxCode == trimmed || p.trackingNumber == trimmed)
        .toList();
    final match = matches.isEmpty ? null : matches.first;

    if (match == null) {
      HapticFeedback.vibrate();
      _showSnackbar(
        'El paquete no está en la lista de este cliente',
        Colors.orange,
      );
      _packageInputController.clear();
      return;
    }

    setState(() {
      _scannedPackages.add(match);
      _isProcessingPackage = false;
    });
    _packageInputController.clear();
    HapticFeedback.mediumImpact();
  }

  Future<void> _processScannedDelivery() async {
    if (_scannedPackages.isEmpty) return;

    final pickupPackages = _scannedPackages
        .where((p) => p.deliveryMethod == 'pickup' || p.deliveryMethod == null)
        .toList();
    final deliveryPackages = _scannedPackages
        .where((p) => p.deliveryMethod == 'delivery')
        .toList();

    if (deliveryPackages.isNotEmpty && pickupPackages.isEmpty) {
      _showDeliveryDispatchSheet(deliveryPackages);
    } else if (pickupPackages.isNotEmpty && deliveryPackages.isEmpty) {
      _showPickupModal(pickupPackages);
    } else {
      _showDeliveryTypeSelector(pickupPackages, deliveryPackages);
    }
  }

  void _showPickupModal(List<AdminPreAlert> packages) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PickupDeliveryModal(packages: packages),
        fullscreenDialog: true,
      ),
    ).then((result) {
      if (result == true) _onDeliveryComplete();
    });
  }

  void _showDeliveryDispatchSheet(List<AdminPreAlert> packages) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DeliveryDispatchSheet(packages: packages),
        fullscreenDialog: true,
      ),
    ).then((result) {
      if (result == true) _onDeliveryComplete();
    });
  }

  void _showDeliveryTypeSelector(
    List<AdminPreAlert> pickupPackages,
    List<AdminPreAlert> deliveryPackages,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Tipo de entrega',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                '${pickupPackages.length} pickup · ${deliveryPackages.length} delivery',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showPickupModal(pickupPackages);
                      },
                      icon: const Icon(Iconsax.shop, size: 18),
                      label: Text('Pickup (${pickupPackages.length})'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showDeliveryDispatchSheet(deliveryPackages);
                      },
                      icon: const Icon(Iconsax.truck, size: 18),
                      label: Text('Delivery (${deliveryPackages.length})'),
                      style: FilledButton.styleFrom(
                        backgroundColor: MBETheme.brandBlack,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onDeliveryComplete() {
    setState(() {
      _scannedPackages.clear();
    });
    _showSnackbar('Entrega procesada correctamente', Colors.green);
  }

  void _showSnackbar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _StatusPillData {
  final String label;
  final int count;
  final Color color;
  const _StatusPillData(this.label, this.count, this.color);
}
