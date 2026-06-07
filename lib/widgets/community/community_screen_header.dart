import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/community_strings.dart';
import '../../core/theme/app_typography.dart';
import '../../router/app_router.dart';

class CommunityScreenHeader extends StatelessWidget {
  const CommunityScreenHeader({super.key});

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
              CommunityStrings.screenTitle,
              textAlign: TextAlign.center,
              style: AppTypography.appBarTitle,
            ),
          ),
          InkWell(
            onTap: () => context.push(AppRoutes.communityNewReport),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.add_circle_outline, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
