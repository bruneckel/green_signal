import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/home_strings.dart';
import '../../router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/home_data.dart';
import 'section_header.dart';

class IndicatorsSection extends StatelessWidget {
  const IndicatorsSection({super.key, required this.indicators});

  final List<IndicatorItem> indicators;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: HomeStrings.indicators,
          showViewAll: true,
          onViewAllTap: () => context.go(AppRoutes.score),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: AppSpacing.indicatorListHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: indicators.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              return _IndicatorCard(item: indicators[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _IndicatorCard extends StatelessWidget {
  const _IndicatorCard({required this.item});

  final IndicatorItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.indicatorCardWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: AppColors.textSecondary, size: 26),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySecondary.copyWith(
              fontSize: 13,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
