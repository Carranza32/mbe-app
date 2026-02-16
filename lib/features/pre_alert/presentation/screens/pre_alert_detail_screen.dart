import 'package:flutter/material.dart';
import 'package:mbe_orders_app/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../data/models/pre_alert_detail_model.dart';
import '../../providers/pre_alert_detail_provider.dart';

class PreAlertDetailScreen extends ConsumerWidget {
  final String preAlertId;

  const PreAlertDetailScreen({Key? key, required this.preAlertId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(preAlertDetailProvider(preAlertId));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.preAlertDetailTitle,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: MBETheme.brandBlack,
          ),
        ),
      ),
      body: detailAsync.when(
        data: (detail) => _DetailContent(detail: detail),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Iconsax.warning_2,
                  size: 48,
                  color: MBETheme.brandRed,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.preAlertDetailLoadError,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(preAlertDetailProvider(preAlertId)),
                  icon: const Icon(Iconsax.refresh),
                  label: Text(l10n.preAlertRetry),
                  style: FilledButton.styleFrom(
                    backgroundColor: MBETheme.brandBlack,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final PreAlertDetail detail;

  const _DetailContent({required this.detail});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionCard(
            title: l10n.preAlertGeneralInfo,
            icon: Iconsax.document_text,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RowLabel(l10n.preAlertTrackingLabel, detail.trackNumber),
                if (detail.store != null)
                  _RowLabel(l10n.preAlertStoreLabel, detail.store!.name),
                if (detail.total != null)
                  _RowLabel(l10n.preAlertTotalLabel, '\$${detail.total!.toStringAsFixed(2)}'),
                if (detail.currentStatus != null)
                  _RowLabel(
                    l10n.preAlertStatus,
                    detail.currentStatus!.displayLabel,
                    valueColor: _statusColor(detail.currentStatus!.color),
                  ),
                if (detail.customer != null) ...[
                  _RowLabel(l10n.preAlertClient, detail.customer!.name),
                  if (detail.customer!.email != null)
                    _RowLabel(l10n.preAlertEmail, detail.customer!.email!),
                  if (detail.customer!.lockerCode != null &&
                      detail.customer!.lockerCode!.isNotEmpty)
                    _RowLabel(l10n.preAlertLocker, detail.customer!.lockerCode!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.preAlertProductsSection,
            icon: Iconsax.box,
            child: detail.products.isEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (detail.productCount != null)
                        Text(
                          l10n.preAlertProductCount(detail.productCount!),
                          style: TextStyle(color: MBETheme.neutralGray),
                        ),
                      if (detail.total != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${l10n.preAlertTotalLabel}: \$${detail.total!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                      if (detail.products.isEmpty &&
                          detail.productCount == null &&
                          detail.total == null)
                        Text(
                          l10n.preAlertNoProducts,
                          style: TextStyle(color: MBETheme.neutralGray),
                        ),
                    ],
                  )
                : Column(
                    children: [
                      for (final p in detail.products)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  p.name ?? l10n.preAlertProductDefault,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                '${p.quantity} × \$${p.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: MBETheme.neutralGray,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                            Text(
                            '${l10n.preAlertTotalLabel}: \$${_productsTotal(detail.products).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.preAlertContact,
            icon: Iconsax.profile_circle,
            child: detail.customer != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RowLabel(l10n.preAlertName, detail.customer!.name),
                      if (detail.customer!.email != null)
                        _RowLabel(l10n.preAlertEmail, detail.customer!.email!),
                      if (detail.customer!.phone != null)
                        _RowLabel(l10n.preAlertPhone, detail.customer!.phone!),
                    ],
                  )
                : Text(
                    l10n.preAlertNoContactData,
                    style: TextStyle(color: MBETheme.neutralGray),
                  ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.preAlertDelivery,
            icon: Iconsax.truck_fast,
            child: detail.customerAddress != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (detail.customerAddress!.name != null)
                        _RowLabel(l10n.preAlertName, detail.customerAddress!.name!),
                      _RowLabel(
                        l10n.preAlertAddress,
                        detail.customerAddress!.fullAddress.isNotEmpty
                            ? detail.customerAddress!.fullAddress
                            : '—',
                      ),
                      if (detail.customerAddress!.phone != null)
                        _RowLabel(l10n.preAlertPhone, detail.customerAddress!.phone!),
                    ],
                  )
                : Text(
                    l10n.preAlertNoDeliveryAddress,
                    style: TextStyle(color: MBETheme.neutralGray),
                  ),
          ),
          if (detail.statusHistory.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionCard(
              title: l10n.preAlertChangeHistory,
              icon: Iconsax.clock,
              child: Column(
                children: [
                  for (final h in detail.statusHistory)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: const BoxDecoration(
                              color: MBETheme.brandBlack,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (h.status != null)
                                  Text(
                                    h.status!.displayLabel,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (h.notes != null &&
                                    h.notes!.trim().isNotEmpty)
                                  Text(
                                    h.notes!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: MBETheme.neutralGray,
                                    ),
                                  ),
                                if (h.changedAt != null)
                                  Text(
                                    DateFormat('dd/MM/yyyy HH:mm')
                                        .format(h.changedAt!),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: MBETheme.neutralGray
                                          .withOpacity(0.8),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (detail.billInfo != null &&
              detail.billInfo!.name != null &&
              detail.billInfo!.url != null) ...[
            const SizedBox(height: 12),
            _SectionCard(
              title: l10n.preAlertDocument,
              icon: Iconsax.document,
              child: InkWell(
                onTap: () {
                  final uri = Uri.tryParse(detail.billInfo!.url!);
                  if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: MBETheme.lightGray,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Iconsax.document,
                        color: MBETheme.brandBlack,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.billInfo!.name!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (detail.billInfo!.size != null)
                            Text(
                              detail.billInfo!.size!,
                              style: TextStyle(
                                fontSize: 12,
                                color: MBETheme.neutralGray,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(
                      Iconsax.arrow_right_3,
                      size: 18,
                      color: MBETheme.neutralGray,
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (detail.paymentSummary != null) ...[
            const SizedBox(height: 12),
            _SectionCard(
              title: l10n.preAlertPayment,
              icon: Iconsax.dollar_circle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RowLabel(
                    l10n.preAlertStatus,
                    detail.paymentSummary!.isPaid ? l10n.preAlertPaid : l10n.preAlertPending,
                    valueColor:
                        detail.paymentSummary!.isPaid
                            ? const Color(0xFF10B981)
                            : MBETheme.neutralGray,
                  ),
                  if (detail.paymentSummary!.finalTotal != null)
                    _RowLabel(
                      l10n.preAlertTotalLabel,
                      '\$${detail.paymentSummary!.finalTotal!.toStringAsFixed(2)}',
                    ),
                  if (detail.paymentSummary!.lastPayment != null) ...[
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Text(
                      l10n.preAlertLastPayment,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: MBETheme.neutralGray,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${detail.paymentSummary!.lastPayment!.amount?.toStringAsFixed(2) ?? '—'} '
                      '${detail.paymentSummary!.lastPayment!.completedAt != null ? ' · ${DateFormat('dd/MM/yyyy').format(detail.paymentSummary!.lastPayment!.completedAt!)}' : ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  double _productsTotal(List<PreAlertDetailProduct> products) {
    return products.fold(0.0, (s, p) => s + (p.quantity * p.price));
  }

  Color _statusColor(String? color) {
    if (color == null) return MBETheme.neutralGray;
    final hex = color.replaceAll('#', '');
    if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    return MBETheme.neutralGray;
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: MBETheme.brandBlack),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _RowLabel extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _RowLabel(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                color: MBETheme.neutralGray,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: valueColor ?? MBETheme.brandBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
