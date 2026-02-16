import 'package:flutter/material.dart';
import 'package:mbe_orders_app/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mbe_orders_app/config/theme/mbe_theme.dart';
import 'package:mbe_orders_app/core/design_system/ds_selection_cards.dart';
import 'package:mbe_orders_app/core/design_system/ds_location_card.dart';
import 'package:mbe_orders_app/core/design_system/ds_badges.dart';
import '../../../data/models/pre_alert_model.dart';
import '../../../data/models/promotion_model.dart';
import '../../../providers/pre_alert_complete_provider.dart';
import '../../../providers/stores_provider.dart';
import '../../../providers/user_addresses_provider.dart';

class Step1Delivery extends HookConsumerWidget {
  final PreAlert preAlert;

  const Step1Delivery({Key? key, required this.preAlert}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final completeState = ref.watch(preAlertCompleteProvider(preAlert));
    final completeNotifier = ref.read(
      preAlertCompleteProvider(preAlert).notifier,
    );

    final isPickup = completeState.isPickup;
    final isDelivery = completeState.isDelivery;
    final bestPromo = completeState.bestPromotionForDelivery;
    final appliesToDelivery =
        bestPromo != null &&
            bestPromo.appliesTo.toLowerCase() == 'delivery';
    final isFreeDelivery =
        appliesToDelivery &&
            bestPromo.discountType.toLowerCase() == 'free_delivery';

    Widget deliveryBadge;
    if (appliesToDelivery) {
      deliveryBadge = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge azul: descuento aplicable (ej. $2)
          DSBadge.info(
            label: '\$${bestPromo.estimatedDiscount.toStringAsFixed(0)}',
          ),
          if (isFreeDelivery) ...[
            const SizedBox(height: MBESpacing.xs),
            // Precio delivery tachado
            Text(
              '${l10n.preAlertFrom} \$2.00',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                decoration: TextDecoration.lineThrough,
                decorationColor: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: MBESpacing.xs),
            // Badge verde con el texto de la promo (ej. Envío Gratis)
            DSBadge.success(label: bestPromo.discountLabel),
          ],
        ],
      );
    } else {
      deliveryBadge = DSBadge.info(label: '${l10n.preAlertFrom} \$2.00');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header del paso
        FadeInDown(
          duration: const Duration(milliseconds: 400),
          child: Container(
            padding: const EdgeInsets.all(MBESpacing.lg),
            decoration: MBECardDecoration.card(),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(MBESpacing.md),
                  decoration: BoxDecoration(
                    color: MBETheme.brandBlack,
                    borderRadius: BorderRadius.circular(MBERadius.medium),
                    boxShadow: MBETheme.shadowSm,
                  ),
                  child: const Icon(
                    Iconsax.truck,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: MBESpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.preAlertDeliveryMethod,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: MBESpacing.xs),
                      Text(
                        l10n.preAlertChooseDeliverySubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: MBESpacing.lg),

        // Selección de método
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 100),
          child: Column(
            children: [
              // Recoger en Tienda
              DSOptionCard(
                title: l10n.preAlertPickupInStore,
                description: l10n.preAlertPickupDescription,
                icon: Iconsax.box,
                isSelected: isPickup,
                onTap: () {
                  completeNotifier.setDeliveryMethod('pickup');
                },
                badge: DSBadge.success(label: l10n.preAlertNoAdditionalCost),
              ),

              const SizedBox(height: MBESpacing.md),

              // Entrega a Domicilio
              DSOptionCard(
                title: l10n.preAlertHomeDelivery,
                description: l10n.preAlertDeliveryDescription,
                icon: Iconsax.truck_fast,
                isSelected: isDelivery,
                onTap: () {
                  completeNotifier.setDeliveryMethod('delivery');
                },
                badge: deliveryBadge,
              ),
            ],
          ),
        ),

        // Banner de promoción si existe
        if (completeState.promotion != null && completeState.isDelivery) ...[
          const SizedBox(height: MBESpacing.lg),
          _PromotionBanner(promotion: completeState.promotion!),
        ],

        const SizedBox(height: MBESpacing.xl),

        // Contenido según el método seleccionado
        AnimatedSwitcher(
          duration: MBEDuration.normal,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: isPickup
              ? _PickupContent(
                  key: const ValueKey('pickup-content'),
                  selectedStoreId: completeState.selectedStoreId,
                  onStoreSelected: (storeId) {
                    completeNotifier.setSelectedStore(storeId);
                  },
                )
              : isDelivery
              ? _DeliveryContent(
                  key: const ValueKey('delivery-content'),
                  selectedAddressId: completeState.selectedAddressId,
                  preAlert: preAlert,
                  onAddressSelected: (addressId) {
                    completeNotifier.setSelectedAddress(addressId);
                  },
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ],
    );
  }
}

