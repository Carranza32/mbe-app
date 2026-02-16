// lib/features/print_orders/presentation/screens/order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:mbe_orders_app/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../data/models/print_order_detail.dart';
import '../../providers/order_detail_provider.dart';

class OrderDetailScreen extends HookConsumerWidget {
  final String orderNumber;

  const OrderDetailScreen({Key? key, required this.orderNumber}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderDetailProvider(orderNumber));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.printOrderDetailTitle,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: orderState.when(
        data: (order) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header con número y estado
              _HeaderCard(order: order),
              const SizedBox(height: 16),

              // Historial
              _HistoryCard(history: order.history),
              const SizedBox(height: 16),

              // Info en grid
              Column(
                children: [
                  _ContactCard(order: order),
                  const SizedBox(height: 12),
                  _DeliveryCard(order: order),
                ],
              ),
              const SizedBox(height: 16),

              Column(
                children: [
                  _ConfigCard(order: order),
                  const SizedBox(height: 12),
                  _FilesCard(pagesCount: order.pagesCount),
                ],
              ),
              const SizedBox(height: 16),

              // Total
              _TotalCard(order: order),
              const SizedBox(height: 16),

              // Ayuda
              _HelpCard(),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}

// Header Card
class _HeaderCard extends StatelessWidget {
  final PrintOrderDetail order;

  const _HeaderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderNumber,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: order.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: order.statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      order.statusLabel,
                      style: TextStyle(
                        color: order.statusColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// History Card
class _HistoryCard extends StatelessWidget {
  final List<OrderHistory> history;

  const _HistoryCard({required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.clock, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.printOrderHistory,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...history.map((h) => _HistoryItem(history: h)),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final OrderHistory history;

  const _HistoryItem({required this.history});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: MBETheme.lightGray,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(history.status),
              size: 16,
              color: MBETheme.neutralGray,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.statusLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  history.comment,
                  style: TextStyle(
                    fontSize: 13,
                    color: MBETheme.neutralGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(history.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: MBETheme.neutralGray.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String status) {
    switch (status) {
      case 'pending': return Iconsax.document;
      case 'printing': return Iconsax.printer;
      case 'ready': return Iconsax.tick_circle;
      case 'delivered': return Iconsax.truck;
      default: return Iconsax.info_circle;
    }
  }
}

// Contact Card
class _ContactCard extends StatelessWidget {
  final PrintOrderDetail order;

  const _ContactCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.user, size: 18),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.preAlertContact,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: AppLocalizations.of(context)!.preAlertName, value: order.customerName),
          _InfoRow(label: AppLocalizations.of(context)!.preAlertEmail, value: order.customerEmail),
          _InfoRow(label: AppLocalizations.of(context)!.preAlertPhone, value: order.customerPhone ?? ''),
        ],
      ),
    );
  }
}

// Delivery Card
class _DeliveryCard extends StatelessWidget {
  final PrintOrderDetail order;

  const _DeliveryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.truck, size: 18),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.preAlertDelivery,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: AppLocalizations.of(context)!.printOrderMethod, value: order.delivery.methodLabel),
          if (order.delivery.location != null)
            _InfoRow(label: AppLocalizations.of(context)!.printOrderLocation, value: order.delivery.location ?? ''),
        ],
      ),
    );
  }
}

// Config Card
class _ConfigCard extends StatelessWidget {
  final PrintOrderDetail order;

  const _ConfigCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.setting_2, size: 18),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.printOrderConfig,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: AppLocalizations.of(context)!.printOrderType, value: order.config.printTypeLabel),
          _InfoRow(label: AppLocalizations.of(context)!.printOrderSize, value: order.config.paperSizeLabel),
          _InfoRow(label: AppLocalizations.of(context)!.printOrderCopies, value: order.config.copies.toString()),
        ],
      ),
    );
  }
}

// Files Card
class _FilesCard extends StatelessWidget {
  final int pagesCount;

  const _FilesCard({required this.pagesCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.document_text, size: 18),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.printOrderFiles,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: AppLocalizations.of(context)!.printOrderPages, value: pagesCount.toString()),
        ],
      ),
    );
  }
}

// Total Card
class _TotalCard extends StatelessWidget {
  final PrintOrderDetail order;

  const _TotalCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MBETheme.brandBlack,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.printOrderTotalOrder,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppLocalizations.of(context)!.printOrderOrderDate,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                DateFormat('dd/MM/yyyy').format(order.createdAt),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Help Card
class _HelpCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.printOrderNeedHelp,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.printOrderHelpMessage,
            style: TextStyle(
              fontSize: 14,
              color: MBETheme.neutralGray,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Widget
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: MBETheme.neutralGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}