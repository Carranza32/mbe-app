// lib/features/print_orders/presentation/widgets/steps/step3_delivery_method.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';

import 'package:mbe_orders_app/config/theme/mbe_theme.dart';
import '../../../../../core/design_system/ds_badges.dart';
import '../../../../../core/design_system/ds_inputs.dart';
import '../../../../../core/design_system/ds_location_card.dart';
import '../../../../../core/design_system/ds_selection_cards.dart';

// ✅ CAMBIO: Importa el provider centralizado
import '../../../providers/create_order_provider.dart';
import '../../../providers/print_config_provider.dart';
import '../../../providers/delivery_pricing_provider.dart';

class Step3DeliveryMethod extends HookConsumerWidget {
  const Step3DeliveryMethod({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // ✅ CAMBIO: Lee desde el provider centralizado
    final orderState = ref.watch(createOrderProvider);
    final deliveryInfo = orderState.request?.deliveryInfo;
    final deliveryPricing = ref.watch(deliveryPricingProvider);
    final configAsync = ref.watch(printConfigProvider);

    // ✅ FIX: Determinar método actual (por defecto pickup si es null)
    final isPickup = deliveryInfo?.method == 'pickup' || deliveryInfo == null;
    final isDelivery = deliveryInfo?.method == 'delivery';

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
                        'Método de Entrega',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: MBESpacing.xs),
                      Text(
                        'Elige cómo quieres recibir tu pedido',
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
                title: 'Recoger en Tienda',
                description: 'Recoge tu pedido en cualquiera de nuestras ubicaciones',
                icon: Iconsax.box,
                isSelected: isPickup,
                onTap: () {
                  // ✅ CAMBIO: Actualiza en el provider centralizado
                  ref.read(createOrderProvider.notifier).setDeliveryMethod('pickup');
                },
                badge: DSBadge.success(label: 'Sin costo adicional'),
              ),

              const SizedBox(height: MBESpacing.md),

              // Envío a Domicilio
              DSOptionCard(
                title: 'Envío a Domicilio',
                description: 'Recibe tu pedido en la puerta de tu casa u oficina',
                icon: Iconsax.truck_fast,
                isSelected: isDelivery,
                onTap: () {
                  // ✅ CAMBIO: Actualiza en el provider centralizado
                  ref.read(createOrderProvider.notifier).setDeliveryMethod('delivery');
                },
                badge: deliveryPricing.isFreeDelivery
                    ? DSBadge.success(label: '¡Envío gratis!')
                    : DSBadge.info(
                        label: 'Desde \$${deliveryPricing.baseCost.toStringAsFixed(2)}',
                      ),
              ),
            ],
          ),
        ),

        const SizedBox(height: MBESpacing.xl),

        // ✅ FIX: Contenido según el método seleccionado con keys únicas
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
                  key: const ValueKey('pickup-content'), // ✅ FIX: Key única
                  configAsync: configAsync,
                  selectedLocation: deliveryInfo?.pickupLocation?.toString(),
                  onLocationSelected: (locationId) {
                    ref.read(createOrderProvider.notifier).setPickupLocation(
                      int.parse(locationId),
                    );
                  },
                )
              : _DeliveryContent(
                  key: const ValueKey('delivery-content'), // ✅ FIX: Key única
                  address: deliveryInfo?.address ?? '',
                  phone: deliveryInfo?.phone ?? '',
                  notes: deliveryInfo?.notes ?? '',
                  pricing: deliveryPricing,
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

/// Contenido para Recoger en Tienda
class _PickupContent extends StatelessWidget {
  final AsyncValue configAsync;
  final String? selectedLocation;
  final Function(String) onLocationSelected;

  const _PickupContent({
    super.key, // ✅ Agregado key
    required this.configAsync,
    required this.selectedLocation,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return configAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          children: [
            const Icon(Iconsax.warning_2, size: 48, color: MBETheme.brandRed),
            const SizedBox(height: MBESpacing.lg),
            const Text('Error al cargar ubicaciones'),
            TextButton(
              onPressed: () {}, // TODO: Retry
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      data: (configModel) {
        final locations = configModel.pickupLocations ?? [];

        if (locations.isEmpty) {
          return Center(
            child: Column(
              children: [
                const Icon(Iconsax.location, size: 48),
                const SizedBox(height: MBESpacing.lg),
                Text(
                  'No hay ubicaciones disponibles',
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
                    'Selecciona una ubicación',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: MBESpacing.lg),

            // Lista de ubicaciones desde el backend
            ...locations.asMap().entries.map((entry) {
              final location = entry.value;
              final openingHours = location.openingHours;
              
              // Formatear horario (tomar el primer día disponible)
              String hours = 'Consultar horarios';
              if (openingHours != null) {
                if (openingHours.lunes != null) {
                  hours = 'Lun-Vie: ${openingHours.lunes}';
                }
              }

              final dsLocation = DSLocation(
                id: location.id?.toString() ?? '',
                name: location.name ?? 'Sin nombre',
                address: location.address ?? 'Sin dirección',
                zone: location.zone ?? '',
                hours: hours,
                phone: location.phone ?? '',
              );

              return FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 100),
                child: DSLocationCard(
                  location: dsLocation,
                  isSelected: selectedLocation == dsLocation.id,
                  onTap: () => onLocationSelected(dsLocation.id),
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
class _DeliveryContent extends StatelessWidget {
  // ✅ FIX: Recibe valores individuales en vez de estado completo
  final String address;
  final String phone;
  final String notes;
  final DeliveryPricingResult pricing;
  final Function(String) onAddressChanged;
  final Function(String) onPhoneChanged;
  final Function(String) onNotesChanged;

  const _DeliveryContent({
    super.key, // ✅ Agregado key
    required this.address,
    required this.phone,
    required this.notes,
    required this.pricing,
    required this.onAddressChanged,
    required this.onPhoneChanged,
    required this.onNotesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card de información de envío
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          child: Container(
            padding: const EdgeInsets.all(MBESpacing.lg),
            decoration: MBECardDecoration.card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Iconsax.note_text,
                      size: 24,
                      color: colorScheme.onSurface,
                    ),
                    const SizedBox(width: MBESpacing.md),
                    Text(
                      'Información de Envío',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: MBESpacing.xl),

                // Dirección de Entrega
                DSInput.textArea(
                  label: 'Dirección de Entrega',
                  hint: 'Calle, número, colonia, municipio, referencias (ej: portón azul)...',
                  value: address,
                  onChanged: onAddressChanged,
                  required: true,
                  maxLines: 3,
                ),

                const SizedBox(height: MBESpacing.lg),

                // Teléfono de Contacto
                DSInput.phone(
                  label: 'Teléfono de Contacto',
                  hint: '2222-2222 o 7777-7777',
                  value: phone,
                  onChanged: onPhoneChanged,
                  required: true,
                ),

                const SizedBox(height: MBESpacing.lg),

                // Notas Adicionales
                DSInput.textArea(
                  label: 'Notas Adicionales (opcional)',
                  hint: 'Horario preferido, instrucciones especiales, punto de referencia...',
                  value: notes,
                  onChanged: onNotesChanged,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),

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
                        pricing.message,
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
                    value: '\$${pricing.baseCost.toStringAsFixed(2)}',
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