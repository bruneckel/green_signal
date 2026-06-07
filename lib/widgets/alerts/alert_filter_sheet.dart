import 'package:flutter/material.dart';

import '../../core/constants/alert_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/alert_item.dart';

Future<AlertTab?> showAlertFilterSheet(
  BuildContext context, {
  required AlertTab selectedTab,
  required Map<AlertTab, int> counts,
}) {
  return showModalBottomSheet<AlertTab>(
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.lg,
            AppSpacing.screenHorizontal,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AlertStrings.filterSheetTitle,
                style: AppTypography.sectionTitle,
              ),
              const SizedBox(height: AppSpacing.md),
              ...AlertTab.values.map((tab) {
                final isSelected = tab == selectedTab;
                final count = counts[tab] ?? 0;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    tab.label,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$count',
                        style: AppTypography.bodySecondary.copyWith(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                    ],
                  ),
                  onTap: () => Navigator.of(context).pop(tab),
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}
