import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/form_utils.dart';
import '../../router/app_router.dart';
import '../../services/auth/auth_exceptions.dart';
import '../../services/auth/auth_repository.dart';
import '../../widgets/auth_footer_link.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/forms/email_text_field.dart';
import '../../widgets/forms/password_text_field.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formController = ValidatedFormController();
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

  Future<void> _submit() async {
    await _formController.run(
      context: context,
      formKey: _formKey,
      notify: () => setState(() {}),
      action: () async {
        await widget.authRepository.login(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (!mounted) return;

        showAppSnackBar(
          context,
          AppStrings.loginSuccess,
          type: AppSnackBarType.success,
        );
        context.go(AppRoutes.home);
      },
    );
  }

  Future<void> _submitWithCredentials() async {
    try {
      await _submit();
    } on InvalidCredentialsException {
      if (!mounted) return;
      showAppSnackBar(
        context,
        AppStrings.invalidCredentials,
        type: AppSnackBarType.error,
      );
    }
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
        autovalidateMode: _formController.autovalidateMode,
        child: Column(
          children: [
            EmailTextField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              onFieldSubmitted: (_) => focusNext(context, _passwordFocusNode),
            ),
            const SizedBox(height: AppSpacing.md),
            PasswordTextField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              onFieldSubmitted: (_) => _submitWithCredentials(),
            ),
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push(AppRoutes.forgotPassword),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(AppStrings.forgotPassword),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: AppStrings.login,
              onPressed: _formController.isLoading ? null : _submitWithCredentials,
              isLoading: _formController.isLoading,
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
