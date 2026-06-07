import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../app_text_field.dart';

class PasswordTextField extends StatelessWidget {
  const PasswordTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.hintText = AppStrings.password,
    this.textInputAction = TextInputAction.done,
    this.autofillHints = const [AutofillHints.password],
    this.onFieldSubmitted,
    this.confirmAgainst,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final TextInputAction textInputAction;
  final Iterable<String> autofillHints;
  final ValueChanged<String>? onFieldSubmitted;
  final String Function()? confirmAgainst;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      focusNode: focusNode,
      hintText: hintText,
      prefixIcon: Icons.lock_outline,
      obscureText: true,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onFieldSubmitted: onFieldSubmitted,
      validator: confirmAgainst == null
          ? Validators.password
          : (value) =>
              Validators.confirmPassword(value, confirmAgainst!()),
    );
  }
}
