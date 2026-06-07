import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const TextStyle splashTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryDark,
  );

  static const TextStyle splashTagline = TextStyle(
    fontSize: 15,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle authTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle authSubtitle = TextStyle(
    fontSize: 15,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle link = TextStyle(
    color: AppColors.primaryGreen,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodySecondary = TextStyle(
    color: AppColors.textSecondary,
  );
}
