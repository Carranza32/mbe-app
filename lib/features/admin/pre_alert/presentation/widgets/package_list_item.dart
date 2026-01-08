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

  const PackageListItem({
    super.key,
    required this.package,
    this.onTap,
    this.context,
    this.showLocation = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hasContext = this.context != null;
    final isSelected = hasContext
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? MBETheme.brandBlack : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CHECKBOX (solo mostrar si hay contexto, no en búsqueda)
            if (hasContext)
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
            if (hasContext) const SizedBox(width: 12),

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

                  // --- BLOQUE CENTRAL: TRACKING ---
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
                            package
                                .eboxCode, // "#" ya suele venir en el tracking o se agrega
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'RobotoMono',
                              fontWeight: FontWeight.w600,
                              color: MBETheme.brandBlack.withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // --- BLOQUE DETALLE: CLIENTE Y EBOX ---
                  Row(
                    children: [
                      // Ebox (Negrita suave)
                      Icon(
                        Iconsax.box_1,
                        size: 14,
                        color: MBETheme.neutralGray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        package.trackingNumber,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: MBETheme.brandBlack,
                        ),
                      ),

                      // Separador
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "•",
                          style: TextStyle(color: MBETheme.neutralGray),
                        ),
                      ),

                      // Cliente
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

                  // --- BLOQUE INFERIOR: Depende del contexto o si se fuerza mostrar ubicación ---
                  (context == PackageContext.enBodega || showLocation)
                      ? _buildLocationInfo(theme)
                      : _buildPriceAndDate(theme, dateStr),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(ThemeData theme) {
    final rack = package.rackNumber ?? 'N/A';
    final segment = package.segmentNumber ?? 'N/A';
    final fullLocation =
        package.rackNumber != null && package.segmentNumber != null
        ? '${package.rackNumber}-${package.segmentNumber}'
        : 'Sin ubicación';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Ubicación (Izquierda)
        Row(
          children: [
            const Icon(Iconsax.location, size: 14, color: MBETheme.neutralGray),
            const SizedBox(width: 4),
            Text(
              fullLocation,
              style: theme.textTheme.bodySmall?.copyWith(
                color: MBETheme.neutralGray,
                fontSize: 11,
              ),
            ),
          ],
        ),

        // Rack y Segmento (Derecha)
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: MBETheme.brandBlack.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rack: $rack',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: MBETheme.brandBlack,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('•', style: TextStyle(color: MBETheme.neutralGray)),
                  const SizedBox(width: 8),
                  Text(
                    'Seg: $segment',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: MBETheme.brandBlack,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Botón Editar
            GestureDetector(
              onTap: () {
                if (onTap != null) onTap!();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MBETheme.lightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.edit,
                  size: 18,
                  color: MBETheme.brandBlack,
                ),
              ),
            ),
          ],
        ),
      ],
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

        // Precio y Botón Editar (Derecha)
        Row(
          children: [
            // Precio (Destacado)
            Text(
              '\$${NumberFormat('#,##0.00').format(package.total)}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: MBETheme.brandBlack,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 12),
            // Botón Editar
            GestureDetector(
              onTap: () {
                if (onTap != null) onTap!();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MBETheme.lightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.edit,
                  size: 18,
                  color: MBETheme.brandBlack,
                ),
              ),
            ),
          ],
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
