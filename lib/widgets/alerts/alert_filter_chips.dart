import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/alert_item.dart';

class AlertFilterChips extends StatelessWidget {
  const AlertFilterChips({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  final AlertTab selectedTab;
  final ValueChanged<AlertTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Row(
        children: AlertTab.values.map((tab) {
          final isSelected = tab == selectedTab;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Material(
              color: isSelected ? AppColors.textPrimary : AppColors.background,
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected ? AppColors.textPrimary : AppColors.border,
                ),
              ),
              child: InkWell(
                onTap: () => onTabChanged(tab),
                customBorder: const StadiumBorder(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Text(
                    tab.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
