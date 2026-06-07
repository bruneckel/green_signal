import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/community_report.dart';

class CommunityFilterChips extends StatelessWidget {
  const CommunityFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final CommunityFilter selectedFilter;
  final ValueChanged<CommunityFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Row(
        children: CommunityFilter.values.map((filter) {
          final isSelected = filter == selectedFilter;
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
                onTap: () => onFilterChanged(filter),
                customBorder: const StadiumBorder(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Text(
                    filter.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected ? Colors.white : AppColors.textPrimary,
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
