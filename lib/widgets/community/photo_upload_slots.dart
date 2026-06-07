import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/form_utils.dart';

class PhotoUploadSlots extends StatelessWidget {
  const PhotoUploadSlots({super.key});

  static const _slotSize = 72.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PhotoSlot(
          icon: Icons.camera_alt_outlined,
          onTap: () => showAppSnackBar(context, AppStrings.featureComingSoon),
        ),
        const SizedBox(width: AppSpacing.sm),
        _PhotoSlot(
          icon: Icons.image_outlined,
          onTap: () => showAppSnackBar(context, AppStrings.featureComingSoon),
        ),
        const SizedBox(width: AppSpacing.sm),
        _PhotoSlot(
          icon: Icons.image_outlined,
          onTap: () => showAppSnackBar(context, AppStrings.featureComingSoon),
        ),
      ],
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceMuted,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        child: SizedBox(
          width: PhotoUploadSlots._slotSize,
          height: PhotoUploadSlots._slotSize,
          child: Icon(icon, color: AppColors.textSecondary, size: 28),
        ),
      ),
    );
  }
}
