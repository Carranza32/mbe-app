// lib/features/print_orders/presentation/screens/my_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:mbe_orders_app/l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../home/providers/main_scaffold_provider.dart';
import '../../../auth/presentation/widgets/verification_pending_modal.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/models/print_order_model.dart';
import '../../providers/orders_provider.dart';
import 'order_detail_screen.dart';

class MyOrdersScreen extends HookConsumerWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);
    final authState = ref.watch(authProvider);
    final user = authState.value;
    final hasShownModal = useState(false);

    // Verificar si el customer está verificado después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Evitar mostrar el modal múltiples veces
      if (hasShownModal.value) return;
      
      if (user != null && 
          !user.isAdmin && 
          user.customer != null && 
          user.customer!.verifiedAt == null) {
        hasShownModal.value = true;
        // Mostrar modal de verificación pendiente
        Future.microtask(() {
          if (context.mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const VerificationPendingModal(),
            );
          }
        });
      }
    });

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
          AppLocalizations.of(context)!.printOrderMyOrders,
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
            
            // Verificar si el customer está verificado antes de crear pedido
            if (user != null && 
                !user.isAdmin && 
                user.customer != null && 
                user.customer!.verifiedAt == null) {
              showDialog(
                context: context,
                builder: (context) => const VerificationPendingModal(),
              );
            } else {
              context.push('/print-orders/create');
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Iconsax.add_circle, color: Colors.white, size: 24),
          label: Text(
            AppLocalizations.of(context)!.printOrderNewOrder,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
      body: ordersState.when(
        data: (response) => RefreshIndicator(
          onRefresh: () => ref.read(ordersProvider.notifier).refresh(),
          child: response.orders.isEmpty
              ? _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: response.orders.length,
                  itemBuilder: (context, index) {
                    final order = response.orders[index];
                    return _OrderCard(order: order);
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
                onPressed: () => ref.invalidate(ordersProvider),
                child: Text(AppLocalizations.of(context)!.preAlertRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final PrintOrder order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OrderDetailScreen(orderNumber: order.orderNumber),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.orderNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: order.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.statusLabel,
                        style: TextStyle(
                          color: order.statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Info
                Row(
                  children: [
                    _InfoChip(
                      icon: order.printType == 'color'
                          ? Iconsax.color_swatch
                          : Iconsax.document_text,
                      label: order.printType == 'color' ? 'Color' : 'B/N',
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Iconsax.document,
                      label: '${order.pagesCount} ${AppLocalizations.of(context)!.printOrderPagesShort}',
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: order.deliveryMethod == 'pickup'
                          ? Iconsax.shop
                          : Iconsax.truck,
                      label: order.deliveryMethod == 'pickup'
                          ? AppLocalizations.of(context)!.printOrderPickup
                          : AppLocalizations.of(context)!.printOrderShipping,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(order.createdAt),
                      style: TextStyle(
                        fontSize: 13,
                        color: MBETheme.neutralGray,
                      ),
                    ),
                    Text(
                      '\$${order.total}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: MBETheme.lightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: MBETheme.neutralGray),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
            Iconsax.document_text,
            size: 80,
            color: MBETheme.neutralGray.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.printOrderNoOrders,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.printOrderCreateFirst,
            style: TextStyle(color: MBETheme.neutralGray),
          ),
        ],
      ),
    );
  }
}
