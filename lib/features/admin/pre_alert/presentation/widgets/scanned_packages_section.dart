import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../data/models/admin_pre_alert_model.dart';
import 'package_list_item.dart';

/// Sección reutilizable de paquetes escaneados con cabecera (contador + Limpiar todo),
/// lista con [PackageListItem] y Dismissible, y barra de progreso opcional.
/// Si [expandedPackageId] y [onExpandedChanged] se proveen, las tarjetas son colapsables:
/// solo la tarjeta con ese id se muestra expandida, el resto colapsadas.
class ScannedPackagesSection extends StatelessWidget {
  final List<AdminPreAlert> packages;
  final VoidCallback onClear;
  final void Function(AdminPreAlert package) onRemovePackage;

  /// Si se provee, se muestra barra de progreso "escaneados / total".
  final int? totalCount;

  /// Mensaje cuando la lista está vacía.
  final String emptyMessage;

  /// Si mostrar ubicación (rack/segmento) en [PackageListItem].
  final bool showLocation;

  /// Margen exterior del contenedor.
  final EdgeInsetsGeometry? margin;

  /// Padding interno del contenedor de la lista (no del header).
  final EdgeInsetsGeometry? listPadding;

  /// ID del paquete actualmente expandido (solo uno). Si null, todas se muestran expandidas.
  final String? expandedPackageId;

  /// Se llama al tocar una tarjeta para expandir/contraer. (id) expande ese paquete, (null) contrae.
  final void Function(String? packageId)? onExpandedChanged;

  const ScannedPackagesSection({
    super.key,
    required this.packages,
    required this.onClear,
    required this.onRemovePackage,
    this.totalCount,
    this.emptyMessage = 'Escanea un código para comenzar',
    this.showLocation = true,
    this.margin,
    this.listPadding,
    this.expandedPackageId,
    this.onExpandedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      packages.isEmpty
                          ? 'Paquetes escaneados'
                          : '${packages.length} paquete(s) escaneado(s)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: MBETheme.brandBlack,
                      ),
                    ),
                    if (packages.isNotEmpty)
                      TextButton(
                        onPressed: onClear,
                        child: const Text(
                          'Limpiar todo',
                          style: TextStyle(
                            color: MBETheme.brandRed,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                if (totalCount != null && totalCount! > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (packages.length / totalCount!).clamp(
                              0.0,
                              1.0,
                            ),
                            backgroundColor: MBETheme.lightGray,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              MBETheme.brandRed,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${packages.length} / $totalCount',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: MBETheme.neutralGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (packages.isEmpty)
            SizedBox(
              height: 150,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.scan_barcode,
                      size: 48,
                      color: Colors.grey.withOpacity(0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      emptyMessage,
                      style: TextStyle(
                        color: Colors.grey.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: listPadding ?? const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: packages.length,
                itemBuilder: (context, index) {
                  final package = packages[index];
                  final isExpanded =
                      expandedPackageId == null ||
                      expandedPackageId == package.id;

                  Widget cardChild;
                  if (onExpandedChanged != null) {
                    // Modo colapsable con ExpansionTile (igual que recepción)
                    cardChild = _ExpandablePackageCard(
                      package: package,
                      isExpanded: isExpanded,
                      expandedPackageId: expandedPackageId,
                      showLocation: showLocation,
                      onExpandedChanged: (expanded) {
                        if (expanded) {
                          onExpandedChanged!(package.id);
                        } else if (expandedPackageId == package.id) {
                          onExpandedChanged!(null);
                        }
                      },
                    );
                  } else {
                    cardChild = PackageListItem(
                      package: package,
                      showLocation: showLocation,
                      onTap: () {},
                    );
                  }

                  return Dismissible(
                    key: Key(package.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      onRemovePackage(package);
                      HapticFeedback.mediumImpact();
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.redAccent.withOpacity(0.1),
                      child: const Icon(Icons.delete, color: Colors.redAccent),
                    ),
                    child: cardChild,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Tarjeta expandible con ExpansionTile (mismo comportamiento que recepción/Listos para procesar).
class _ExpandablePackageCard extends StatelessWidget {
  final AdminPreAlert package;
  final bool isExpanded;
  final String? expandedPackageId;
  final bool showLocation;
  final void Function(bool expanded) onExpandedChanged;

  const _ExpandablePackageCard({
    required this.package,
    required this.isExpanded,
    required this.expandedPackageId,
    required this.showLocation,
    required this.onExpandedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ExpansionTile(
        key: ValueKey('expansion_${package.id}_$expandedPackageId'),
        initiallyExpanded: isExpanded,
        onExpansionChanged: onExpandedChanged,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          child: Icon(Iconsax.box_1, size: 20, color: MBETheme.brandRed),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              (package.providerName ?? package.provider).toUpperCase(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '#${package.trackingNumber}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if ((package.lockerCode?.trim().isNotEmpty ?? false) ||
                package.clientName.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                (package.lockerCode?.trim().isNotEmpty ?? false)
                    ? package.lockerCode!
                    : package.clientName,
                style: TextStyle(fontSize: 12, color: MBETheme.neutralGray),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: MBETheme.brandRed.withOpacity(0.8),
              size: 20,
            ),
            const SizedBox(width: 8),
            Icon(
              isExpanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_2,
              color: MBETheme.brandRed,
              size: 18,
            ),
          ],
        ),
        children: [
          PackageListItem(
            package: package,
            showLocation: showLocation,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
