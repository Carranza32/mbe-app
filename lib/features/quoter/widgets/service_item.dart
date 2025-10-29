import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';

class ServiceItem extends StatelessWidget {
  final String title;
  final String price;
  final bool showInfo;

  const ServiceItem({
    super.key,
    required this.title,
    required this.price,
    this.showInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (showInfo) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}