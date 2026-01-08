import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../core/design_system/ds_buttons.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../data/models/admin_pre_alert_model.dart';
import '../../providers/delivery_manager.dart';
import 'signature_capture_widget.dart';
import 'recipient_selector.dart';

class PickupDeliveryModal extends ConsumerStatefulWidget {
  final List<AdminPreAlert> packages;

  const PickupDeliveryModal({super.key, required this.packages});

  @override
  ConsumerState<PickupDeliveryModal> createState() =>
      _PickupDeliveryModalState();
}

class _PickupDeliveryModalState extends ConsumerState<PickupDeliveryModal> {
  final GlobalKey<SignatureCaptureWidgetState> _signatureKey =
      GlobalKey<SignatureCaptureWidgetState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  RecipientType? _recipientType;
  String? _recipientName;
  bool _isLoading = false;
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
  Widget build(BuildContext context) {
    final total = widget.packages.fold<double>(
      0.0,
      (sum, package) => sum + package.total,
    );
    final totalWeight = widget.packages.fold<double>(
      0.0,
      (sum, package) => sum + (package.totalWeight ?? 0.0),
    );
    final totalProducts = widget.packages.fold<int>(
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
          'Procesar Entrega',
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
                    _buildSummaryCard(total, totalWeight, totalProducts),
                    const SizedBox(height: 20),

                    // Lista de paquetes con detalles
                    Text(
                      'Paquetes (${widget.packages.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MBETheme.brandBlack,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.packages.map(
                      (package) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPackageCard(package),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Selector de receptor
                    RecipientSelector(
                      onRecipientChanged: (type, name) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _recipientType = type;
                              _recipientName = name;
                            });
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Captura de firma
                    SignatureCaptureWidget(key: _signatureKey),
                    const SizedBox(height: 20),
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
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DSButton.primary(
                        label: _isLoading
                            ? 'Procesando...'
                            : 'Confirmar Entrega',
                        fullWidth: true,
                        onPressed: _isLoading ? null : _processDelivery,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
                  'Paquetes',
                  '${widget.packages.length}',
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  Iconsax.box,
                  'Productos',
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
    final isPickup = package.deliveryMethod == 'pickup';

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
                color: (isPickup ? Colors.blue : Colors.green).withOpacity(0.1),
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
                  color: (isPickup ? Colors.blue : Colors.green).withOpacity(
                    0.3,
                  ),
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
                  _buildDetailRow(Iconsax.user, 'Cliente', package.clientName),
                  const SizedBox(height: 12),
                  _buildDetailRow(Iconsax.box_1, 'Ebox Code', package.eboxCode),
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
                      'Proveedor',
                      package.providerName ?? package.provider,
                    ),
                  ],
                  if (package.shippingProvider != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Iconsax.truck,
                      'Transporte',
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
                        const Text(
                          'Productos',
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
                                        'Sin categoría',
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

  Future<void> _processDelivery() async {
    // Validar firma
    final signatureState = _signatureKey.currentState;
    if (signatureState == null || !signatureState.hasSignature) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes capturar la firma del cliente'),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }

    // Validar receptor
    if (_recipientType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar quién recibe el paquete'),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }

    if (_recipientType == RecipientType.encargado &&
        (_recipientName == null || _recipientName!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes ingresar el nombre del encargado'),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Capturar firma
      final signature = await signatureState.captureSignature();
      if (signature == null) {
        throw Exception('Error al capturar la firma');
      }

      // Determinar quién recibe
      final deliveredTo = _recipientType == RecipientType.titular
          ? 'titular'
          : _recipientName!;

      // Procesar entrega
      final deliveryManager = ref.read(deliveryManagerProvider.notifier);
      final success = await deliveryManager.processPickupDelivery(
        packageIds: widget.packages.map((p) => p.id).toList(),
        signaturePath: signature,
        deliveredTo: deliveredTo,
        deliveredAt: DateTime.now(),
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${widget.packages.length} paquete(s) entregado(s) exitosamente',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al procesar la entrega'),
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
