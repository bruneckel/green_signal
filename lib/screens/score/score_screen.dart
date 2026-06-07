import 'package:flutter/material.dart';

import '../../core/constants/score_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/neighborhood_score_data.dart';
import '../../widgets/home/risk_score_card.dart';
import '../../widgets/score/environmental_indicators_list.dart';
import '../../widgets/score/score_screen_header.dart';

class ScoreScreen extends StatelessWidget {
  const ScoreScreen({super.key, this.data = NeighborhoodScoreData.mock});

  final NeighborhoodScoreData data;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              const ScoreScreenHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
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
                          TextSpan(text: data.neighborhood),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      data.city,
                      style: AppTypography.bodySecondary.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    RiskScoreCard(
                      riskScore: data.riskScore,
                      riskLevel: data.riskLevel,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      ScoreStrings.indicatorsTitle,
                      style: AppTypography.sectionTitle,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    EnvironmentalIndicatorsList(
                      indicators: data.indicators,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
