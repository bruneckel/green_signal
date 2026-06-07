import 'package:flutter/material.dart';

import '../../core/constants/home_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: AppTypography.authTitle),
            const SizedBox(height: 8),
            const Text(
              HomeStrings.comingSoon,
              style: AppTypography.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}
