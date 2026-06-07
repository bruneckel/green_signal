import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/form_utils.dart';
import '../../core/utils/validators.dart';
import '../../router/app_router.dart';
import '../../services/address/viacep_client.dart';
import '../../services/auth/auth_exceptions.dart';
import '../../services/auth/auth_repository.dart';
import '../../widgets/address/address_form_fields.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.authRepository,
    this.viaCepClient,
  });

  final AuthRepository authRepository;
  final ViaCepClient? viaCepClient;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<AddressFormFieldsState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _cepFocusNode = FocusNode();
  final _streetFocusNode = FocusNode();
  final _numberFocusNode = FocusNode();
  final _complementFocusNode = FocusNode();
  final _neighborhoodFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  late final ViaCepClient _viaCepClient;

  bool _attemptedSubmit = false;
  bool _isLoading = false;
  bool _cepResolved = false;

  @override
  void initState() {
    super.initState();
    _viaCepClient = widget.viaCepClient ?? LiveViaCepClient();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cepController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _cepFocusNode.dispose();
    _streetFocusNode.dispose();
    _numberFocusNode.dispose();
    _complementFocusNode.dispose();
    _neighborhoodFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    unfocus(context);
    setState(() => _attemptedSubmit = true);

    final cepResolved =
        _addressFormKey.currentState?.cepResolved ?? _cepResolved;

    if (!cepResolved) {
      _addressFormKey.currentState?.showCepRequiredError();
    }

    if (!_formKey.currentState!.validate() || !cepResolved) return;

    setState(() => _isLoading = true);

    try {
      await widget.authRepository.register(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        cep: _cepController.text,
        street: _streetController.text,
        number: _numberController.text,
        complement: _complementController.text.trim().isEmpty
            ? null
            : _complementController.text,
        neighborhood: _neighborhoodController.text,
        city: _cityController.text,
        state: _stateController.text,
      );

      if (!mounted) return;

      showAppSnackBar(context, AppStrings.registerSuccess);
      context.go(AppRoutes.login);
    } on EmailAlreadyRegisteredException {
      if (!mounted) return;
      showAppSnackBar(context, AppStrings.emailAlreadyRegistered);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
        autovalidateMode: _attemptedSubmit
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
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
              onFieldSubmitted: (_) => _focusNext(_cepFocusNode),
              validator: Validators.email,
            ),
            const SizedBox(height: AppSpacing.md),
            AddressFormFields(
              key: _addressFormKey,
              cepController: _cepController,
              streetController: _streetController,
              numberController: _numberController,
              complementController: _complementController,
              neighborhoodController: _neighborhoodController,
              cityController: _cityController,
              stateController: _stateController,
              cepFocusNode: _cepFocusNode,
              streetFocusNode: _streetFocusNode,
              numberFocusNode: _numberFocusNode,
              complementFocusNode: _complementFocusNode,
              neighborhoodFocusNode: _neighborhoodFocusNode,
              viaCepClient: _viaCepClient,
              onNextAfterNeighborhood: _phoneFocusNode,
              onCepStateChanged: (state) {
                setState(() => _cepResolved = state.cepResolved);
              },
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
              onPressed: _isLoading ? null : _submit,
              isLoading: _isLoading,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
