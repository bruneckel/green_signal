import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/form_utils.dart';
import '../../core/utils/validators.dart';
import '../../models/map_layer_data.dart';
import '../../router/app_router.dart';
import '../../services/auth/auth_exceptions.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/environment/environmental_repository.dart';
import '../../services/environment/location_resolver.dart';
import '../../services/environment/map_location_resolver.dart';
import '../../services/map/map_grid_sampler.dart';
import '../../services/map/map_repository.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_footer_link.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authRepository,
    this.mapRepository,
    this.environmentalRepository,
    this.locationResolver,
    this.mapLocationResolver,
  });

  final AuthRepository authRepository;
  final MapRepository? mapRepository;
  final EnvironmentalRepository? environmentalRepository;
  final LocationResolver? locationResolver;
  final MapLocationResolver? mapLocationResolver;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _attemptedSubmit = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    unfocus(context);
    setState(() => _attemptedSubmit = true);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.authRepository.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      unawaited(_warmUpCaches());

      showAppSnackBar(context, AppStrings.loginSuccess);
      context.go(AppRoutes.home);
    } on InvalidCredentialsException {
      if (!mounted) return;
      showAppSnackBar(context, AppStrings.invalidCredentials);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _forgotPassword() {
    showAppSnackBar(context, AppStrings.featureComingSoon);
  }

  Future<void> _warmUpCaches() async {
    final envRepo = widget.environmentalRepository;
    final mapRepo = widget.mapRepository;
    final locationResolver = widget.locationResolver;
    final mapLocationResolver = widget.mapLocationResolver;
    if (envRepo == null ||
        mapRepo == null ||
        locationResolver == null ||
        mapLocationResolver == null) {
      return;
    }

    try {
      final location = await locationResolver.resolve(widget.authRepository);
      unawaited(
        envRepo.fetchSnapshot(
          point: location.position,
          locationLabel: location.label,
        ),
      );

      final mapLocation = await mapLocationResolver.resolve(
        widget.authRepository,
      );
      unawaited(
        mapRepo.fetchLayer(
          layer: MapLayer.airQuality,
          bounds: LatLngBounds.fromCenterZoom(
            mapLocation.position,
            MapLayerData.initialZoom,
          ),
          zoom: MapLayerData.initialZoom,
        ),
      );
    } catch (_) {
      // Warm-up is best-effort.
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
              onPressed: _isLoading ? null : _submit,
              isLoading: _isLoading,
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
