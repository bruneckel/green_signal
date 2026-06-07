import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/form_utils.dart';
import '../../core/utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _addressFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    unfocus(context);
    if (!_formKey.currentState!.validate()) return;

    showAppSnackBar(context, AppStrings.registerSuccess);
    context.pop();
  }

  void _focusNext(FocusNode node) {
    FocusScope.of(context).requestFocus(node);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: AppStrings.registerTitle,
      subtitle: AppStrings.registerSubtitle,
      onBack: () => context.pop(),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            AppTextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              hintText: AppStrings.fullName,
              prefixIcon: Icons.person_outline,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              onFieldSubmitted: (_) => _focusNext(_emailFocusNode),
              validator: (value) =>
                  Validators.required(value, fieldName: AppStrings.fullName),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              hintText: AppStrings.email,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              onFieldSubmitted: (_) => _focusNext(_addressFocusNode),
              validator: Validators.email,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _addressController,
              focusNode: _addressFocusNode,
              hintText: AppStrings.address,
              prefixIcon: Icons.location_on_outlined,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.fullStreetAddress],
              onFieldSubmitted: (_) => _focusNext(_phoneFocusNode),
              validator: (value) =>
                  Validators.required(value, fieldName: AppStrings.address),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              hintText: AppStrings.phone,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              onFieldSubmitted: (_) => _focusNext(_passwordFocusNode),
              validator: (value) =>
                  Validators.required(value, fieldName: AppStrings.phone),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              hintText: AppStrings.password,
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              onFieldSubmitted: (_) => _focusNext(_confirmPasswordFocusNode),
              validator: Validators.password,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocusNode,
              hintText: AppStrings.confirmPassword,
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onFieldSubmitted: (_) => _submit(),
              validator: (value) => Validators.confirmPassword(
                value,
                _passwordController.text,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: AppStrings.register,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
