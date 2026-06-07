import 'package:flutter/material.dart';

import '../../core/constants/score_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/neighborhood_score_data.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/environment/environmental_repository.dart';
import '../../services/environment/unified_location_resolver.dart';
import '../../services/environment/snapshot_presentation.dart';
import '../../widgets/home/risk_score_card.dart';
import '../../widgets/score/environmental_indicators_list.dart';
import '../../widgets/score/score_neighborhood_header.dart';
import '../../widgets/shared/screen_loading_indicator.dart';
import '../../widgets/shell/tab_screen_header.dart';
import '../../widgets/shell/tab_screen_scaffold.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({
    super.key,
    required this.authRepository,
    required this.environmentalRepository,
    required this.locationResolver,
  });

  final AuthRepository authRepository;
  final EnvironmentalRepository environmentalRepository;
  final UnifiedLocationResolver locationResolver;

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  bool _isLoading = true;
  NeighborhoodScoreData? _data;

  @override
  void initState() {
    super.initState();
    widget.authRepository.addListener(_onAuthChanged);
    widget.locationResolver.addListener(_onLocationChanged);
    _loadSnapshot();
  }

  @override
  void dispose() {
    widget.authRepository.removeListener(_onAuthChanged);
    widget.locationResolver.removeListener(_onLocationChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    widget.locationResolver.loadOverridesForUser(widget.authRepository);
    _loadSnapshot();
  }

  void _onLocationChanged() => _loadSnapshot();

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
    final user = widget.authRepository.currentUser;
    final neighborhood =
        _data?.neighborhood ?? user?.neighborhood ?? ScoreStrings.loadingLabel;
    final city = _data?.city ?? user?.profileLabel ?? '';

    return TabScreenScaffold(
      backgroundColor: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.md),
            const TabScreenHeader(title: ScoreStrings.screenTitle),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  ScoreNeighborhoodHeader(
                    neighborhood: neighborhood,
                    city: city,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (_isLoading || _data == null)
                    const ScreenLoadingIndicator()
                  else ...[
                    RiskScoreCard(
                      riskScore: _data!.riskScore,
                      riskLevel: _data!.riskLevel,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      ScoreStrings.indicatorsTitle,
                      style: AppTypography.sectionTitle,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    EnvironmentalIndicatorsList(
                      indicators: _data!.indicators,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
