import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/profile_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/cep_input_formatter.dart';
import '../../core/utils/form_utils.dart';
import '../../core/utils/validators.dart';
import '../../models/user_account.dart';
import '../../services/address/viacep_client.dart';
import '../../services/auth/auth_repository.dart';
import '../../widgets/address/address_form_fields.dart';
import '../../widgets/app_text_field.dart';
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
  final _phoneFocusNode = FocusNode();
  final _cepFocusNode = FocusNode();
  final _streetFocusNode = FocusNode();
  final _numberFocusNode = FocusNode();
  final _complementFocusNode = FocusNode();
  final _neighborhoodFocusNode = FocusNode();

  late final ViaCepClient _viaCepClient;

  bool _attemptedSubmit = false;
  bool _isLoading = false;
  bool _cepResolved = false;
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
    _phoneController.text = user.phone;

    if (user.hasStructuredAddress) {
      _cepController.text = formatCepDisplay(user.cep);
      _streetController.text = user.street;
      _numberController.text = user.number ?? '';
      _complementController.text = user.complement ?? '';
      _neighborhoodController.text = user.neighborhood;
      _cityController.text = user.city;
      _stateController.text = user.state;
      _cepResolved = true;
    } else {
      _cepController.clear();
      _streetController.clear();
      _numberController.clear();
      _complementController.clear();
      _neighborhoodController.clear();
      _cityController.clear();
      _stateController.clear();
      _cepResolved = false;
    }

    _initialized = true;
    if (mounted) setState(() {});
  }

  Future<void> _submit() async {
    unfocus(context);
    setState(() => _attemptedSubmit = true);

    final user = widget.authRepository.currentUser;
    final cepResolved = user?.hasStructuredAddress == true ||
        _addressFormKey.currentState?.cepResolved == true ||
        _cepResolved;

    if (!cepResolved) {
      _addressFormKey.currentState?.showCepRequiredError();
    }

    if (!_formKey.currentState!.validate() || !cepResolved) return;

    setState(() => _isLoading = true);

    try {
      await widget.authRepository.updateProfile(
        name: _nameController.text,
        phone: _phoneController.text,
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

      showAppSnackBar(context, ProfileStrings.saveSuccess);
      context.pop();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
            autovalidateMode: _attemptedSubmit
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xs,
                    AppSpacing.sm,
                    AppSpacing.screenHorizontal,
                    0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                        color: AppColors.textPrimary,
                      ),
                      const Expanded(
                        child: Column(
                          children: [
                            Text(
                              ProfileStrings.screenTitle,
                              textAlign: TextAlign.center,
                              style: AppTypography.appBarTitle,
                            ),
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              ProfileStrings.subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
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
                          style: AppTypography.authTitle.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          user.email,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySecondary,
                        ),
                        const SizedBox(height: AppSpacing.sectionGap),
                        Text(
                          ProfileStrings.personalDataSection,
                          style: AppTypography.sectionTitle,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          hintText: AppStrings.fullName,
                          prefixIcon: Icons.person_outline,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).requestFocus(_phoneFocusNode),
                          validator: (value) => Validators.required(
                            value,
                            fieldName: AppStrings.fullName,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _emailController,
                          hintText: AppStrings.email,
                          prefixIcon: Icons.email_outlined,
                          readOnly: true,
                          enabled: false,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          ProfileStrings.emailReadOnlyHint,
                          style: AppTypography.bodySecondary.copyWith(
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          hintText: AppStrings.phone,
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).requestFocus(_cepFocusNode),
                          validator: (value) => Validators.required(
                            value,
                            fieldName: AppStrings.phone,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sectionGap),
                        Text(
                          ProfileStrings.addressSection,
                          style: AppTypography.sectionTitle,
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
                          initialCepResolved: user.hasStructuredAddress,
                          onCepStateChanged: (state) {
                            setState(() => _cepResolved = state.cepResolved);
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        PrimaryButton(
                          label: ProfileStrings.save,
                          onPressed: _isLoading ? null : _submit,
                          isLoading: _isLoading,
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
