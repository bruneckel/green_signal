import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/environmental_snapshot.dart';
import '../../models/home_data.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/environment/environmental_repository.dart';
import '../../services/environment/location_resolver.dart';
import '../../services/environment/snapshot_presentation.dart';
import '../../widgets/home/active_alerts_section.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/home/indicators_section.dart';
import '../../widgets/home/risk_score_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.authRepository,
    required this.environmentalRepository,
    required this.locationResolver,
  });

  final AuthRepository authRepository;
  final EnvironmentalRepository environmentalRepository;
  final LocationResolver locationResolver;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  EnvironmentalSnapshot? _snapshot;
  ResolvedLocation? _location;

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
      _location = location;
      _snapshot = snapshot;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final locationLabel = _location?.label ?? HomeData.mock.city;

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
              HomeHeader(city: locationLabel),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.sectionGap),
                    if (_isLoading || snapshot == null)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xxl),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else ...[
                      RiskScoreCard(
                        riskScore: snapshot.riskScore,
                        riskLevel: snapshot.riskLevel,
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      ActiveAlertsSection(alerts: HomeData.mock.alerts),
                      const SizedBox(height: AppSpacing.sectionGap),
                      IndicatorsSection(
                        indicators: SnapshotPresentation.toHomeIndicators(
                          snapshot,
                        ),
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
