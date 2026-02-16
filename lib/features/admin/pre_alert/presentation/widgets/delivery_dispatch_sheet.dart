import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
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

class DeliveryDispatchSheet extends ConsumerStatefulWidget {
  final List<AdminPreAlert> packages;

  const DeliveryDispatchSheet({super.key, required this.packages});

  @override
  ConsumerState<DeliveryDispatchSheet> createState() =>
      _DeliveryDispatchSheetState();
}

class _DeliveryDispatchSheetState extends ConsumerState<DeliveryDispatchSheet> {
  final _formKey = GlobalKey<FormState>();
  final _trackingController = TextEditingController();
  final _manualInputController = TextEditingController();
  bool _isLoading = false;

  ShippingProviderModel? _selectedProvider;
  final Map<String, AdminPreAlert> _scannedPackages = {};
  final Map<String, bool> _expandedPackages = {};

  @override
  void initState() {
    super.initState();
    // Expandir el primer paquete por defecto
    if (widget.packages.isNotEmpty) {
      _expandedPackages[widget.packages.first.id] = true;
    }
  }

  @override
  void dispose() {
    _trackingController.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Combinar paquetes iniciales con los escaneados
    final allPackages = [
      ...widget.packages,
      ..._scannedPackages.values.where(
        (p) => !widget.packages.any((wp) => wp.id == p.id),
      ),
    ];

    final total = allPackages.fold<double>(
      0.0,
      (sum, package) => sum + package.total,
    );
    final totalWeight = allPackages.fold<double>(
      0.0,
      (sum, package) => sum + (package.totalWeight ?? 0.0),
    );
    final totalProducts = allPackages.fold<int>(
      0,
      (sum, package) => sum + package.productCount,
    );

    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: MBETheme.brandBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Despachar a Domicilio',
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
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumen general
                    if (allPackages.isNotEmpty)
                      _buildSummaryCard(total, totalWeight, totalProducts),
                    if (allPackages.isNotEmpty) const SizedBox(height: 20),

                    // Lista de paquetes
                    if (allPackages.isEmpty)
                      _buildEmptyState()
                    else ...[
                      Text(
                        'Paquetes (${allPackages.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: MBETheme.brandBlack,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...allPackages.map(
                        (package) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildPackageCard(package),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Selección de proveedor
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: MBETheme.shadowMd,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.adminShippingProvider,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: MBETheme.brandBlack,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildShippingProviderSelector(),
                          const SizedBox(height: 16),

                          // Input de tracking externo
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextFormField(
                              controller: _trackingController,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Iconsax.barcode,
                                  color: Colors.black87,
                                ),
                                labelText: 'Guía Externa (Opcional)',
                                hintText: 'Ej. C1230005',
                                labelStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Botones de acción
            Container(
              padding: const EdgeInsets.all(20),
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
                child: DSButton.primary(
                  label: _isLoading ? AppLocalizations.of(context)!.adminProcessing : AppLocalizations.of(context)!.adminConfirmDispatch,
                  fullWidth: true,
                  icon: Iconsax.box_tick,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _processDispatch,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Iconsax.scan_barcode, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.adminScanPackagesToDispatch,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    double total,
    double totalWeight,
    int totalProducts,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen General',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MBETheme.brandBlack,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  Iconsax.box_1,
                  AppLocalizations.of(context)!.adminPackages,
                  '${widget.packages.length + _scannedPackages.length}',
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  Iconsax.box,
                  AppLocalizations.of(context)!.adminProducts,
                  '$totalProducts',
                ),
              ),
            ],
          ),
          if (totalWeight > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    Iconsax.weight,
                    'Peso Total',
                    '${totalWeight.toStringAsFixed(2)} LB',
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MBETheme.brandBlack,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: MBETheme.brandBlack,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MBETheme.lightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: MBETheme.brandBlack),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: MBETheme.neutralGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: MBETheme.brandBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(AdminPreAlert package) {
    final isExpanded = _expandedPackages[package.id] ?? false;

    return Container(
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
          // Header (siempre visible)
          InkWell(
            onTap: () {
              setState(() {
                _expandedPackages[package.id] = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isExpanded
                      ? Radius.zero
                      : const Radius.circular(16),
                  bottomRight: isExpanded
                      ? Radius.zero
                      : const Radius.circular(16),
                ),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.truck,
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
                          AppLocalizations.of(context)!.adminHomeDelivery,
                          style: TextStyle(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${package.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: MBETheme.brandBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        isExpanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_2,
                        color: MBETheme.brandBlack,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Contenido expandible
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información básica
                  _buildDetailRow(Iconsax.user, AppLocalizations.of(context)!.adminClient, package.clientName),
                  const SizedBox(height: 12),
                  _buildDetailRow(Iconsax.box_1, AppLocalizations.of(context)!.adminEboxCode, package.eboxCode),
                  if (package.rackNumber != null &&
                      package.segmentNumber != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Iconsax.location,
                      'Ubicación',
                      '${package.rackNumber}-${package.segmentNumber}',
                    ),
                  ],
                  if (package.providerName != null ||
                      package.provider.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Iconsax.shop,
                      AppLocalizations.of(context)!.adminProvider,
                      package.providerName ?? package.provider,
                    ),
                  ],
                  if (package.shippingProvider != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Iconsax.truck,
                      AppLocalizations.of(context)!.adminTransport,
                      package.shippingProvider!,
                    ),
                  ],

                  // Productos
                  if (package.products != null &&
                      package.products!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Iconsax.box, size: 18, color: MBETheme.brandBlack),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.adminProducts,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: MBETheme.brandBlack,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: MBETheme.brandBlack.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${package.products!.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: MBETheme.brandBlack,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...package.products!.map((product) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: MBETheme.lightGray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Iconsax.box,
                                  size: 16,
                                  color: MBETheme.brandBlack,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    product.productCategoryName ??
                                        AppLocalizations.of(context)!.adminNoCategory,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: MBETheme.brandBlack,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (product.description != null &&
                                product.description!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                product.description!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: MBETheme.neutralGray,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildInfoChip('Cant: ${product.quantity}'),
                                if (product.weight != null)
                                  _buildInfoChip(
                                    'Peso: ${product.weight!.toStringAsFixed(2)} ${product.weightType ?? 'LB'}',
                                  ),
                                _buildInfoChip(
                                  'Precio: \$${product.price.toStringAsFixed(2)}',
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  // Resumen del paquete
                  const SizedBox(height: 20),
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
                      if (package.totalWeight != null)
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
                          'Total del Paquete',
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
        color: MBETheme.brandBlack.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: MBETheme.brandBlack,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildShippingProviderSelector() {
    final shippingProvidersState = ref.watch(shippingProvidersProvider);

    return shippingProvidersState.when(
      data: (providers) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonFormField<ShippingProviderModel>(
            value: _selectedProvider,
            icon: const Icon(Iconsax.arrow_down_1, size: 18),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,
              prefixIcon: const Icon(Iconsax.truck_fast, color: Colors.black87),
              labelText: AppLocalizations.of(context)!.adminShippingProvider,
              labelStyle: TextStyle(color: Colors.grey),
            ),
            items: providers.map((provider) {
              return DropdownMenuItem(
                value: provider,
                child: Text(
                  provider.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedProvider = val),
            validator: (val) => val == null ? AppLocalizations.of(context)!.adminRequired : null,
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Error cargando proveedores',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Future<void> _processCode(String code) async {
    if (code.trim().isEmpty) return;

    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      final package = await repository.findPackageByEbox(code.trim());

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

      // Verificar si ya está en la lista
      final isAlreadyInList =
          widget.packages.any((p) => p.id == package.id) ||
          _scannedPackages.containsKey(package.id);

      if (isAlreadyInList) {
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

      // Agregar el paquete a la lista de escaneados
      setState(() {
        _scannedPackages[package.id] = package;
        // Expandir automáticamente el paquete recién escaneado
        _expandedPackages[package.id] = true;
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
      _manualInputController.clear();
    }
  }

  Future<void> _processDispatch() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProvider == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.adminSelectProvider),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Combinar paquetes iniciales con escaneados
    final allPackages = [
      ...widget.packages,
      ..._scannedPackages.values.where(
        (p) => !widget.packages.any((wp) => wp.id == p.id),
      ),
    ];

    if (allPackages.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.adminScanAtLeastOne),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final deliveryManager = ref.read(deliveryManagerProvider.notifier);

      if (!mounted) return;

      final success = await deliveryManager.processDeliveryDispatch(
        packageIds: allPackages.map((p) => p.id).toList(),
        shippingProviderId: _selectedProvider!.id,
        providerTrackingNumber: _trackingController.text.trim().isEmpty
            ? null
            : _trackingController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ref.invalidate(adminPreAlertsProvider);
        ref.invalidate(contextCountsProvider);
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.adminDispatchSuccess),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(AppLocalizations.of(context)!.adminDispatchError);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
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
