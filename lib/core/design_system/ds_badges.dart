import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/theme/mbe_theme.dart';

/// Badges y chips reutilizables
/// Uso: DSBadge.success(label: 'Sin costo')

class DSBadge {
  DSBadge._();

  /// Badge de éxito (verde)
  static Widget success({
    required String label,
    IconData? icon,
    bool withAnimation = false,
  }) {
    return _Badge(
      label: label,
      icon: icon,
      color: const Color(0xFF10B981),
      withAnimation: withAnimation,
    );
  }

  /// Badge de error (rojo MBE)
  static Widget error({
    required String label,
    IconData? icon,
    bool withAnimation = false,
  }) {
    return _Badge(
      label: label,
      icon: icon,
      color: MBETheme.brandRed,
      withAnimation: withAnimation,
    );
  }

  /// Badge de advertencia (naranja)
  static Widget warning({
    required String label,
    IconData? icon,
    bool withAnimation = false,
  }) {
    return _Badge(
      label: label,
      icon: icon,
      color: const Color(0xFFF59E0B),
      withAnimation: withAnimation,
    );
  }

  /// Badge de info (azul)
  static Widget info({
    required String label,
    IconData? icon,
    bool withAnimation = false,
  }) {
    return _Badge(
      label: label,
      icon: icon,
      color: const Color(0xFF3B82F6),
      withAnimation: withAnimation,
    );
  }

  /// Badge neutral (negro)
  static Widget neutral({
    required String label,
    IconData? icon,
    bool withAnimation = false,
  }) {
    return _Badge(
      label: label,
      icon: icon,
      color: MBETheme.brandBlack,
      withAnimation: withAnimation,
    );
  }

  /// Badge personalizado
  static Widget custom({
    required String label,
    IconData? icon,
    required Color color,
    bool withAnimation = false,
  }) {
    return _Badge(
      label: label,
      icon: icon,
      color: color,
      withAnimation: withAnimation,
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final bool withAnimation;

  const _Badge({
    required this.label,
    this.icon,
    required this.color,
    this.withAnimation = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget badge = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MBESpacing.sm + 2, 
        vertical: MBESpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(MBERadius.full),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: MBESpacing.xs),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (withAnimation) {
      return ZoomIn(
        duration: const Duration(milliseconds: 300),
        child: badge,
      );
    }

    return badge;
  }
}

/// Chip seleccionable (para filtros) - Estilo Grab
class DSChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const DSChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: MBEDuration.normal,
        curve: MBECurve.standard,
        padding: const EdgeInsets.symmetric(
          horizontal: MBESpacing.md, 
          vertical: MBESpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? MBETheme.brandBlack : MBETheme.lightGray,
          borderRadius: BorderRadius.circular(MBERadius.full),
          border: Border.all(
            color: isSelected
                ? MBETheme.brandBlack
                : MBETheme.neutralGray.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? MBETheme.shadowSm : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: MBESpacing.xs),
            ],
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected ? Colors.white : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge de contador (notifications, etc)
class DSCounterBadge extends StatelessWidget {
  final int count;
  final Color? color;

  const DSCounterBadge({
    Key? key,
    required this.count,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? MBETheme.brandRed;

    if (count == 0) return const SizedBox.shrink();

    return ZoomIn(
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: MBESpacing.xs + 2, 
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: effectiveColor,
          borderRadius: BorderRadius.circular(MBERadius.full),
          boxShadow: [
            BoxShadow(
              color: effectiveColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: const BoxConstraints(
          minWidth: 20,
          minHeight: 20,
        ),
        child: Center(
          child: Text(
            count > 99 ? '99+' : count.toString(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}

/// Badge de estado (online, offline, etc)
class DSStatusBadge extends StatelessWidget {
  final String label;
  final DSStatusBadgeType type;

  const DSStatusBadge({
    Key? key,
    required this.label,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    IconData icon;

    switch (type) {
      case DSStatusBadgeType.online:
        color = const Color(0xFF10B981);
        icon = Icons.circle;
        break;
      case DSStatusBadgeType.offline:
        color = MBETheme.neutralGray;
        icon = Icons.circle;
        break;
      case DSStatusBadgeType.away:
        color = const Color(0xFFF59E0B);
        icon = Icons.circle;
        break;
      case DSStatusBadgeType.busy:
        color = MBETheme.brandRed;
        icon = Icons.circle;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MBESpacing.sm, 
        vertical: MBESpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(MBERadius.full),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 8,
            color: color,
          ),
          const SizedBox(width: MBESpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum DSStatusBadgeType {
  online,
  offline,
  away,
  busy,
}