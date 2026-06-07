import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../app_text_field.dart';

class EmailTextField extends StatelessWidget {
  const EmailTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.readOnly = false,
    this.enabled = true,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final bool readOnly;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      focusNode: focusNode,
      hintText: AppStrings.email,
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.email],
      onFieldSubmitted: onFieldSubmitted,
      validator: enabled && !readOnly ? Validators.email : null,
      readOnly: readOnly,
      enabled: enabled,
    );
  }
}
