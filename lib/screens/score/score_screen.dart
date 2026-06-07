import 'package:flutter/material.dart';

import '../../core/constants/score_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/neighborhood_score_data.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/environment/environmental_repository.dart';
import '../../services/environment/location_resolver.dart';
import '../../services/environment/snapshot_presentation.dart';
import '../../widgets/home/risk_score_card.dart';
import '../../widgets/score/environmental_indicators_list.dart';
import '../../widgets/score/score_screen_header.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({
    super.key,
    required this.authRepository,
    required this.environmentalRepository,
    required this.locationResolver,
  });

  final AuthRepository authRepository;
  final EnvironmentalRepository environmentalRepository;
  final LocationResolver locationResolver;

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  bool _isLoading = true;
  NeighborhoodScoreData? _data;

  @override
  void initState() {
    super.initState();
    _loadSnapshot();
  }

  Future<void> _loadSnapshot() async {
    setState(() => _isLoading = true);

    final location = await widget.locationResolver.resolve(
      widget.authRepository,
    );
    final snapshot = await widget.environmentalRepository.fetchSnapshot(
      point: location.position,
      locationLabel: location.label,
    );

    if (!mounted) return;

    setState(() {
      _data = SnapshotPresentation.toNeighborhoodScoreData(
        snapshot: snapshot,
        location: location,
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = _data ?? NeighborhoodScoreData.mock;

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
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xxl),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else ...[
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
