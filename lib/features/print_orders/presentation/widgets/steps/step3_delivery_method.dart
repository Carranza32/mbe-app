// lib/features/print_orders/presentation/widgets/steps/step3_delivery_method.dart
import 'package:flutter/material.dart';
import 'package:mbe_orders_app/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';

import 'package:mbe_orders_app/config/theme/mbe_theme.dart';
import '../../../../../core/design_system/ds_badges.dart';
import '../../../../../core/design_system/ds_inputs.dart';
import '../../../../../core/design_system/ds_location_card.dart';
import '../../../../../core/design_system/ds_selection_cards.dart';

import '../../../providers/create_order_provider.dart';
import '../../../providers/print_order_delivery_promotion_provider.dart';
import '../../../../pre_alert/providers/stores_provider.dart';
import '../../../../pre_alert/providers/user_addresses_provider.dart';
import '../../../../profile/data/models/address_model.dart';

class Step3DeliveryMethod extends HookConsumerWidget {
  const Step3DeliveryMethod({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final orderState = ref.watch(createOrderProvider);
    final orderNotifier = ref.read(createOrderProvider.notifier);
    final deliveryInfo = orderState.request?.deliveryInfo;
    final pricing = orderNotifier.calculatePricing();
    final promoAsync = ref.watch(printOrderBestPromotionProvider(pricing.printSubtotal));

    final isPickup = deliveryInfo?.method == 'pickup' || deliveryInfo == null;
    final isDelivery = deliveryInfo?.method == 'delivery';

    // Badge de envío como en pre-alertas: promoción o costo por defecto
    final bestPromo = promoAsync.value;
    final appliesToDelivery = bestPromo != null &&
        bestPromo.appliesTo.toLowerCase() == 'delivery';
    final isFreeDeliveryPromo = appliesToDelivery &&
        bestPromo.discountType.toLowerCase() == 'free_delivery';

    Widget deliveryBadge;
    if (appliesToDelivery) {
      deliveryBadge = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isFreeDeliveryPromo)
            DSBadge.info(
              label: '\$${bestPromo.estimatedDiscount.toStringAsFixed(0)}',
            ),
          if (isFreeDeliveryPromo) ...[
            Text(
              'Desde \$${pricing.deliveryBaseCost.toStringAsFixed(2)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                decoration: TextDecoration.lineThrough,
                decorationColor: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: MBESpacing.xs),
            DSBadge.success(label: bestPromo.discountLabel),
          ],
        ],
      );
    } else {
      deliveryBadge = pricing.isFreeDelivery
          ? DSBadge.success(label: '¡Envío gratis!')
          : DSBadge.info(
              label: 'Desde \$${pricing.deliveryBaseCost.toStringAsFixed(2)}',
            );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                        l10n.printOrderChooseReceiveOrder,
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

        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 100),
          child: Column(
            children: [
              DSOptionCard(
                title: l10n.preAlertPickupInStore,
                description: l10n.preAlertPickupDescription,
                icon: Iconsax.box,
                isSelected: isPickup,
                onTap: () {
                  ref.read(createOrderProvider.notifier).setDeliveryMethod('pickup');
                },
                badge: DSBadge.success(label: l10n.preAlertNoAdditionalCost),
              ),
              const SizedBox(height: MBESpacing.md),
              DSOptionCard(
                title: l10n.preAlertHomeDelivery,
                description: l10n.preAlertDeliveryDescription,
                icon: Iconsax.truck_fast,
                isSelected: isDelivery,
                onTap: () {
                  ref.read(createOrderProvider.notifier).setDeliveryMethod('delivery');
                },
                badge: deliveryBadge,
              ),
            ],
          ),
        ),

        const SizedBox(height: MBESpacing.xl),

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
                  selectedLocation: deliveryInfo?.pickupLocation?.toString(),
                  onLocationSelected: (locationId) {
                    ref.read(createOrderProvider.notifier).setPickupLocation(
                      int.parse(locationId),
                    );
                  },
                )
              : _DeliveryContent(
                  key: const ValueKey('delivery-content'),
                  address: deliveryInfo.address ?? '',
                  phone: deliveryInfo.phone ?? '',
                  notes: deliveryInfo.notes ?? '',
                  pricing: pricing,
                  onAddressChanged: (value) {
                    ref.read(createOrderProvider.notifier).setDeliveryAddress(value);
                  },
                  onPhoneChanged: (value) {
                    ref.read(createOrderProvider.notifier).setDeliveryPhone(value);
                  },
                  onNotesChanged: (value) {
                    ref.read(createOrderProvider.notifier).setDeliveryNotes(value);
                  },
                ),
        ),

        const SizedBox(height: MBESpacing.xxxl),
      ],
    );
  }
}

