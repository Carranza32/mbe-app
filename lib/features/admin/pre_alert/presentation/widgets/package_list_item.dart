import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../core/design_system/ds_badges.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../data/models/admin_pre_alert_model.dart';
import '../../data/models/package_status.dart';
import '../../providers/package_selection_provider.dart';
import '../widgets/context_filter_segmented.dart';

class PackageListItem extends ConsumerWidget {
  final AdminPreAlert package;
  final VoidCallback? onTap;
  final PackageContext? context;
  final bool showLocation; // Forzar mostrar ubicación
  /// Si false, no se muestra checkbox ni estado de selección (p. ej. en listas Por Recibir / Para Entregar).
  final bool showSelectionCheckbox;

  const PackageListItem({
    super.key,
    required this.package,
    this.onTap,
    this.context,
    this.showLocation = false,
    this.showSelectionCheckbox = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hasContext = this.context != null;
    final showCheckbox = hasContext && showSelectionCheckbox;
    final isSelected = showCheckbox
        ? ref.watch(
            packageSelectionProvider.select(
              (state) => state.contains(package.id),
            ),
          )
        : false;
    final selectionNotifier = ref.read(packageSelectionProvider.notifier);

    // Formateador de fecha (Asumiendo que tienes un campo date o createdAt)
    // Si tu modelo no tiene fecha, usa DateTime.now() como placeholder o agrégalo al modelo.
    final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (showCheckbox && isSelected) ? MBETheme.brandBlack : Colors.transparent,
            width: (showCheckbox && isSelected) ? 2 : 1,
          ),
          boxShadow: MBETheme.shadowMd,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CHECKBOX (solo si showSelectionCheckbox está activo; no en listas Por Recibir / Para Entregar)
            if (showCheckbox)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) =>
                        selectionNotifier.toggleSelection(package.id),
                    activeColor: MBETheme.brandBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    side: const BorderSide(
                      color: Color(0xFFE0E0E0),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            if (showCheckbox) const SizedBox(width: 12),

            // 2. INFORMACIÓN DEL PAQUETE
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BLOQUE SUPERIOR: PROVEEDOR Y ESTADO ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          (package.providerName ?? package.provider)
                              .toUpperCase(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: MBETheme.brandBlack,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Badge compacto alineado a la derecha
                      FittedBox(child: _StatusBadge(status: package.status)),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // --- BLOQUE CENTRAL: TRACKING (sombreado, icono escanear) → track_number ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: MBETheme.lightGray,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Iconsax.barcode,
                          size: 14,
                          color: MBETheme.neutralGray,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            package.trackingNumber,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'RobotoMono',
                              fontWeight: FontWeight.bold,
                              color: MBETheme.brandBlack,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // --- BLOQUE DETALLE: PACKAGE_CODE (icono box) y CLIENTE ---
                  Row(
                    children: [
                      Icon(
                        Iconsax.box_1,
                        size: 14,
                        color: MBETheme.neutralGray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        package.eboxCode,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: MBETheme.brandBlack,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "•",
                          style: TextStyle(color: MBETheme.neutralGray),
                        ),
                      ),
                      const Icon(
                        Iconsax.user,
                        size: 14,
                        color: MBETheme.neutralGray,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          package.clientName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: MBETheme.neutralGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 10),

                  // --- BLOQUE INFERIOR: Precio y fecha, y si está en bodega, mostrar rack y segmento ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPriceAndDate(theme, dateStr),
                      // Si está en bodega, mostrar rack y segmento debajo de la fecha
                      if (this.context == PackageContext.enBodega || showLocation) ...[
                        const SizedBox(height: 8),
                        _buildRackSegmentInfo(theme),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceAndDate(ThemeData theme, String dateStr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Fecha (Izquierda)
        Row(
          children: [
            const Icon(
              Iconsax.calendar_1,
              size: 14,
              color: MBETheme.neutralGray,
            ),
            const SizedBox(width: 4),
            Text(
              dateStr,
              style: theme.textTheme.bodySmall?.copyWith(
                color: MBETheme.neutralGray,
                fontSize: 11,
              ),
            ),
          ],
        ),

        // Precio (Negrita y alineado a la derecha)
        Text(
          '\$${NumberFormat('#,##0.00').format(package.total)}',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: MBETheme.brandBlack,
            fontSize: 18,
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  Widget _buildRackSegmentInfo(ThemeData theme) {
    final rack = package.rackNumber ?? 'N/A';
    final segment = package.segmentNumber ?? 'N/A';
    final hasLocation = package.rackNumber != null && 
                        package.rackNumber!.isNotEmpty &&
                        package.segmentNumber != null && 
                        package.segmentNumber!.isNotEmpty;

    return Row(
      children: [
        Icon(
          Iconsax.location,
          size: 14,
          color: hasLocation ? MBETheme.brandRed : MBETheme.neutralGray,
        ),
        const SizedBox(width: 6),
        Text(
          'Rack: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: MBETheme.neutralGray,
            fontSize: 12,
          ),
        ),
        Text(
          rack,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: hasLocation ? MBETheme.brandBlack : MBETheme.neutralGray,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '•',
          style: TextStyle(color: MBETheme.neutralGray),
        ),
        const SizedBox(width: 12),
        Text(
          'Segmento: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: MBETheme.neutralGray,
            fontSize: 12,
          ),
        ),
        Text(
          segment,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: hasLocation ? MBETheme.brandBlack : MBETheme.neutralGray,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PackageStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    // Mapeo de estados a badges según el color del backend
    switch (status) {
      // Estados que requieren acción (warning/info)
      case PackageStatus.ingresada:
        return DSBadge.info(label: status.label);
      case PackageStatus.listaParaRecibir:
        return DSBadge.custom(label: status.label, color: MBETheme.brandBlack);
      case PackageStatus.enTienda:
        return DSBadge.warning(label: status.label);
      case PackageStatus.solicitudRecoleccion:
        return DSBadge.info(label: status.label);
      case PackageStatus.confirmadaRecoleccion:
        return DSBadge.success(label: status.label);
      case PackageStatus.enRuta:
        return DSBadge.warning(label: status.label);
      case PackageStatus.entregada:
        return DSBadge.success(label: status.label);
      case PackageStatus.retornada:
        return DSBadge.error(label: status.label);
      case PackageStatus.listaRetiro:
        return DSBadge.info(label: status.label);
      case PackageStatus.completada:
        return DSBadge.success(label: status.label);
      case PackageStatus.cancelada:
        return DSBadge.error(label: status.label);
    }
  }
}
