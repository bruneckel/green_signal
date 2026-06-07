import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AppSnackBarType { success, error, info }

void unfocus(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();
}

void focusNext(BuildContext context, FocusNode node) {
  FocusScope.of(context).requestFocus(node);
}

String? optionalTrim(String value) =>
    value.trim().isEmpty ? null : value.trim();

void showAppSnackBar(
  BuildContext context,
  String message, {
  AppSnackBarType type = AppSnackBarType.info,
}) {
  final backgroundColor = switch (type) {
    AppSnackBarType.success => AppColors.primaryDark,
    AppSnackBarType.error => AppColors.riskHigh,
    AppSnackBarType.info => AppColors.textPrimary,
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
}

class ValidatedFormController {
  bool attemptedSubmit = false;
  bool isLoading = false;

  AutovalidateMode get autovalidateMode => attemptedSubmit
      ? AutovalidateMode.onUserInteraction
      : AutovalidateMode.disabled;

  Future<void> run({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required VoidCallback notify,
    VoidCallback? beforeValidate,
    bool Function()? extraValidation,
    required Future<void> Function() action,
  }) async {
    unfocus(context);
    attemptedSubmit = true;
    notify();

    beforeValidate?.call();

    final formValid = formKey.currentState?.validate() ?? false;
    final extraValid = extraValidation?.call() ?? true;
    if (!formValid || !extraValid) return;

    isLoading = true;
    notify();

    try {
      await action();
    } finally {
      isLoading = false;
      notify();
    }
  }
}
