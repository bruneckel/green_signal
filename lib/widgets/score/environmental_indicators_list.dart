import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/neighborhood_score_data.dart';

class EnvironmentalIndicatorsList extends StatelessWidget {
  const EnvironmentalIndicatorsList({
    super.key,
    required this.indicators,
  });

  final List<EnvironmentalIndicator> indicators;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < indicators.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: AppColors.border),
          _IndicatorRow(indicator: indicators[i]),
        ],
      ],
    );
  }
}

class _IndicatorRow extends StatelessWidget {
  const _IndicatorRow({required this.indicator});

  final EnvironmentalIndicator indicator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(
            indicator.icon,
            size: 22,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              indicator.label,
              style: AppTypography.bodySecondary.copyWith(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            indicator.value,
            style: AppTypography.bodySecondary.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
