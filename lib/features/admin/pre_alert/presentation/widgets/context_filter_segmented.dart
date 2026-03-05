import 'package:flutter/material.dart';
import '../../../../../config/theme/mbe_theme.dart';
import 'package:iconsax/iconsax.dart';

/// Filtros de contexto para la Super Lista (menú horizontal con scroll).
enum PackageContext {
  porRecibir,
  disponibles,
  solicitudEnvio, // Con sub-tabs: Domicilio | Casillero
  confirmacionesDeEnvio,
  enCamino,
  entregado,
}

/// Sub-tabs Domicilio | Casillero para solicitudEnvio, confirmacionesDeEnvio, enCamino
enum DeliveryMethodSubContext {
  domicilio, // delivery_method=delivery
  casillero, // delivery_method=locker
}

extension DeliveryMethodSubContextExtension on DeliveryMethodSubContext {
  String get label {
    switch (this) {
      case DeliveryMethodSubContext.domicilio:
        return 'Domicilio';
      case DeliveryMethodSubContext.casillero:
        return 'Casillero';
    }
  }

  String get deliveryMethod {
    switch (this) {
      case DeliveryMethodSubContext.domicilio:
        return 'delivery';
      case DeliveryMethodSubContext.casillero:
        return 'locker';
    }
  }
}

extension PackageContextExtension on PackageContext {
  String get label {
    switch (this) {
      case PackageContext.porRecibir:
        return 'Por recibir';
      case PackageContext.disponibles:
        return 'Disponibles';
      case PackageContext.solicitudEnvio:
        return 'Solicitud envío';
      case PackageContext.confirmacionesDeEnvio:
        return 'Confirmaciones de envío';
      case PackageContext.enCamino:
        return 'En camino';
      case PackageContext.entregado:
        return 'Entregado';
    }
  }

  String get shortLabel {
    switch (this) {
      case PackageContext.porRecibir:
        return 'Por recibir';
      case PackageContext.disponibles:
        return 'Disponibles';
      case PackageContext.solicitudEnvio:
        return 'Sol. envío';
      case PackageContext.confirmacionesDeEnvio:
        return 'Conf. envío';
      case PackageContext.enCamino:
        return 'En camino';
      case PackageContext.entregado:
        return 'Entregado';
    }
  }

  IconData get icon {
    switch (this) {
      case PackageContext.porRecibir:
        return Iconsax.box_tick;
      case PackageContext.disponibles:
        return Iconsax.box;
      case PackageContext.solicitudEnvio:
        return Iconsax.document_text;
      case PackageContext.confirmacionesDeEnvio:
        return Iconsax.truck_fast;
      case PackageContext.enCamino:
        return Iconsax.truck;
      case PackageContext.entregado:
        return Iconsax.tick_circle;
    }
  }

  String get statusFilter {
    switch (this) {
      case PackageContext.porRecibir:
        return 'lista_para_recepcionar';
      case PackageContext.disponibles:
        return 'disponible_para_retiro';
      case PackageContext.solicitudEnvio:
        return 'solicitud_recoleccion';
      case PackageContext.confirmacionesDeEnvio:
        return 'confirmada_recoleccion';
      case PackageContext.enCamino:
        return 'en_ruta';
      case PackageContext.entregado:
        return 'entregado';
    }
  }

  /// delivery_method solo para solicitudEnvio (se usa con solicitudEnvioSub)
  String? get deliveryMethodFilter => null;
}

class ContextFilterSegmented extends StatelessWidget {
  final PackageContext selectedContext;
  final Function(PackageContext) onContextChanged;
  final Map<PackageContext, int>? counts;

  /// Sub-pills Domicilio | Casillero para solicitudEnvio, confirmacionesDeEnvio, enCamino
  final DeliveryMethodSubContext? selectedSubContext;
  final Function(DeliveryMethodSubContext)? onSubContextChanged;
  final Map<DeliveryMethodSubContext, int>? subCounts;

  const ContextFilterSegmented({
    super.key,
    required this.selectedContext,
    required this.onContextChanged,
    this.counts,
    this.selectedSubContext,
    this.onSubContextChanged,
    this.subCounts,
  });

  /// True si el contexto actual tiene sub-pills
  static bool hasSubPills(PackageContext context) {
    return context == PackageContext.solicitudEnvio ||
        context == PackageContext.confirmacionesDeEnvio ||
        context == PackageContext.enCamino;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Menú principal horizontal con scroll
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: PackageContext.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final ctx = PackageContext.values[index];
                final isSelected = selectedContext == ctx;
                final count = counts?[ctx] ?? 0;
                return _ContextPill(
                  packageContext: ctx,
                  isSelected: isSelected,
                  count: count,
                  onTap: () => onContextChanged(ctx),
                );
              },
            ),
          ),
          // Sub-pills Domicilio | Casillero para solicitudEnvio, confirmacionesDeEnvio, enCamino
          if (ContextFilterSegmented.hasSubPills(selectedContext) &&
              onSubContextChanged != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _SubPill(
                      label: DeliveryMethodSubContext.domicilio.label,
                      isSelected:
                          selectedSubContext ==
                          DeliveryMethodSubContext.domicilio,
                      count: subCounts?[DeliveryMethodSubContext.domicilio] ?? 0,
                      onTap: () =>
                          onSubContextChanged!(DeliveryMethodSubContext
                              .domicilio),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SubPill(
                      label: DeliveryMethodSubContext.casillero.label,
                      isSelected:
                          selectedSubContext ==
                          DeliveryMethodSubContext.casillero,
                      count: subCounts?[DeliveryMethodSubContext.casillero] ?? 0,
                      onTap: () =>
                          onSubContextChanged!(DeliveryMethodSubContext
                              .casillero),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContextPill extends StatelessWidget {
  final PackageContext packageContext;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;

  const _ContextPill({
    required this.packageContext,
    required this.isSelected,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minWidth: 95, maxWidth: 130),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? MBETheme.brandBlack : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? MBETheme.brandBlack : Colors.grey.shade400,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: MBETheme.brandBlack.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              packageContext.icon,
              size: 18,
              color: isSelected ? Colors.white : MBETheme.brandBlack,
            ),
            const SizedBox(height: 2),
            Text(
              packageContext.shortLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : MBETheme.brandBlack,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : MBETheme.brandBlack.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : MBETheme.brandBlack,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;

  const _SubPill({
    required this.label,
    required this.isSelected,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? MBETheme.brandBlack : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? MBETheme.brandBlack : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : MBETheme.brandBlack,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : MBETheme.brandBlack.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : MBETheme.brandBlack,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
