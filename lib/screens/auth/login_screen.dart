import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/form_utils.dart';
import '../../core/utils/validators.dart';
import '../../router/app_router.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_footer_link.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    unfocus(context);
    if (!_formKey.currentState!.validate()) return;

    showAppSnackBar(context, AppStrings.loginSuccess);
  }

  void _forgotPassword() {
    showAppSnackBar(context, AppStrings.featureComingSoon);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: AppStrings.welcomeTitle,
      subtitle: AppStrings.welcomeSubtitle,
      showBackButton: false,
      centerContent: true,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            AppTextField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              hintText: AppStrings.email,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_passwordFocusNode),
              validator: Validators.email,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              hintText: AppStrings.password,
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _submit(),
              validator: Validators.password,
            ),
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: TextButton(
                onPressed: _forgotPassword,
                child: const Text(AppStrings.forgotPassword),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: AppStrings.login,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.lg),
            AuthFooterLink(
              prefix: AppStrings.noAccount,
              actionLabel: AppStrings.signUp,
              onTap: () => context.push(AppRoutes.register),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
