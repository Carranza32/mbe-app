import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../core/design_system/ds_badges.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../data/models/admin_pre_alert_model.dart';
import '../../data/models/package_status.dart';
import '../../providers/package_selection_provider.dart';

class PackageListItem extends ConsumerWidget {
  final AdminPreAlert package;
  final VoidCallback? onTap;

  const PackageListItem({
    super.key,
    required this.package,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSelected = ref.watch(
      packageSelectionProvider.select((state) => state.contains(package.id)),
    );
    final selectionNotifier = ref.read(packageSelectionProvider.notifier);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? MBETheme.brandBlack 
                : MBETheme.neutralGray.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? MBETheme.shadowMd : MBETheme.shadowSm,
        ),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => selectionNotifier.toggleSelection(package.id),
              activeColor: MBETheme.brandBlack,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '#${package.trackingNumber}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _StatusBadge(status: package.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Iconsax.code,
                        size: 14,
                        color: MBETheme.neutralGray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        package.eboxCode,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: MBETheme.neutralGray,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Iconsax.user,
                        size: 14,
                        color: MBETheme.neutralGray,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          package.clientName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: MBETheme.neutralGray,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          package.provider,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${NumberFormat('#,##0.00').format(package.total)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: MBETheme.brandBlack,
                        ),
                      ),
                    ],
                  ),
                  if (package.deliveryMethod != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Método: ${package.deliveryMethod}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: MBETheme.neutralGray,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PackageStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case PackageStatus.pendingConfirmation:
        return DSBadge.warning(label: status.label);
      case PackageStatus.readyToExport:
        return DSBadge.info(label: status.label);
      case PackageStatus.delivery:
        return DSBadge.success(label: status.label);
      case PackageStatus.pickup:
        return DSBadge.info(label: status.label);
      case PackageStatus.exported:
        return DSBadge.neutral(label: status.label);
    }
  }
}

