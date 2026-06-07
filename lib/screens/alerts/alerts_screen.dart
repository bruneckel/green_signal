import 'package:flutter/material.dart';

import '../../core/constants/alert_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/alert_item.dart';
import '../../services/alerts/alerts_repository.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/environment/environmental_repository.dart';
import '../../services/environment/location_resolver.dart';
import '../../widgets/alerts/alert_card.dart';
import '../../widgets/alerts/alert_filter_chips.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({
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
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  AlertTab _selectedTab = AlertTab.active;
  bool _isLoading = true;
  bool _inmetHasError = false;
  List<AlertItem> _alerts = const [];
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    widget.authRepository.addListener(_onAuthChanged);
    _loadAlerts();
  }

  @override
  void dispose() {
    widget.authRepository.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() => _loadAlerts();

  Future<void> _loadAlerts() async {
    final generation = ++_loadGeneration;
    final isInitialLoad = _alerts.isEmpty;

    if (isInitialLoad) {
      setState(() => _isLoading = true);
    }

    final location = await widget.locationResolver.resolve(
      widget.authRepository,
    );
    final snapshot = await widget.environmentalRepository.fetchSnapshot(
      point: location.position,
      locationLabel: location.label,
    );
    final result = await widget.alertsRepository.fetchAlerts(
      location: location,
      snapshot: snapshot,
    );

    if (!mounted || generation != _loadGeneration) return;

    setState(() {
      _alerts = result.alerts;
      _inmetHasError = result.inmetHasError;
      _isLoading = false;
    });

    if (result.inmetHasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AlertStrings.inmetLoadError)),
      );
    }
  }

  List<AlertItem> get _filteredAlerts =>
      _alerts.where((alert) => alert.tab == _selectedTab).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredAlerts;

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.md),
            const Text(
              AlertStrings.screenTitle,
              textAlign: TextAlign.center,
              style: AppTypography.appBarTitle,
            ),
            const SizedBox(height: AppSpacing.md),
            AlertFilterChips(
              selectedTab: _selectedTab,
              onTabChanged: (tab) => setState(() => _selectedTab = tab),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadAlerts,
                child: _isLoading && _alerts.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          Center(child: CircularProgressIndicator()),
                        ],
                      )
                    : filtered.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: 120,
                                child: Center(
                                  child: Text(
                                    AlertStrings.emptyList,
                                    style: AppTypography.bodySecondary.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.screenHorizontal,
                              0,
                              AppSpacing.screenHorizontal,
                              AppSpacing.lg,
                            ),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              return AlertCard(alert: filtered[index]);
                            },
                          ),
              ),
            ),
            if (_inmetHasError && _alerts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  0,
                  AppSpacing.screenHorizontal,
                  AppSpacing.sm,
                ),
                child: Text(
                  AlertStrings.inmetLoadError,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySecondary.copyWith(
                    color: AppColors.riskHigh,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
