import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../router/app_router.dart';
import '../../widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _splashDuration = Duration(milliseconds: 2500);

  Timer? _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_splashDuration, _goToLogin);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToLogin() {
    if (_navigated || !mounted) return;
    _navigated = true;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _goToLogin,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(),
                const SizedBox(height: AppSpacing.lg),
                const Text(AppStrings.appName, style: AppTypography.splashTitle),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  AppStrings.tagline,
                  textAlign: TextAlign.center,
                  style: AppTypography.splashTagline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
