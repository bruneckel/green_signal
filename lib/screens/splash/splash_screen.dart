import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../router/app_router.dart';
import '../../services/auth/auth_repository.dart';
import '../../widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.authRepository});

  static const duration = Duration(milliseconds: 2500);

  final AuthRepository authRepository;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(SplashScreen.duration, _navigateFromSplash);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _navigateFromSplash() {
    if (_navigated || !mounted) return;
    _navigated = true;

    if (widget.authRepository.isLoggedIn) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateFromSplash,
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
