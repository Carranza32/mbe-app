import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../data/models/locker_retrieval_model.dart';
import 'package:iconsax/iconsax.dart';

class LockerPickupListItem extends StatelessWidget {
  final LockerPickupItem item;
  final bool isPending;
  final VoidCallback? onTap;

  const LockerPickupListItem({
    super.key,
    required this.item,
    required this.isPending,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = item.createdAt != null
        ? _formatDate(item.createdAt!)
        : (item.deliveredAt != null
            ? 'Entregado: ${_formatDate(item.deliveredAt!)}'
            : '—');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isPending ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isPending
                      ? MBETheme.brandRed.withValues(alpha: 0.1)
                      : MBETheme.neutralGray.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Iconsax.box_1,
                  color: isPending ? MBETheme.brandRed : MBETheme.neutralGray,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.customerNameMasked,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: MBETheme.brandBlack,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Casillero ${item.physicalLockerCode}'
                          '${item.lockerCode != null ? ' · ${item.lockerCode}' : ''}',
                      style: TextStyle(
                        fontSize: 13,
                        color: MBETheme.neutralGray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 12,
                        color: MBETheme.neutralGray,
                      ),
                    ),
                    if (item.pieceCount > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '${item.pieceCount} piezas',
                          style: TextStyle(
                            fontSize: 12,
                            color: MBETheme.neutralGray,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isPending)
                Icon(
                  Iconsax.arrow_right_3,
                  color: MBETheme.brandRed,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('dd MMM, HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }
}
