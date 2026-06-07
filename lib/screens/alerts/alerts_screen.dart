import 'package:flutter/material.dart';

import '../../core/constants/alert_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/alert_item.dart';
import '../../widgets/alerts/alert_card.dart';
import '../../widgets/alerts/alert_filter_chips.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key, this.alerts = AlertsData.mock});

  final List<AlertItem> alerts;

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  AlertTab _selectedTab = AlertTab.active;

  List<AlertItem> get _filteredAlerts =>
      widget.alerts.where((alert) => alert.tab == _selectedTab).toList();

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
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        AlertStrings.emptyList,
                        style: AppTypography.bodySecondary.copyWith(
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.separated(
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
          ],
        ),
      ),
    );
  }
}
