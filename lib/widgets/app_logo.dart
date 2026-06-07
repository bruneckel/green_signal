import 'package:flutter/material.dart';

import '../core/constants/assets.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = AppSpacing.logoSize,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      Assets.logo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          _LogoPlaceholder(size: size),
    );
  }
}

class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.eco_outlined,
        size: size * 0.5,
        color: AppColors.primaryGreen,
      ),
    );
  }
}
