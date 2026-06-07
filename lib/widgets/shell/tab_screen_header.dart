import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../shared/header_icon_button.dart';

class TabScreenHeader extends StatelessWidget {
  const TabScreenHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  static const _slotSize = 32.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Row(
        children: [
          SizedBox(
            width: _slotSize,
            height: _slotSize,
            child: HeaderIconButton(
              icon: Icons.menu,
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.appBarTitle,
            ),
          ),
          SizedBox(
            width: _slotSize,
            height: _slotSize,
            child: trailing,
          ),
        ],
      ),
    );
  }
}
