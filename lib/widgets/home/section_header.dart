import 'package:flutter/material.dart';

import '../../core/constants/home_strings.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/form_utils.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.showViewAll = false,
  });

  final String title;
  final bool showViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTypography.sectionTitle)),
        if (showViewAll)
          GestureDetector(
            onTap: () =>
                showAppSnackBar(context, HomeStrings.comingSoon),
            child: const Text(
              HomeStrings.viewAll,
              style: AppTypography.viewAll,
            ),
          ),
      ],
    );
  }
}
