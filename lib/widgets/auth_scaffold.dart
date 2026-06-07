import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/form_utils.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBackButton = true,
    this.centerContent = false,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool showBackButton;
  final bool centerContent;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => unfocus(context),
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: centerContent
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    children: [
                      if (showBackButton)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: AppSpacing.xs,
                              bottom: AppSpacing.lg,
                            ),
                            child: IconButton(
                              onPressed:
                                  onBack ?? () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              style: IconButton.styleFrom(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        )
                      else if (!centerContent)
                        const SizedBox(height: AppSpacing.xl),
                      Text(title, style: AppTypography.authTitle),
                      const SizedBox(height: AppSpacing.xs),
                      Text(subtitle, style: AppTypography.authSubtitle),
                      const SizedBox(height: AppSpacing.xl),
                      child,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
