import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class InlineErrorBanner extends StatelessWidget {
  const InlineErrorBanner({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTypography.bodySecondary.copyWith(
          color: AppColors.riskHigh,
          fontSize: 13,
        ),
      ),
    );
  }
}
