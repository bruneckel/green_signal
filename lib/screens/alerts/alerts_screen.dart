import 'package:flutter/material.dart';

import '../../core/constants/alert_strings.dart';
import '../../core/utils/form_utils.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/alert_item.dart';
import '../../services/alerts/alert_presentation.dart';
import '../../services/alerts/alerts_repository.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/environment/environmental_repository.dart';
import '../../services/environment/unified_location_resolver.dart';
import '../../widgets/alerts/alert_filter_sheet.dart';
import '../../widgets/alerts/alerts_list_content.dart';
import '../../widgets/shared/header_icon_button.dart';
import '../../widgets/shared/inline_error_banner.dart';
import '../../widgets/shell/tab_screen_header.dart';
import '../../widgets/shell/tab_screen_scaffold.dart';

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
  final UnifiedLocationResolver locationResolver;
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
    widget.locationResolver.addListener(_onLocationChanged);
    _loadAlerts();
  }

  @override
  void dispose() {
    widget.authRepository.removeListener(_onAuthChanged);
    widget.locationResolver.removeListener(_onLocationChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    widget.locationResolver.loadOverridesForUser(widget.authRepository);
    _loadAlerts();
  }

  void _onLocationChanged() => _loadAlerts();

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
      showAppSnackBar(
        context,
        AlertStrings.inmetLoadError,
        type: AppSnackBarType.error,
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

  @override
  Widget build(BuildContext context) {
    final filteredCount = _filteredAlerts.length;

    return TabScreenScaffold(
      backgroundColor: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          TabScreenHeader(
            title: AlertStrings.screenTitle,
            trailing: HeaderIconButton(
              icon: Icons.tune,
              onPressed: _openFilterSheet,
            ),
          ),
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
              child: AlertsListContent(
                isLoading: _isLoading,
                alerts: _alerts,
                selectedTab: _selectedTab,
              ),
            ),
          ),
          if (_inmetHasError && _alerts.isNotEmpty)
            InlineErrorBanner(message: AlertStrings.inmetLoadError),
        ],
      ),
    );
  }
}
