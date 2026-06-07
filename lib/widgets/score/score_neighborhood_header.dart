import 'package:flutter/material.dart';

import '../../core/constants/score_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class ScoreNeighborhoodHeader extends StatelessWidget {
  const ScoreNeighborhoodHeader({
    super.key,
    required this.neighborhood,
    required this.city,
  });

  final String neighborhood;
  final String city;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: AppTypography.sectionTitle.copyWith(
              color: AppColors.textPrimary,
            ),
            children: [
              TextSpan(
                text: '${ScoreStrings.neighborhoodPrefix} ',
                style: AppTypography.bodySecondary.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(text: neighborhood),
            ],
          ),
        ),
        if (city.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            city,
            style: AppTypography.bodySecondary.copyWith(fontSize: 14),
          ),
        ],
      ],
    );
  }
}