/// Contenido para Recoger en Tienda (tiendas MBE, igual que pre-alertas)
class _PickupContent extends ConsumerWidget {
  final String? selectedLocation;
  final Function(String) onLocationSelected;

  const _PickupContent({
    super.key,
    required this.selectedLocation,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
            const Text('Error al cargar tiendas'),
            TextButton(
              onPressed: () => ref.invalidate(mbeStoresProvider),
              child: const Text('Reintentar'),
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
                  'No hay tiendas disponibles',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    'Selecciona una tienda',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: MBESpacing.lg),
            ...stores.asMap().entries.map((entry) {
              final store = entry.value;
              final dsLocation = DSLocation(
                id: store.id.toString(),
                name: store.name,
                address: store.address ?? 'Sin dirección',
                zone: store.zone ?? '',
                hours: null,
                phone: store.phone ?? '',
              );
              final isSelected = selectedLocation == dsLocation.id;
              return FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: Duration(milliseconds: entry.key * 100),
                child: DSLocationCard(
                  location: dsLocation,
                  isSelected: isSelected,
                  onTap: () => onLocationSelected(store.id.toString()),
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

/// Contenido para Envío a Domicilio (direcciones del cliente, igual que pre-alertas)
class _DeliveryContent extends ConsumerWidget {
  final String address;
  final String phone;
  final String notes;
  final PriceBreakdown pricing;
  final Function(String) onAddressChanged;
  final Function(String) onPhoneChanged;
  final Function(String) onNotesChanged;

  const _DeliveryContent({
    super.key,
    required this.address,
    required this.phone,
    required this.notes,
    required this.pricing,
    required this.onAddressChanged,
    required this.onPhoneChanged,
    required this.onNotesChanged,
  });

  static String _fullAddressString(AddressModel a) {
    final parts = [a.address, a.city, a.region];
    return parts.where((s) => s.isNotEmpty).join(', ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
            const Text('Error al cargar direcciones'),
            TextButton(
              onPressed: () => ref.invalidate(userAddressesProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      data: (addresses) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (addresses.isEmpty) ...[
              Center(
                child: Column(
                  children: [
                    const Icon(Iconsax.location, size: 48),
                    const SizedBox(height: MBESpacing.lg),
                    Text(
                      'No tienes direcciones guardadas',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: MBESpacing.md),
                    Text(
                      'Ingresa la dirección y teléfono abajo',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MBESpacing.lg),
              _DeliveryFormSection(
                address: address,
                phone: phone,
                notes: notes,
                onAddressChanged: onAddressChanged,
                onPhoneChanged: onPhoneChanged,
                onNotesChanged: onNotesChanged,
              ),
            ] else ...[
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
                      'Selecciona una dirección',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MBESpacing.lg),
              ...addresses.asMap().entries.map((entry) {
                final addressModel = entry.value;
                final fullAddr = _fullAddressString(addressModel);
                final isSelected = address == fullAddr && phone == addressModel.phone;
                return FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: Duration(milliseconds: entry.key * 100),
                  child: _AddressCard(
                    address: addressModel,
                    isSelected: isSelected,
                    onTap: () {
                      onAddressChanged(fullAddr);
                      onPhoneChanged(addressModel.phone);
                    },
                  ),
                );
              }),
              const SizedBox(height: MBESpacing.lg),
              DSInput.textArea(
                label: 'Notas Adicionales (opcional)',
                hint: 'Horario preferido, instrucciones especiales...',
                value: notes,
                onChanged: onNotesChanged,
                maxLines: 2,
              ),
            ],

            const SizedBox(height: MBESpacing.lg),

            // Información de costos dinámicos
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 100),
              child: Container(
            padding: const EdgeInsets.all(MBESpacing.lg),
            decoration: BoxDecoration(
              color: pricing.isFreeDelivery 
                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                  : MBETheme.lightGray,
              borderRadius: BorderRadius.circular(MBERadius.large),
              border: Border.all(
                color: pricing.isFreeDelivery
                    ? const Color(0xFF10B981).withValues(alpha: 0.3)
                    : MBETheme.neutralGray.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      pricing.isFreeDelivery ? Iconsax.tick_circle : Iconsax.truck,
                      size: 24,
                      color: pricing.isFreeDelivery 
                          ? const Color(0xFF10B981)
                          : colorScheme.onSurface,
                    ),
                    const SizedBox(width: MBESpacing.md),
                    Expanded(
                      child: Text(
                        pricing.isFreeDelivery
                            ? '¡Envío gratis! (pedido mayor a \$${pricing.freeDeliveryMinimum.toStringAsFixed(2)})'
                            : 'Costo de envío: \$${pricing.deliveryCost.toStringAsFixed(2)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: pricing.isFreeDelivery 
                              ? const Color(0xFF10B981)
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (!pricing.isFreeDelivery) ...[
                  const SizedBox(height: MBESpacing.lg),

                  _InfoRow(
                    icon: Iconsax.dollar_circle,
                    label: 'Costo base',
                    value: '\$${pricing.deliveryBaseCost.toStringAsFixed(2)}',
                    iconColor: const Color(0xFF10B981),
                  ),
                  
                  const SizedBox(height: MBESpacing.sm),

                  _InfoRow(
                    icon: Iconsax.receipt_2,
                    label: 'Envío gratis en pedidos mayores a',
                    value: '\$${pricing.freeDeliveryMinimum.toStringAsFixed(2)}',
                    iconColor: const Color(0xFF3B82F6),
                  ),
                ],
                
                const SizedBox(height: MBESpacing.sm),

                _InfoRow(
                  icon: Iconsax.clock,
                  label: 'Tiempo estimado',
                  value: '1-2 días hábiles',
                  iconColor: const Color(0xFFF59E0B),
                ),
              ],
            ),
              ),
            ),

            const SizedBox(height: MBESpacing.lg),

            // Tips de entrega
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 200),
              child: Container(
            padding: const EdgeInsets.all(MBESpacing.lg),
            decoration: MBECardDecoration.card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Iconsax.info_circle,
                      size: 20,
                      color: Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: MBESpacing.sm),
                    Text(
                      'Consejos para tu entrega',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MBESpacing.md),
                const _TipItem(
                  '• Asegúrate de incluir referencias claras de tu ubicación',
                ),
                const SizedBox(height: MBESpacing.xs),
                const _TipItem(
                  '• Verifica que tu teléfono esté disponible durante la entrega',
                ),
                const SizedBox(height: MBESpacing.xs),
                const _TipItem(
                  '• Puedes agregar un horario preferido en las notas',
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

/// Sección de formulario manual cuando no hay direcciones guardadas
class _DeliveryFormSection extends StatelessWidget {
  final String address;
  final String phone;
  final String notes;
  final Function(String) onAddressChanged;
  final Function(String) onPhoneChanged;
  final Function(String) onNotesChanged;

  const _DeliveryFormSection({
    required this.address,
    required this.phone,
    required this.notes,
    required this.onAddressChanged,
    required this.onPhoneChanged,
    required this.onNotesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MBESpacing.lg),
      decoration: MBECardDecoration.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DSInput.textArea(
            label: 'Dirección de Entrega',
            hint: 'Calle, número, colonia, municipio...',
            value: address,
            onChanged: onAddressChanged,
            required: true,
            maxLines: 3,
          ),
          const SizedBox(height: MBESpacing.lg),
          DSInput.phone(
            label: 'Teléfono de Contacto',
            hint: '2222-2222 o 7777-7777',
            value: phone,
            onChanged: onPhoneChanged,
            required: true,
          ),
          const SizedBox(height: MBESpacing.lg),
          DSInput.textArea(
            label: 'Notas (opcional)',
            hint: 'Horario preferido, referencias...',
            value: notes,
            onChanged: onNotesChanged,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

/// Card para una dirección del cliente (como en pre-alertas)
class _AddressCard extends StatelessWidget {
  final AddressModel address;
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: MBEDuration.normal,
        margin: const EdgeInsets.only(bottom: MBESpacing.md),
        padding: const EdgeInsets.all(MBESpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? MBETheme.brandBlack.withValues(alpha: 0.06)
              : MBETheme.lightGray,
          borderRadius: BorderRadius.circular(MBERadius.large),
          border: Border.all(
            color: isSelected
                ? MBETheme.brandBlack
                : MBETheme.neutralGray.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(MBESpacing.sm),
              decoration: BoxDecoration(
                color: isSelected
                    ? MBETheme.brandBlack
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(MBERadius.medium),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          address.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (address.isDefault)
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: MBESpacing.sm,
                              vertical: MBESpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(MBERadius.small),
                            ),
                            child: Text(
                              'Predeterminada',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: MBESpacing.xs),
                  Text(
                    address.address,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: MBESpacing.sm),
                  Wrap(
                    spacing: MBESpacing.xs,
                    runSpacing: MBESpacing.xs,
                    children: [
                      _InfoChip(
                        icon: Iconsax.location,
                        label: address.fullLocation,
                      ),
                      if (address.phone.isNotEmpty)
                        _InfoChip(icon: Iconsax.call, label: address.phone),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: MBESpacing.sm),
                child: Icon(Icons.check_rounded, color: MBETheme.brandBlack, size: 24),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: MBESpacing.sm, vertical: MBESpacing.xs),
        decoration: BoxDecoration(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(MBERadius.small),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.labelSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widgets auxiliares...
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
          child: Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
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

class _TipItem extends StatelessWidget {
  final String text;

  const _TipItem(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}