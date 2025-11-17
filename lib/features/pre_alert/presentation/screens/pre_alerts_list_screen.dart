// lib/features/pre_alert/presentation/screens/pre_alerts_list_screen.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../data/models/pre_alert_model.dart';
import '../../providers/pre_alerts_provider.dart';

class PreAlertsListScreen extends HookConsumerWidget {
  const PreAlertsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preAlertsState = ref.watch(preAlertsProvider);

    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'Mis Prealertas',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add_circle),
            onPressed: () => context.push('/pre-alert/create'),
          ),
        ],
      ),
      body: preAlertsState.when(
        data: (response) => RefreshIndicator(
          onRefresh: () => ref.read(preAlertsProvider.notifier).refresh(),
          child: response.preAlerts.isEmpty
              ? _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: response.preAlerts.length,
                  itemBuilder: (context, index) {
                    final preAlert = response.preAlerts[index];
                    return _PreAlertCard(preAlert: preAlert);
                  },
                ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.info_circle, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(error.toString()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(preAlertsProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreAlertCard extends StatelessWidget {
  final PreAlert preAlert;

  const _PreAlertCard({required this.preAlert});

  Color _getStatusColor() {
    final colorHex = preAlert.statusColor.replaceAll('#', '');
    return Color(int.parse('FF$colorHex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('dd MMM yyyy').format(preAlert.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Tracking y Estado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tracking Number
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.truck_fast,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'TRACKING',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preAlert.trackingNumber,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Estado
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor().withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  preAlert.statusLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Tienda y Fecha
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Iconsax.shop,
                  label: 'TIENDA',
                  value: preAlert.store,
                ),
              ),
              Expanded(
                child: _InfoItem(
                  icon: Iconsax.calendar,
                  label: 'FECHA',
                  value: formattedDate,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Productos y Total
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Iconsax.box,
                  label: 'PRODUCTOS',
                  value: '${preAlert.productCount}',
                ),
              ),
              Expanded(
                child: _InfoItem(
                  icon: Iconsax.dollar_circle,
                  label: 'TOTAL',
                  value: '\$${preAlert.totalValue.toStringAsFixed(2)}',
                  valueColor: MBETheme.brandBlack,
                  isBold: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Casillero
          Row(
            children: [
              const Icon(
                Iconsax.location,
                size: 16,
                color: MBETheme.neutralGray,
              ),
              const SizedBox(width: 6),
              Text(
                'Sin dirección',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.box,
            size: 80,
            color: MBETheme.neutralGray.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No tienes pre-alertas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera pre-alerta de paquete',
            style: TextStyle(
              color: MBETheme.neutralGray,
            ),
          ),
        ],
      ),
    );
  }
}
