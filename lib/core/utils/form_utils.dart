import 'package:flutter/material.dart';

void unfocus(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();
}

void focusNext(BuildContext context, FocusNode node) {
  FocusScope.of(context).requestFocus(node);
}

String? optionalTrim(String value) =>
    value.trim().isEmpty ? null : value.trim();

void showAppSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
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
