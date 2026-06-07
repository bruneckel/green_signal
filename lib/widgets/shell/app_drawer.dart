import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../router/app_router.dart';
import '../../services/auth/auth_repository.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.authRepository});

  final AuthRepository authRepository;

  void _closeDrawer(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _onProfileTap(BuildContext context) {
    _closeDrawer(context);
    context.push(AppRoutes.profile);
  }

  Future<void> _onLogoutTap(BuildContext context) async {
    _closeDrawer(context);
    await authRepository.logout();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.viewPaddingOf(context).top;
    final user = authRepository.currentUser;

    return Drawer(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
            SizedBox(height: topInset),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor:
                        AppColors.primaryGreen.withValues(alpha: 0.15),
                    child: const Icon(
                      Icons.person,
                      size: 36,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    user?.name ?? '—',
                    style: AppTypography.authTitle.copyWith(
                      fontSize: 20,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '—',
                    style: AppTypography.bodySecondary.copyWith(height: 1.2),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text(AppStrings.profile),
              onTap: () => _onProfileTap(context),
            ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.riskHigh),
              title: const Text(
                AppStrings.logout,
                style: TextStyle(color: AppColors.riskHigh),
              ),
              onTap: () => _onLogoutTap(context),
            ),
            SizedBox(
              height: MediaQuery.viewPaddingOf(context).bottom + AppSpacing.sm,
            ),
        ],
      ),
    );
  }
}
