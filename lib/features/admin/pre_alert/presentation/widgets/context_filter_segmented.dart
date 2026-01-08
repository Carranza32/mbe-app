import 'package:flutter/material.dart';
import '../../../../../config/theme/mbe_theme.dart';
import 'package:iconsax/iconsax.dart';

/// Filtros de contexto principales para la Super Lista
enum PackageContext {
  porRecibir, // Pre-alertados / En Tránsito
  enBodega, // Recibidos / En Tienda
  paraEntregar, // Listos para retiro
}

extension PackageContextExtension on PackageContext {
  String get label {
    switch (this) {
      case PackageContext.porRecibir:
        return 'Por Recibir';
      case PackageContext.enBodega:
        return 'En Bodega';
      case PackageContext.paraEntregar:
        return 'Para Entregar';
    }
  }

  IconData get icon {
    switch (this) {
      case PackageContext.porRecibir:
        return Iconsax.box_tick;
      case PackageContext.enBodega:
        return Iconsax.box;
      case PackageContext.paraEntregar:
        return Iconsax.truck_fast;
    }
  }

  String get description {
    switch (this) {
      case PackageContext.porRecibir:
        return 'Paquetes por recibir';
      case PackageContext.enBodega:
        return 'Recibidos / En tienda';
      case PackageContext.paraEntregar:
        return 'Listos para retiro';
    }
  }
}

class ContextFilterSegmented extends StatelessWidget {
  final PackageContext selectedContext;
  final Function(PackageContext) onContextChanged;
  final Map<PackageContext, int>? counts;

  const ContextFilterSegmented({
    super.key,
    required this.selectedContext,
    required this.onContextChanged,
    this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Segmented Control
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Asegura alineación superior
            children: [
              Expanded(
                child: _ContextButton(
                  context: PackageContext.porRecibir,
                  isSelected: selectedContext == PackageContext.porRecibir,
                  count: counts?[PackageContext.porRecibir],
                  onTap: () => onContextChanged(PackageContext.porRecibir),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ContextButton(
                  context: PackageContext.enBodega,
                  isSelected: selectedContext == PackageContext.enBodega,
                  count: counts?[PackageContext.enBodega],
                  onTap: () => onContextChanged(PackageContext.enBodega),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ContextButton(
                  context: PackageContext.paraEntregar,
                  isSelected: selectedContext == PackageContext.paraEntregar,
                  count: counts?[PackageContext.paraEntregar],
                  onTap: () => onContextChanged(PackageContext.paraEntregar),
                ),
              ),
            ],
          ),

          // Descripción y contador inferior
          if (counts != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  selectedContext.icon,
                  size: 16,
                  color: MBETheme.neutralGray,
                ),
                const SizedBox(width: 8),
                Text(
                  selectedContext.description,
                  style: TextStyle(color: MBETheme.neutralGray, fontSize: 13),
                ),
                const Spacer(),
                // Aquí también forzamos a mostrar 0 si es nulo para consistencia
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: MBETheme.brandBlack.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${counts![selectedContext] ?? 0}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ContextButton extends StatelessWidget {
  final PackageContext context;
  final bool isSelected;
  final int? count;
  final VoidCallback onTap;

  const _ContextButton({
    required this.context,
    required this.isSelected,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos 0 si el count es nulo
    final displayCount = count ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? MBETheme.brandBlack : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? MBETheme.brandBlack
                : MBETheme.neutralGray.withOpacity(0.3),
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
          children: [
            Icon(
              this.context.icon,
              size: 20,
              color: isSelected ? Colors.white : MBETheme.brandBlack,
            ),
            const SizedBox(height: 4),
            Text(
              this.context.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : MBETheme.brandBlack,
              ),
              textAlign: TextAlign.center,
              maxLines: 1, // Evita saltos de línea inesperados
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // SIEMPRE mostramos el contenedor, así mantienen la misma altura
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : MBETheme.brandBlack.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$displayCount',
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
