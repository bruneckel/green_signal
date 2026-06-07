import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../home/app_section_card.dart';
import 'skeleton.dart';

class RiskScoreCardSkeleton extends StatelessWidget {
  const RiskScoreCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 180, height: 18),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SkeletonCircle(size: 120),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBox(height: 12),
                    const SizedBox(height: AppSpacing.md),
                    const SkeletonBox(width: 120, height: 12),
                    const SizedBox(height: AppSpacing.md),
                    const SkeletonBox(width: 100, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class IndicatorsSectionSkeleton extends StatelessWidget {
  const IndicatorsSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBox(width: 120, height: 18),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: AppSpacing.indicatorListHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (_, __) => const _IndicatorCardSkeleton(),
          ),
        ),
      ],
    );
  }
}

class ActiveAlertsSectionSkeleton extends StatelessWidget {
  const ActiveAlertsSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 140, height: 18),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < 2; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            const _AlertRowSkeleton(),
          ],
        ],
      ),
    );
  }
}

class _IndicatorCardSkeleton extends StatelessWidget {
  const _IndicatorCardSkeleton();

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
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SkeletonCircle(size: 26),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(width: 72, height: 12),
          SizedBox(height: AppSpacing.xs),
          SkeletonBox(width: 56, height: 12),
        ],
      ),
    );
  }
}

class _AlertRowSkeleton extends StatelessWidget {
  const _AlertRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SkeletonCircle(size: 36),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 160, height: 14),
              SizedBox(height: AppSpacing.xs),
              SkeletonBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

class AlertCardSkeleton extends StatelessWidget {
  const AlertCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonCircle(size: 28),
              SizedBox(width: AppSpacing.sm),
              SkeletonBox(width: 80, height: 12),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(width: double.infinity, height: 16),
          SizedBox(height: AppSpacing.xs),
          SkeletonBox(height: 12),
          SizedBox(height: AppSpacing.xs),
          SkeletonBox(width: 220, height: 12),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(width: 140, height: 12),
        ],
      ),
    );
  }
}

class ScoreIndicatorsSkeleton extends StatelessWidget {
  const ScoreIndicatorsSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < itemCount; i++) ...[
          if (i > 0) const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                const SkeletonCircle(size: 22),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(child: SkeletonBox(height: 14)),
                const SizedBox(width: AppSpacing.md),
                const SkeletonBox(width: 48, height: 14),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class MapAreaSkeleton extends StatelessWidget {
  const MapAreaSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          child: const SkeletonBox(
            width: double.infinity,
            height: double.infinity,
            borderRadius: AppSpacing.borderRadius,
          ),
        ),
      ),
    );
  }
}

class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonPulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RiskScoreCardSkeleton(),
          SizedBox(height: AppSpacing.sectionGap),
          ActiveAlertsSectionSkeleton(),
          SizedBox(height: AppSpacing.sectionGap),
          IndicatorsSectionSkeleton(),
        ],
      ),
    );
  }
}

class ScoreScreenSkeleton extends StatelessWidget {
  const ScoreScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonPulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 220, height: 20),
          SizedBox(height: AppSpacing.xs),
          SkeletonBox(width: 140, height: 14),
          SizedBox(height: AppSpacing.lg),
          RiskScoreCardSkeleton(),
          SizedBox(height: AppSpacing.lg),
          SkeletonBox(width: 160, height: 18),
          SizedBox(height: AppSpacing.sm),
          ScoreIndicatorsSkeleton(),
        ],
      ),
    );
  }
}

class AlertsListSkeleton extends StatelessWidget {
  const AlertsListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.lg,
          AppSpacing.screenHorizontal,
          AppSpacing.lg,
        ),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, __) => const AlertCardSkeleton(),
      ),
    );
  }
}
