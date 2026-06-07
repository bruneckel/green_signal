import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/profile_strings.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/form_utils.dart';
import '../../core/utils/validators.dart';
import '../app_text_field.dart';
import 'email_text_field.dart';
import 'form_section_title.dart';
import 'phone_text_field.dart';

class PersonalDataFormFields extends StatelessWidget {
  const PersonalDataFormFields({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.nameFocusNode,
    required this.emailFocusNode,
    required this.phoneFocusNode,
    this.emailReadOnly = false,
    this.onNextAfterPhone,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final FocusNode nameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode phoneFocusNode;
  final bool emailReadOnly;
  final FocusNode? onNextAfterPhone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormSectionTitle(title: AppStrings.personalDataSection),
        AppTextField(
          controller: nameController,
          focusNode: nameFocusNode,
          hintText: AppStrings.fullName,
          prefixIcon: Icons.person_outline,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.name],
          onFieldSubmitted: (_) => emailReadOnly
              ? focusNext(context, phoneFocusNode)
              : focusNext(context, emailFocusNode),
          validator: (value) =>
              Validators.required(value, fieldName: AppStrings.fullName),
        ),
        const SizedBox(height: AppSpacing.md),
        EmailTextField(
          controller: emailController,
          focusNode: emailFocusNode,
          readOnly: emailReadOnly,
          enabled: !emailReadOnly,
          onFieldSubmitted: emailReadOnly
              ? null
              : (_) => focusNext(context, phoneFocusNode),
        ),
        if (emailReadOnly) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            ProfileStrings.emailReadOnlyHint,
            style: AppTypography.bodySecondary.copyWith(
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        PhoneTextField(
          controller: phoneController,
          focusNode: phoneFocusNode,
          onFieldSubmitted: onNextAfterPhone == null
              ? null
              : (_) => focusNext(context, onNextAfterPhone!),
        ),
      ],
    );
  }
}
