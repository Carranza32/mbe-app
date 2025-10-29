import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';

import 'package:mbe_orders_app/config/theme/mbe_theme.dart';
import '../../../../../core/design_system/ds_badges.dart';
import '../../../../../core/design_system/ds_inputs.dart';
import '../../../../../core/design_system/ds_location_card.dart';
import '../../../../../core/design_system/ds_selection_cards.dart';


// Enum para método de entrega
enum DeliveryMethod { pickup, delivery }

class Step3DeliveryMethod extends HookConsumerWidget {
  const Step3DeliveryMethod({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // States
    final deliveryMethod = useState(DeliveryMethod.pickup);
    final selectedLocation = useState<String?>(null);
    final deliveryAddress = useState('');
    final deliveryPhone = useState('');
    final deliveryNotes = useState('');

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
                isSelected: deliveryMethod.value == DeliveryMethod.pickup,
                onTap: () => deliveryMethod.value = DeliveryMethod.pickup,
                badge: DSBadge.success(label: 'Sin costo adicional'),
              ),

              const SizedBox(height: MBESpacing.md),

              // Envío a Domicilio
              DSOptionCard(
                title: 'Envío a Domicilio',
                description: 'Recibe tu pedido en la puerta de tu casa u oficina',
                icon: Iconsax.truck_fast,
                isSelected: deliveryMethod.value == DeliveryMethod.delivery,
                onTap: () => deliveryMethod.value = DeliveryMethod.delivery,
                badge: DSBadge.info(label: 'Desde \$2.00'),
              ),
            ],
          ),
        ),

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
          child: deliveryMethod.value == DeliveryMethod.pickup
              ? _PickupContent(
                  selectedLocation: selectedLocation.value,
                  onLocationSelected: (locationId) {
                    selectedLocation.value = locationId;
                  },
                )
              : _DeliveryContent(
                  address: deliveryAddress.value,
                  phone: deliveryPhone.value,
                  notes: deliveryNotes.value,
                  onAddressChanged: (value) => deliveryAddress.value = value,
                  onPhoneChanged: (value) => deliveryPhone.value = value,
                  onNotesChanged: (value) => deliveryNotes.value = value,
                ),
        ),

        const SizedBox(height: MBESpacing.xxxl),
      ],
    );
  }
}

/// Contenido para Recoger en Tienda
class _PickupContent extends StatelessWidget {
  final String? selectedLocation;
  final Function(String) onLocationSelected;

  const _PickupContent({
    required this.selectedLocation,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Datos de ejemplo - reemplazar con datos reales
    final locations = [
      const DSLocation(
        id: '1',
        name: 'Centro Histórico',
        address: 'Av. Cuscatlán #123, San Salvador',
        zone: 'Centro',
        hours: 'Lun-Vie 8AM-6PM',
        phone: '2222-2222',
      ),
      const DSLocation(
        id: '2',
        name: 'Santa Elena',
        address: 'Plaza Santa Elena Local 45',
        zone: 'Antiguo Cuscatlán',
        hours: 'Lun-Sab 9AM-7PM',
        phone: '2333-3333',
      ),
      const DSLocation(
        id: '3',
        name: 'Metrocentro',
        address: 'Centro Comercial Metrocentro, 2do Nivel',
        zone: 'San Salvador',
        hours: 'Lun-Dom 10AM-8PM',
        phone: '2444-4444',
      ),
    ];

    return Column(
      key: const ValueKey('pickup'),
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

        // Lista de ubicaciones
        ...locations.asMap().entries.map((entry) {
          return FadeInUp(
            duration: const Duration(milliseconds: 400),
            delay: Duration(milliseconds: 100 * entry.key),
            child: DSLocationCard(
              location: entry.value,
              isSelected: selectedLocation == entry.value.id,
              onTap: () => onLocationSelected(entry.value.id),
              animationDelay: entry.key,
            ),
          );
        }),
      ],
    );
  }
}

/// Contenido para Envío a Domicilio
class _DeliveryContent extends StatelessWidget {
  final String address;
  final String phone;
  final String notes;
  final Function(String) onAddressChanged;
  final Function(String) onPhoneChanged;
  final Function(String) onNotesChanged;

  const _DeliveryContent({
    required this.address,
    required this.phone,
    required this.notes,
    required this.onAddressChanged,
    required this.onPhoneChanged,
    required this.onNotesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      key: const ValueKey('delivery'),
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

        // Información de costos
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 100),
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
                Row(
                  children: [
                    Icon(
                      Iconsax.truck,
                      size: 24,
                      color: colorScheme.onSurface,
                    ),
                    const SizedBox(width: MBESpacing.md),
                    Text(
                      'Información de Envío',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: MBESpacing.lg),

                _InfoRow(
                  icon: Iconsax.dollar_circle,
                  label: 'Costo base',
                  value: '\$2.00',
                  iconColor: const Color(0xFF10B981),
                ),
                
                const SizedBox(height: MBESpacing.sm),

                _InfoRow(
                  icon: Iconsax.receipt_2,
                  label: 'Envío gratis en pedidos mayores a',
                  value: '\$20.00',
                  iconColor: const Color(0xFF3B82F6),
                ),
                
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
                _TipItem(
                  '• Asegúrate de incluir referencias claras de tu ubicación',
                ),
                const SizedBox(height: MBESpacing.xs),
                _TipItem(
                  '• Verifica que tu teléfono esté disponible durante la entrega',
                ),
                const SizedBox(height: MBESpacing.xs),
                _TipItem(
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

// Widget auxiliar: Fila de información
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

// Widget auxiliar: Item de consejo
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