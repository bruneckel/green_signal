import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/form_utils.dart';
import '../../services/auth/auth_repository.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/forms/email_text_field.dart';
import '../../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formController = ValidatedFormController();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  bool _submitted = false;
  String _submittedEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await _formController.run(
      context: context,
      formKey: _formKey,
      notify: () => setState(() {}),
      action: () async {
        await widget.authRepository.requestPasswordReset(
          email: _emailController.text,
        );

        if (!mounted) return;

        setState(() {
          _submitted = true;
          _submittedEmail = _emailController.text.trim();
        });
      },
    );
  }

  Future<void> _resend() async {
    _formController.isLoading = true;
    setState(() {});

    try {
      await widget.authRepository.requestPasswordReset(
        email: _submittedEmail,
      );
    } finally {
      if (mounted) {
        _formController.isLoading = false;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: _submitted
          ? AppStrings.forgotPasswordSuccessTitle
          : AppStrings.forgotPasswordTitle,
      subtitle: _submitted
          ? AppStrings.forgotPasswordSuccessMessage
          : AppStrings.forgotPasswordSubtitle,
      onBack: () => context.pop(),
      child: _submitted ? _buildSuccessContent() : _buildFormContent(),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      autovalidateMode: _formController.autovalidateMode,
      child: Column(
        children: [
          EmailTextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: AppStrings.sendResetLink,
            onPressed: _formController.isLoading ? null : _submit,
            isLoading: _formController.isLoading,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 72,
          color: AppColors.primaryGreen.withValues(alpha: 0.85),
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: AppStrings.backToLogin,
          onPressed: _formController.isLoading ? null : () => context.pop(),
          isLoading: false,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: _formController.isLoading ? null : _resend,
          child: const Text(AppStrings.resendResetLink),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
