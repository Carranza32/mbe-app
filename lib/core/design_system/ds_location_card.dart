import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import '../../config/theme/mbe_theme.dart';

/// Card de ubicación/sucursal reutilizable
/// Uso: DSLocationCard(location: location, isSelected: true, onTap: () {})

class DSLocationCard extends StatelessWidget {
  final DSLocation location;
  final bool isSelected;
  final VoidCallback onTap;
  final int? animationDelay;

  const DSLocationCard({
    Key? key,
    required this.location,
    required this.isSelected,
    required this.onTap,
    this.animationDelay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeInLeft(
      duration: const Duration(milliseconds: 400),
      delay: animationDelay != null
          ? Duration(milliseconds: animationDelay! * 100)
          : Duration.zero,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: MBEDuration.normal,
          curve: MBECurve.standard,
          padding: const EdgeInsets.all(MBESpacing.lg),
          margin: const EdgeInsets.only(bottom: MBESpacing.md),
          decoration: BoxDecoration(
            color: isSelected 
                ? MBETheme.brandBlack.withValues(alpha: 0.03)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(MBERadius.large),
            border: Border.all(
              color: isSelected
                  ? MBETheme.brandBlack
                  : MBETheme.neutralGray.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1.5,
            ),
            boxShadow: isSelected ? MBETheme.shadowMd : MBETheme.shadowSm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono - Estilo Grab
              AnimatedContainer(
                duration: MBEDuration.normal,
                curve: MBECurve.standard,
                padding: const EdgeInsets.all(MBESpacing.md),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? MBETheme.brandBlack
                      : MBETheme.lightGray,
                  borderRadius: BorderRadius.circular(MBERadius.medium),
                  boxShadow: isSelected ? MBETheme.shadowSm : [],
                ),
                child: Icon(
                  Iconsax.location5,
                  size: 24,
                  color: isSelected 
                      ? Colors.white 
                      : colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(width: MBESpacing.md),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Text(
                      location.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: MBESpacing.xs),

                    // Dirección
                    Text(
                      location.address,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: MBESpacing.sm),

                    // Badges
                    Wrap(
                      spacing: MBESpacing.xs,
                      runSpacing: MBESpacing.xs,
                      children: [
                        if (location.zone != null)
                          _InfoBadge(
                            icon: Iconsax.location,
                            label: location.zone!,
                          ),
                        if (location.hours != null)
                          _InfoBadge(
                            icon: Iconsax.clock,
                            label: location.hours!,
                          ),
                        if (location.phone != null)
                          _InfoBadge(
                            icon: Iconsax.call,
                            label: location.phone!,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: MBESpacing.sm),

              // Checkmark
              if (isSelected)
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: MBETheme.brandBlack,
                          shape: BoxShape.circle,
                          boxShadow: MBETheme.shadowMd,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MBESpacing.sm, 
        vertical: MBESpacing.xs,
      ),
      decoration: BoxDecoration(
        color: MBETheme.lightGray,
        borderRadius: BorderRadius.circular(MBERadius.small),
        border: Border.all(
          color: MBETheme.neutralGray.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: MBESpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Modelo de datos para ubicación
class DSLocation {
  final String id;
  final String name;
  final String address;
  final String? zone;
  final String? hours;
  final String? phone;

  const DSLocation({
    required this.id,
    required this.name,
    required this.address,
    this.zone,
    this.hours,
    this.phone,
  });

  factory DSLocation.fromJson(Map<String, dynamic> json) {
    return DSLocation(
      id: json['id'].toString(),
      name: json['name'] as String,
      address: json['address'] as String,
      zone: json['zone'] as String?,
      hours: json['hours'] as String?,
      phone: json['phone'] as String?,
    );
  }
}