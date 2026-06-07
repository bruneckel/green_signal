import 'package:flutter/material.dart';

import '../../core/constants/location_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class HomeLocationBar extends StatelessWidget {
  const HomeLocationBar({
    super.key,
    required this.city,
    required this.isExploring,
    required this.onTap,
  });

  final String city;
  final bool isExploring;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        isExploring ? AppColors.primaryGreen : AppColors.textSecondary;

    return Column(
      children: [
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: iconColor,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  isExploring
                      ? '$city · ${LocationStrings.exploringSuffix}'
                      : city,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySecondary.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: iconColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
