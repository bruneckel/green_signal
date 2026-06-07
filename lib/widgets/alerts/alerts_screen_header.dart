import 'package:flutter/material.dart';

import '../../core/constants/alert_strings.dart';
import '../../core/theme/app_typography.dart';

class AlertsScreenHeader extends StatelessWidget {
  const AlertsScreenHeader({
    super.key,
    required this.onFilterTap,
  });

  final VoidCallback onFilterTap;

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
              AlertStrings.screenTitle,
              textAlign: TextAlign.center,
              style: AppTypography.appBarTitle,
            ),
          ),
          InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.tune, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
