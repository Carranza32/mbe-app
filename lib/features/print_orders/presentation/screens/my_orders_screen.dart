// lib/features/print_orders/presentation/screens/my_orders_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/models/print_order_model.dart';
import '../../providers/orders_provider.dart';
import 'order_detail_screen.dart';

class MyOrdersScreen extends HookConsumerWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      drawer: _AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'Mis Pedidos',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add_circle),
            onPressed: () => context.push('/print-orders/create'),
          ),
        ],
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
                child: const Text('Reintentar'),
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
                      label: '${order.pagesCount} págs',
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: order.deliveryMethod == 'pickup'
                          ? Iconsax.shop
                          : Iconsax.truck,
                      label: order.deliveryMethod == 'pickup'
                          ? 'Recoger'
                          : 'Envío',
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
          const Text(
            'No tienes pedidos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer pedido de impresión',
            style: TextStyle(color: MBETheme.neutralGray),
          ),
        ],
      ),
    );
  }
}

// Widget del Drawer
class _AppDrawer extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final authState = ref.watch(authProvider);
    // final user = authState.value;

    final secureStorage = ref.read(secureStorageProvider);
    final userFuture = useMemoized(() => secureStorage.read(key: 'user'));
    final userSnapshot = useFuture(userFuture);

    Map<String, dynamic>? userData;
    if (userSnapshot.hasData && userSnapshot.data != null) {
      try {
        userData = jsonDecode(userSnapshot.data!);
      } catch (e) {
        print('Error al decodificar usuario: $e');
      }
    }

    final name = userData?['name'] ?? 'Usuario';
    final email = userData?['email'] ?? '';

    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: const BoxDecoration(color: MBETheme.brandBlack),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.user,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name ?? 'Usuario',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerItem(
                  icon: Iconsax.document_text,
                  title: 'Mis Pedidos',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _DrawerItem(
                  icon: Iconsax.user,
                  title: 'Mi Perfil',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navegar a perfil
                  },
                ),
                const Divider(),
                _DrawerItem(
                  icon: Iconsax.setting_2,
                  title: 'Configuración',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navegar a settings
                  },
                ),
              ],
            ),
          ),

          // Logout
          const Divider(height: 1),
          _DrawerItem(
            icon: Iconsax.logout,
            title: 'Cerrar Sesión',
            isDestructive: true,
            onTap: () async {
              Navigator.pop(context);

              // Mostrar confirmación
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Estás seguro que deseas salir?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: MBETheme.brandRed,
                      ),
                      child: const Text('Salir'),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;

              // Ejecutar logout (ya maneja errores internamente)
              await ref.read(authProvider.notifier).logout();

              // Navegar a login si el contexto sigue montado
              if (context.mounted) {
                context.go('/auth/login');
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? MBETheme.brandRed : MBETheme.neutralGray,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? MBETheme.brandRed : MBETheme.brandBlack,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
