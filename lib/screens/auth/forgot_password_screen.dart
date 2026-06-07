import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/form_utils.dart';
import '../../core/utils/validators.dart';
import '../../services/auth/auth_repository.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  bool _attemptedSubmit = false;
  bool _isLoading = false;
  bool _submitted = false;
  String _submittedEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    unfocus(context);
    setState(() => _attemptedSubmit = true);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.authRepository.requestPasswordReset(
        email: _emailController.text,
      );

      if (!mounted) return;

      setState(() {
        _submitted = true;
        _submittedEmail = _emailController.text.trim();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resend() async {
    setState(() => _isLoading = true);

    try {
      await widget.authRepository.requestPasswordReset(
        email: _submittedEmail,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
      autovalidateMode: _attemptedSubmit
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        children: [
          AppTextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            hintText: AppStrings.email,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            onFieldSubmitted: (_) => _submit(),
            validator: Validators.email,
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: AppStrings.sendResetLink,
            onPressed: _isLoading ? null : _submit,
            isLoading: _isLoading,
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
          onPressed: _isLoading ? null : () => context.pop(),
          isLoading: false,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: _isLoading ? null : _resend,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(AppStrings.resendResetLink),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