/// Contenido para Recoger en Tienda
class _PickupContent extends ConsumerWidget {
  final int? selectedStoreId;
  final Function(int) onStoreSelected;

  const _PickupContent({
    super.key,
    required this.selectedStoreId,
    required this.onStoreSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final storesAsync = ref.watch(mbeStoresProvider);

    return storesAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(MBESpacing.xl),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          children: [
            const Icon(Iconsax.warning_2, size: 48, color: MBETheme.brandRed),
            const SizedBox(height: MBESpacing.lg),
            Text(l10n.preAlertErrorLoadingStores),
            TextButton(
              onPressed: () => ref.invalidate(mbeStoresProvider),
              child: Text(l10n.preAlertRetry),
            ),
          ],
        ),
      ),
      data: (stores) {
        if (stores.isEmpty) {
          return Center(
            child: Column(
              children: [
                const Icon(Iconsax.location, size: 48),
                const SizedBox(height: MBESpacing.lg),
                Text(
                  l10n.preAlertNoStores,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de sección
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MBESpacing.xs),
              child: Row(
                children: [
                  Icon(
                    Iconsax.location,
                    size: 20,
                    color: colorScheme.onSurface,
                  ),
                  const SizedBox(width: MBESpacing.sm),
                  Text(
                    l10n.preAlertSelectStoreTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: MBESpacing.lg),

            // Lista de tiendas
            ...stores.asMap().entries.map((entry) {
              final store = entry.value;

              final dsLocation = DSLocation(
                id: store.id.toString(),
                name: store.name,
                address: store.address ?? l10n.preAlertNoAddressFallback,
                zone: store.zone ?? '',
                hours: null,
                phone: store.phone ?? '',
              );

              final isSelected = selectedStoreId == store.id;

              return FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: Duration(milliseconds: entry.key * 100),
                child: DSLocationCard(
                  location: dsLocation,
                  isSelected: isSelected,
                  onTap: () => onStoreSelected(store.id),
                  animationDelay: entry.key,
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

/// Contenido para Envío a Domicilio
class _DeliveryContent extends ConsumerWidget {
  final int? selectedAddressId;
  final PreAlert preAlert;
  final Function(int) onAddressSelected;

  const _DeliveryContent({
    super.key,
    required this.selectedAddressId,
    required this.preAlert,
    required this.onAddressSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Obtener direcciones del usuario usando provider estable
    final addressesAsync = ref.watch(userAddressesProvider);

    return addressesAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(MBESpacing.xl),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          children: [
            const Icon(Iconsax.warning_2, size: 48, color: MBETheme.brandRed),
            const SizedBox(height: MBESpacing.lg),
            Text(l10n.preAlertErrorLoadingAddresses),
            TextButton(
              onPressed: () => ref.invalidate(userAddressesProvider),
              child: Text(l10n.preAlertRetry),
            ),
          ],
        ),
      ),
      data: (addresses) {
        if (addresses.isEmpty) {
          return Center(
            child: Column(
              children: [
                const Icon(Iconsax.location, size: 48),
                const SizedBox(height: MBESpacing.lg),
                Text(
                  l10n.preAlertNoAddresses,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: MBESpacing.md),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navegar a agregar dirección
                  },
                  icon: const Icon(Iconsax.add),
                  label: Text(l10n.preAlertAddAddress),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de sección
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MBESpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.location,
                        size: 20,
                        color: colorScheme.onSurface,
                      ),
                      const SizedBox(width: MBESpacing.sm),
                      Text(
                        l10n.preAlertSelectAddress,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.add),
                    onPressed: () {
                      // TODO: Navegar a agregar dirección
                    },
                    tooltip: l10n.preAlertNewAddress,
                  ),
                ],
              ),
            ),

            const SizedBox(height: MBESpacing.lg),

            // Lista de direcciones
            ...addresses.asMap().entries.map((entry) {
              final address = entry.value;
              final isSelected = selectedAddressId == address.id;

              return FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: Duration(milliseconds: entry.key * 100),
                child: _AddressCard(
                  address: address,
                  isSelected: isSelected,
                  onTap: () => onAddressSelected(address.id),
                ),
              );
            }),

            const SizedBox(height: MBESpacing.lg),

            // Información de envío
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: Duration(milliseconds: addresses.length * 100),
              child: Container(
                padding: const EdgeInsets.all(MBESpacing.lg),
                decoration: BoxDecoration(
                  color: MBETheme.lightGray,
                  borderRadius: BorderRadius.circular(MBERadius.large),
                  border: Border.all(
                    color: MBETheme.neutralGray.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Iconsax.dollar_circle,
                      label: l10n.preAlertBaseCost,
                      value: '\$2.00',
                      iconColor: const Color(0xFF10B981),
                    ),
                    const SizedBox(height: MBESpacing.sm),
                    _InfoRow(
                      icon: Iconsax.clock,
                      label: l10n.preAlertEstimatedTime,
                      value: l10n.preAlertEstimatedTimeValue,
                      iconColor: const Color(0xFFF59E0B),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Card para mostrar una dirección
class _AddressCard extends StatelessWidget {
  final dynamic address; // AddressModel
  final bool isSelected;
  final VoidCallback onTap;

  const _AddressCard({
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
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
            // Icono
            AnimatedContainer(
              duration: MBEDuration.normal,
              curve: MBECurve.standard,
              padding: const EdgeInsets.all(MBESpacing.md),
              decoration: BoxDecoration(
                color: isSelected ? MBETheme.brandBlack : MBETheme.lightGray,
                borderRadius: BorderRadius.circular(MBERadius.medium),
                boxShadow: isSelected ? MBETheme.shadowSm : [],
              ),
              child: Icon(
                address.name.toLowerCase().contains('casa') ||
                        address.name.toLowerCase().contains('home')
                    ? Iconsax.home
                    : Iconsax.building,
                size: 24,
                color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(width: MBESpacing.md),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          address.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (address.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: MBESpacing.sm,
                            vertical: MBESpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              MBERadius.small,
                            ),
                          ),
                          child: Text(
                            l10n.preAlertDefault,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: const Color(0xFF10B981),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: MBESpacing.xs),

                  // Dirección completa
                  Text(
                    address.address,
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
                      _InfoBadge(
                        icon: Iconsax.location,
                        label: address.fullLocation,
                      ),
                      if (address.phone.isNotEmpty)
                        _InfoBadge(icon: Iconsax.call, label: address.phone),
                      if (address.references != null &&
                          address.references!.isNotEmpty)
                        _InfoBadge(
                          icon: Iconsax.info_circle,
                          label: address.references!,
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
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoBadge({required this.icon, required this.label});

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
        border: Border.all(color: MBETheme.neutralGray.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: MBESpacing.xs),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(MBESpacing.sm),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(MBERadius.small),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: MBESpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Banner de promoción
class _PromotionBanner extends StatelessWidget {
  final PromotionModel promotion;

  const _PromotionBanner({required this.promotion});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return FadeInDown(
      duration: const Duration(milliseconds: 400),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: MBESpacing.xs),
        padding: const EdgeInsets.all(MBESpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF10B981).withValues(alpha: 0.1),
              const Color(0xFF10B981).withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(MBERadius.large),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(MBESpacing.sm),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(MBERadius.medium),
              ),
              child: const Icon(
                Iconsax.discount_shape,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: MBESpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promotion.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: MBETheme.brandBlack,
                    ),
                  ),
                  const SizedBox(height: MBESpacing.xs),
                  Row(
                    children: [
                      const Icon(
                        Iconsax.tick_circle,
                        size: 16,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: MBESpacing.xs),
                      Text(
                        l10n.preAlertSaveAmount('\$${promotion.estimatedDiscount.toStringAsFixed(2)}'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
}
