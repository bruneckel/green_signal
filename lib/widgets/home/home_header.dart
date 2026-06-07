import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/form_utils.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.city});

  final String city;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          child: Row(
            children: [
              _HeaderIconButton(
                icon: Icons.menu,
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
              const Expanded(
                child: Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: AppTypography.appBarTitle,
                ),
              ),
              _HeaderIconButton(
                icon: Icons.notifications_outlined,
                onPressed: () =>
                    showAppSnackBar(context, AppStrings.featureComingSoon),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: () =>
              showAppSnackBar(context, AppStrings.featureComingSoon),
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: Color(0xFF757575),
              ),
              const SizedBox(width: 4),
              Text(
                city,
                style: AppTypography.bodySecondary.copyWith(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: Color(0xFF757575),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 24),
      ),
    );
  }
}
