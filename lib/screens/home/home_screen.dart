import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/home_data.dart';
import '../../widgets/home/active_alerts_section.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/home/indicators_section.dart';
import '../../widgets/home/risk_score_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.data = HomeData.mock});

  final HomeData data;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceMuted,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              HomeHeader(city: data.city),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.sectionGap),
                    RiskScoreCard(
                      riskScore: data.riskScore,
                      riskLevel: data.riskLevel,
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    ActiveAlertsSection(alerts: data.alerts),
                    const SizedBox(height: AppSpacing.sectionGap),
                    IndicatorsSection(indicators: data.indicators),
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
