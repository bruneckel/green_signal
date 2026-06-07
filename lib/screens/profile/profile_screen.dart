import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/profile_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/cep_input_formatter.dart';
import '../../core/utils/form_utils.dart';
import '../../core/utils/phone_input_formatter.dart';
import '../../models/user_account.dart';
import '../../services/address/viacep_client.dart';
import '../../services/auth/auth_repository.dart';
import '../../widgets/address/address_form_fields.dart';
import '../../widgets/forms/form_screen_header.dart';
import '../../widgets/forms/form_section_title.dart';
import '../../widgets/forms/personal_data_form_fields.dart';
import '../../widgets/primary_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.authRepository,
    this.viaCepClient,
  });

  final AuthRepository authRepository;
  final ViaCepClient? viaCepClient;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formController = ValidatedFormController();
  final _addressFormKey = GlobalKey<AddressFormFieldsState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _cepFocusNode = FocusNode();
  final _streetFocusNode = FocusNode();
  final _numberFocusNode = FocusNode();
  final _complementFocusNode = FocusNode();
  final _neighborhoodFocusNode = FocusNode();

  late final ViaCepClient _viaCepClient;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _viaCepClient = widget.viaCepClient ?? LiveViaCepClient();
    widget.authRepository.addListener(_onAuthChanged);
    _loadUser(widget.authRepository.currentUser);
  }

  @override
  void dispose() {
    widget.authRepository.removeListener(_onAuthChanged);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cepController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _cepFocusNode.dispose();
    _streetFocusNode.dispose();
    _numberFocusNode.dispose();
    _complementFocusNode.dispose();
    _neighborhoodFocusNode.dispose();
    super.dispose();
  }

  void _onAuthChanged() {
    _loadUser(widget.authRepository.currentUser);
  }

  void _loadUser(UserAccount? user) {
    if (user == null) return;

    _nameController.text = user.name;
    _emailController.text = user.email;
    _phoneController.text = formatPhoneDisplay(user.phone);

    if (user.hasStructuredAddress) {
      _cepController.text = formatCepDisplay(user.cep);
      _streetController.text = user.street;
      _numberController.text = user.number ?? '';
      _complementController.text = user.complement ?? '';
      _neighborhoodController.text = user.neighborhood;
      _cityController.text = user.city;
      _stateController.text = user.state;
    } else {
      _cepController.clear();
      _streetController.clear();
      _numberController.clear();
      _complementController.clear();
      _neighborhoodController.clear();
      _cityController.clear();
      _stateController.clear();
    }

    _initialized = true;
    if (mounted) setState(() {});
  }

  bool _isCepResolved() {
    final user = widget.authRepository.currentUser;
    return user?.hasStructuredAddress == true ||
        _addressFormKey.currentState?.cepResolved == true;
  }

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
        await widget.authRepository.updateProfile(
          name: _nameController.text,
          phone: _phoneController.text,
          cep: _cepController.text,
          street: _streetController.text,
          number: _numberController.text,
          complement: optionalTrim(_complementController.text),
          neighborhood: _neighborhoodController.text,
          city: _cityController.text,
          state: _stateController.text,
        );

        if (!mounted) return;

        showAppSnackBar(
          context,
          ProfileStrings.saveSuccess,
          type: AppSnackBarType.success,
        );
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authRepository.currentUser;

    if (!_initialized || user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: () => unfocus(context),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: _formController.autovalidateMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormScreenHeader(
                  title: ProfileStrings.screenTitle,
                  subtitle: ProfileStrings.subtitle,
                  onBack: () => context.pop(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenHorizontal,
                      AppSpacing.lg,
                      AppSpacing.screenHorizontal,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                AppColors.primaryGreen.withValues(alpha: 0.15),
                            child: const Icon(
                              Icons.person,
                              size: 44,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          user.name,
                          textAlign: TextAlign.center,
                          style: AppTypography.authTitle.copyWith(
                            fontSize: 20,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySecondary.copyWith(
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sectionGap),
                        PersonalDataFormFields(
                          nameController: _nameController,
                          emailController: _emailController,
                          phoneController: _phoneController,
                          nameFocusNode: _nameFocusNode,
                          emailFocusNode: _emailFocusNode,
                          phoneFocusNode: _phoneFocusNode,
                          emailReadOnly: true,
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
                          initialCepResolved: user.hasStructuredAddress,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        PrimaryButton(
                          label: ProfileStrings.save,
                          onPressed: _formController.isLoading ? null : _submit,
                          isLoading: _formController.isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
