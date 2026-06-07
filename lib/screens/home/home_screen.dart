import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/alerts_config.dart';
import '../../core/constants/home_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/environmental_snapshot.dart';
import '../../models/home_data.dart';
import '../../router/app_router.dart';
import '../../services/alerts/alert_presentation.dart';
import '../../services/alerts/alerts_repository.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/environment/environmental_repository.dart';
import '../../services/environment/location_resolver.dart';
import '../../services/environment/snapshot_presentation.dart';
import '../../widgets/home/active_alerts_section.dart';
import '../../widgets/home/home_location_bar.dart';
import '../../widgets/home/indicators_section.dart';
import '../../widgets/home/risk_score_card.dart';
import '../../widgets/shared/header_icon_button.dart';
import '../../widgets/shared/screen_loading_indicator.dart';
import '../../widgets/shell/tab_screen_header.dart';
import '../../widgets/shell/tab_screen_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.authRepository,
    required this.environmentalRepository,
    required this.locationResolver,
    required this.alertsRepository,
  });

  final AuthRepository authRepository;
  final EnvironmentalRepository environmentalRepository;
  final LocationResolver locationResolver;
  final AlertsRepository alertsRepository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  EnvironmentalSnapshot? _snapshot;
  ResolvedLocation? _location;
  List<ActiveAlert> _activeAlerts = const [];

  @override
  void initState() {
    super.initState();
    widget.authRepository.addListener(_onAuthChanged);
    _loadSnapshot();
  }

  @override
  void dispose() {
    widget.authRepository.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() => _loadSnapshot();

  Future<void> _loadSnapshot() async {
    setState(() => _isLoading = true);

    final location = await widget.locationResolver.resolve(
      widget.authRepository,
    );
    final snapshot = await widget.environmentalRepository.fetchSnapshot(
      point: location.position,
      locationLabel: location.label,
    );
    final alertsResult = await widget.alertsRepository.fetchAlerts(
      location: location,
      snapshot: snapshot,
    );

    if (!mounted) return;

    setState(() {
      _location = location;
      _snapshot = snapshot;
      _activeAlerts = AlertPresentation.toActiveAlerts(
        alertsResult.alerts,
        limit: AlertsConfig.homeActiveAlertsLimit,
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final locationLabel = _location?.label ?? HomeData.mock.city;

    return TabScreenScaffold(
      backgroundColor: AppColors.surfaceMuted,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            TabScreenHeader(
              title: HomeStrings.navHome,
              trailing: HeaderIconButton(
                icon: Icons.notifications_outlined,
                onPressed: () => context.go(AppRoutes.alerts),
              ),
            ),
            HomeLocationBar(city: locationLabel),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.sectionGap),
                  if (_isLoading || snapshot == null)
                    const ScreenLoadingIndicator()
                  else ...[
                    RiskScoreCard(
                      riskScore: snapshot.riskScore,
                      riskLevel: snapshot.riskLevel,
                    ),
                    if (_activeAlerts.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sectionGap),
                      ActiveAlertsSection(alerts: _activeAlerts),
                    ],
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
    );
  }
}
