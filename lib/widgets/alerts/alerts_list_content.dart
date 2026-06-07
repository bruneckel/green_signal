import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/alert_item.dart';
import '../../services/alerts/alert_presentation.dart';
import '../../widgets/alerts/alert_card.dart';
import '../../widgets/alerts/alerts_empty_state.dart';
import '../../widgets/alerts/alerts_grouped_list.dart';
import '../../widgets/shared/screen_loading_indicator.dart';

class AlertsListContent extends StatelessWidget {
  const AlertsListContent({
    super.key,
    required this.isLoading,
    required this.alerts,
    required this.selectedTab,
  });

  final bool isLoading;
  final List<AlertItem> alerts;
  final AlertTab selectedTab;

  List<AlertItem> get _filteredAlerts =>
      AlertPresentation.filterByTab(alerts, selectedTab);

  @override
  Widget build(BuildContext context) {
    if (isLoading && alerts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          ScreenLoadingIndicator(),
        ],
      );
    }

    if (_filteredAlerts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          AlertsEmptyState(tab: selectedTab),
        ],
      );
    }

    if (selectedTab == AlertTab.all) {
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
}
