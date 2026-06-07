import 'package:flutter/material.dart';

import '../../core/constants/home_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/home_data.dart';
import 'app_section_card.dart';
import 'risk_gauge.dart';

class RiskScoreCard extends StatelessWidget {
  const RiskScoreCard({
    super.key,
    required this.riskScore,
    required this.riskLevel,
  });

  final int riskScore;
  final RiskLevel riskLevel;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            HomeStrings.environmentalRiskScore,
            style: AppTypography.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final stackVertically = constraints.maxWidth < 360;

              if (stackVertically) {
                return Column(
                  children: [
                    RiskGauge(score: riskScore, riskLevel: riskLevel),
                    const SizedBox(height: AppSpacing.lg),
                    const _RiskLegend(),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RiskGauge(score: riskScore, riskLevel: riskLevel),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(child: _RiskLegend()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RiskLegend extends StatelessWidget {
  const _RiskLegend();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LegendItem(color: AppColors.riskLow, label: HomeStrings.riskLowRange),
        SizedBox(height: AppSpacing.md),
        _LegendItem(
          color: AppColors.riskMedium,
          label: HomeStrings.riskMediumRange,
        ),
        SizedBox(height: AppSpacing.md),
        _LegendItem(color: AppColors.riskHigh, label: HomeStrings.riskHighRange),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySecondary.copyWith(fontSize: 13),
          ),
        ),
      ],
    );
  }
}
