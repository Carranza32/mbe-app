import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../data/models/package_status.dart';
import '../../providers/admin_pre_alerts_provider.dart';

class StatusFilterChips extends ConsumerWidget {
  final PackageStatus? selectedStatus;
  final Function(PackageStatus?) onStatusSelected;

  const StatusFilterChips({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsState = ref.watch(adminPreAlertsProvider);
    final allAlerts = alertsState.value ?? [];

    final statusCounts = {
      for (var status in PackageStatus.values)
        status: allAlerts.where((a) => a.status == status).length,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _FilterChip(
            label: 'Todos',
            count: allAlerts.length,
            isSelected: selectedStatus == null,
            onTap: () => onStatusSelected(null),
          ),
          const SizedBox(width: 8),
          ...PackageStatus.values.map((status) {
            final count = statusCounts[status] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: status.label,
                count: count,
                isSelected: selectedStatus == status,
                onTap: () => onStatusSelected(status),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? MBETheme.brandBlack 
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected 
                ? MBETheme.brandBlack 
                : MBETheme.neutralGray.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: isSelected ? MBETheme.shadowMd : MBETheme.shadowSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? Colors.white : MBETheme.brandBlack,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white.withValues(alpha: 0.2)
                      : MBETheme.brandBlack.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected ? Colors.white : MBETheme.brandBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

