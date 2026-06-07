import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/score_strings.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/form_utils.dart';

class ScoreScreenHeader extends StatelessWidget {
  const ScoreScreenHeader({super.key});

  static const _iconButtonSize = 32.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const SizedBox(width: _iconButtonSize),
          const Expanded(
            child: Text(
              ScoreStrings.screenTitle,
              textAlign: TextAlign.center,
              style: AppTypography.appBarTitle,
            ),
          ),
          InkWell(
            onTap: () =>
                showAppSnackBar(context, AppStrings.featureComingSoon),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.filter_list, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
