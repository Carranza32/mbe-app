// lib/features/pre_alert/presentation/screens/pre_alerts_list_screen.dart
import 'package:flutter/material.dart';
import 'package:mbe_orders_app/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../home/providers/main_scaffold_provider.dart';
import '../../../auth/presentation/widgets/verification_pending_modal.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/models/pre_alert_model.dart';
import '../../providers/pre_alerts_provider.dart';

class PreAlertsListScreen extends ConsumerStatefulWidget {
  const PreAlertsListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PreAlertsListScreen> createState() =>
      _PreAlertsListScreenState();
}

class _PreAlertsListScreenState extends ConsumerState<PreAlertsListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasShownModal = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Verificar si el customer está verificado después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVerificationStatus();
    });
  }

  void _checkVerificationStatus() {
    // Evitar mostrar el modal múltiples veces
    if (_hasShownModal || !mounted) return;
    
    final authState = ref.read(authProvider);
    final user = authState.value;
    
    if (user != null && 
        !user.isAdmin && 
        user.customer != null && 
        user.customer!.verifiedAt == null) {
      _hasShownModal = true;
      // Mostrar modal de verificación pendiente
      Future.microtask(() {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const VerificationPendingModal(),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Cargar más cuando se acerca al final
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final notifier = ref.read(preAlertsProvider.notifier);
      if (notifier.hasMore && !notifier.isLoadingMore) {
        notifier.loadMore().then((_) {
          if (mounted) {
            setState(() {});
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final preAlertsState = ref.watch(preAlertsProvider);

    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: Builder(
          builder: (context) {
            // Usar watch para obtener el GlobalKey reactivamente
            final scaffoldKey = ref.watch(mainScaffoldKeyProvider);
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                // Intentar abrir el drawer usando el GlobalKey
                if (scaffoldKey?.currentState != null) {
                  scaffoldKey!.currentState!.openDrawer();
                } else {
                  debugPrint('⚠️ GlobalKey del Scaffold no está disponible');
                }
              },
            );
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.preAlertMyPreAlerts,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFFED1C24), Color(0xFFB91419)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFED1C24).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            final authState = ref.read(authProvider);
            final user = authState.value;
            
            // Verificar si el customer está verificado antes de crear pre-alerta
            if (user != null && 
                !user.isAdmin && 
                user.customer != null && 
                user.customer!.verifiedAt == null) {
              showDialog(
                context: context,
                builder: (context) => const VerificationPendingModal(),
              );
            } else {
              context.push('/pre-alert/create');
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Iconsax.add_circle, color: Colors.white, size: 24),
          label: Text(
            AppLocalizations.of(context)!.preAlertNewPreAlert,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          await ref.read(preAlertsProvider.notifier).refresh();
        },
        child: preAlertsState.when(
          data: (preAlerts) {
            if (preAlerts.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [const SizedBox(height: 100), _EmptyState()],
              );
            }

            final notifier = ref.read(preAlertsProvider.notifier);
            final isLoadingMore = notifier.isLoadingMore;
            final hasMore = notifier.hasMore;

            // Verificar si hay pre-alertas que requieren acción
            final hasPendingActions = preAlerts.any((p) => p.requiresAction);

            return ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount:
                  preAlerts.length +
                  (hasPendingActions ? 1 : 0) +
                  (hasMore && isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Mostrar banner de alerta al inicio si hay acciones pendientes
                if (hasPendingActions && index == 0) {
                  return _ActionRequiredBanner();
                }

                // Ajustar índice si hay banner
                final adjustedIndex = hasPendingActions ? index - 1 : index;

                if (adjustedIndex == preAlerts.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final preAlert = preAlerts[adjustedIndex];
                return _PreAlertCard(preAlert: preAlert);
              },
            );
          },
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 200),
              Center(child: CircularProgressIndicator()),
            ],
          ),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 100),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Iconsax.info_circle,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(error.toString()),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(preAlertsProvider),
                      child: Text(AppLocalizations.of(context)!.preAlertRetry),
                    ),
                  ],
                ),
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

    return InkWell(
      onTap: () {
        if (preAlert.requiresAction) {
          // Icono amarillo: completar pre-alerta (entrega, contacto, pago)
          context.push(
            '/pre-alert/complete/${preAlert.id}',
            extra: preAlert,
          );
        } else {
          // Ver detalle (solo lectura)
          context.push('/pre-alert/detail/${preAlert.id}');
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
                            AppLocalizations.of(context)!.preAlertTracking,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Badge de acción requerida
                          if (preAlert.requiresAction) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Iconsax.danger,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
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
                    label: AppLocalizations.of(context)!.preAlertStore,
                    value: preAlert.store,
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Iconsax.calendar,
                    label: AppLocalizations.of(context)!.preAlertDate,
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
                    label: AppLocalizations.of(context)!.preAlertProducts,
                    value: '${preAlert.productCount}',
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Iconsax.dollar_circle,
                    label: AppLocalizations.of(context)!.preAlertTotal,
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
                  AppLocalizations.of(context)!.preAlertNoAddress,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
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
            Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
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

class _ActionRequiredBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.amber.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange.shade500,
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.box, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.preAlertActionRequired,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.preAlertActionRequiredMessage,
                  style: TextStyle(fontSize: 13, color: Colors.orange.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
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
          Text(
            AppLocalizations.of(context)!.preAlertNoPreAlerts,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.preAlertCreateFirst,
            style: TextStyle(color: MBETheme.neutralGray),
          ),
        ],
      ),
    );
  }
}
