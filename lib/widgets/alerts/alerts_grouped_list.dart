import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/alert_item.dart';
import '../../services/alerts/alert_presentation.dart';
import 'alert_card.dart';

class AlertsGroupedList extends StatelessWidget {
  const AlertsGroupedList({
    super.key,
    required this.alerts,
  });

  final List<AlertItem> alerts;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
      ),
      children: [
        for (final tab in AlertTab.categories) ...[
          Text(
            tab.label,
            style: AppTypography.sectionTitle.copyWith(fontSize: 15),
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._sectionContent(tab),
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }

  List<Widget> _sectionContent(AlertTab tab) {
    final sectionAlerts = alerts.where((alert) => alert.tab == tab).toList();
    if (sectionAlerts.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(
            AlertPresentation.sectionEmptyMessageFor(tab),
            style: AppTypography.bodySecondary.copyWith(fontSize: 13),
          ),
        ),
      ];
    }

    return [
      for (var i = 0; i < sectionAlerts.length; i++) ...[
        if (i > 0) const SizedBox(height: AppSpacing.sm),
        AlertCard(alert: sectionAlerts[i]),
      ],
    ];
  }
}
