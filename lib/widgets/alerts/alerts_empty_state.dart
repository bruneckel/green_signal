import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/alert_item.dart';
import '../../services/alerts/alert_presentation.dart';

class AlertsEmptyState extends StatelessWidget {
  const AlertsEmptyState({
    super.key,
    required this.tab,
  });

  final AlertTab tab;

  @override
  Widget build(BuildContext context) {
    final isPeaceful = tab == AlertTab.all;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPeaceful
                ? Icons.check_circle_outline
                : Icons.notifications_none_outlined,
            size: 48,
            color: isPeaceful ? AppColors.primaryGreen : AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AlertPresentation.emptyMessageFor(tab),
            textAlign: TextAlign.center,
            style: AppTypography.bodySecondary.copyWith(
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
