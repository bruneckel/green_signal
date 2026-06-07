import 'package:flutter/material.dart';

import '../../core/constants/score_strings.dart';
import '../../core/theme/app_typography.dart';

class ScoreScreenHeader extends StatelessWidget {
  const ScoreScreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        ScoreStrings.screenTitle,
        textAlign: TextAlign.center,
        style: AppTypography.appBarTitle,
      ),
    );
  }
}
