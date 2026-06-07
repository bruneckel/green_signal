import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/form_utils.dart';

class CommunityLocationSelector extends StatelessWidget {
  const CommunityLocationSelector({
    super.key,
    this.city = 'São Paulo, SP',
  });

  final String city;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showAppSnackBar(context, AppStrings.featureComingSoon),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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
    );
  }
}
