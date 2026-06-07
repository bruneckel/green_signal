import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/form_utils.dart';
import '../../router/app_router.dart';
import '../../services/address/viacep_client.dart';
import '../../services/auth/auth_exceptions.dart';
import '../../services/auth/auth_repository.dart';
import '../../widgets/address/address_form_fields.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/forms/form_section_title.dart';
import '../../widgets/forms/password_text_field.dart';
import '../../widgets/forms/personal_data_form_fields.dart';
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
  final _formController = ValidatedFormController();
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

  bool _isCepResolved() => _addressFormKey.currentState?.cepResolved == true;

  Future<void> _submit() async {
    await _formController.run(
      context: context,
      formKey: _formKey,
      notify: () => setState(() {}),
      beforeValidate: () {
        if (!_isCepResolved()) {
          _addressFormKey.currentState?.showCepRequiredError();
        }
      },
      extraValidation: _isCepResolved,
      action: () async {
        try {
          await widget.authRepository.register(
            name: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            password: _passwordController.text,
            cep: _cepController.text,
            street: _streetController.text,
            number: _numberController.text,
            complement: optionalTrim(_complementController.text),
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
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: AppStrings.registerTitle,
      subtitle: AppStrings.registerSubtitle,
      onBack: () => context.pop(),
      child: Form(
        key: _formKey,
        autovalidateMode: _formController.autovalidateMode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PersonalDataFormFields(
              nameController: _nameController,
              emailController: _emailController,
              phoneController: _phoneController,
              nameFocusNode: _nameFocusNode,
              emailFocusNode: _emailFocusNode,
              phoneFocusNode: _phoneFocusNode,
              onNextAfterPhone: _cepFocusNode,
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            FormSectionTitle(title: AppStrings.addressSection),
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
              onNextAfterNeighborhood: _passwordFocusNode,
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            FormSectionTitle(title: AppStrings.securitySection),
            PasswordTextField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              onFieldSubmitted: (_) =>
                  focusNext(context, _confirmPasswordFocusNode),
            ),
            const SizedBox(height: AppSpacing.md),
            PasswordTextField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocusNode,
              hintText: AppStrings.confirmPassword,
              confirmAgainst: () => _passwordController.text,
              autofillHints: const [AutofillHints.newPassword],
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: AppStrings.register,
              onPressed: _formController.isLoading ? null : _submit,
              isLoading: _formController.isLoading,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
