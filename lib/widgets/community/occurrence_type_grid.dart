import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/community_report.dart';

class OccurrenceTypeGrid extends StatelessWidget {
  const OccurrenceTypeGrid({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final ReportCategory? selectedCategory;
  final ValueChanged<ReportCategory> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < newReportCategories.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _OccurrenceTile(
              category: newReportCategories[i],
              isSelected: newReportCategories[i] == selectedCategory,
              onTap: () => onCategorySelected(newReportCategories[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _OccurrenceTile extends StatelessWidget {
  const _OccurrenceTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final ReportCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          side: BorderSide(
            color: isSelected ? AppColors.primaryGreen : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category.icon,
                  size: 22,
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.textSecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  category.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
