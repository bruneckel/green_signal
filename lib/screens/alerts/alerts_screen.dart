import 'package:flutter/material.dart';

import '../../core/constants/alert_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/alert_item.dart';
import '../../services/alerts/alert_presentation.dart';
import '../../services/alerts/alerts_repository.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/environment/environmental_repository.dart';
import '../../services/environment/location_resolver.dart';
import '../../widgets/alerts/alert_card.dart';
import '../../widgets/alerts/alert_filter_sheet.dart';
import '../../widgets/alerts/alerts_empty_state.dart';
import '../../widgets/alerts/alerts_grouped_list.dart';
import '../../widgets/alerts/alerts_screen_header.dart';

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
  AlertTab _selectedTab = AlertTab.all;
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

  Future<void> _openFilterSheet() async {
    final selected = await showAlertFilterSheet(
      context,
      selectedTab: _selectedTab,
      counts: AlertPresentation.countsByTab(_alerts),
    );
    if (selected != null && mounted) {
      setState(() => _selectedTab = selected);
    }
  }

  List<AlertItem> get _filteredAlerts =>
      AlertPresentation.filterByTab(_alerts, _selectedTab);

  Widget _buildAlertList() {
    if (_isLoading && _alerts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (_filteredAlerts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          AlertsEmptyState(tab: _selectedTab),
        ],
      );
    }

    if (_selectedTab == AlertTab.all) {
      return AlertsGroupedList(alerts: _filteredAlerts);
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
      ),
      itemCount: _filteredAlerts.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        return AlertCard(alert: _filteredAlerts[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredCount = _filteredAlerts.length;

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.md),
            AlertsScreenHeader(onFilterTap: _openFilterSheet),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AlertStrings.filterSummary(_selectedTab.label, filteredCount),
              textAlign: TextAlign.center,
              style: AppTypography.bodySecondary.copyWith(fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadAlerts,
                child: _buildAlertList(),
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
