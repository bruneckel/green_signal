import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/home_strings.dart';
import '../../router/app_router.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/home_data.dart';
import 'alert_tile.dart';
import 'app_section_card.dart';
import 'section_header.dart';

class ActiveAlertsSection extends StatelessWidget {
  const ActiveAlertsSection({super.key, required this.alerts});

  final List<ActiveAlert> alerts;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: HomeStrings.activeAlerts),
          const SizedBox(height: AppSpacing.lg),
          ...alerts.map(
            (alert) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AlertTile(alert: alert),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => context.go(AppRoutes.alerts),
              child: const Text(
                HomeStrings.viewAll,
                style: AppTypography.viewAll,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
