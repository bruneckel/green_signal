import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/cep_input_formatter.dart';
import '../../core/utils/form_utils.dart';
import '../../core/utils/validators.dart';
import '../../services/address/viacep_client.dart';
import '../app_text_field.dart';

class AddressFormFields extends StatefulWidget {
  const AddressFormFields({
    super.key,
    required this.cepController,
    required this.streetController,
    required this.numberController,
    required this.complementController,
    required this.neighborhoodController,
    required this.cityController,
    required this.stateController,
    required this.cepFocusNode,
    required this.streetFocusNode,
    required this.numberFocusNode,
    required this.complementFocusNode,
    required this.neighborhoodFocusNode,
    required this.viaCepClient,
    this.initialCepResolved = false,
    this.onNextAfterNeighborhood,
  });

  final TextEditingController cepController;
  final TextEditingController streetController;
  final TextEditingController numberController;
  final TextEditingController complementController;
  final TextEditingController neighborhoodController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final FocusNode cepFocusNode;
  final FocusNode streetFocusNode;
  final FocusNode numberFocusNode;
  final FocusNode complementFocusNode;
  final FocusNode neighborhoodFocusNode;
  final ViaCepClient viaCepClient;
  final bool initialCepResolved;
  final FocusNode? onNextAfterNeighborhood;

  @override
  State<AddressFormFields> createState() => AddressFormFieldsState();
}

class AddressFormFieldsState extends State<AddressFormFields> {
  bool _isFetchingCep = false;
  late bool _cepResolved;
  String? _cepError;

  @override
  void initState() {
    super.initState();
    _cepResolved = widget.initialCepResolved;
    widget.cepController.addListener(_onCepChanged);
  }

  @override
  void dispose() {
    widget.cepController.removeListener(_onCepChanged);
    super.dispose();
  }

  bool get cepResolved => _cepResolved;

  void showCepRequiredError() {
    setState(() => _cepError = AppStrings.cepNotFound);
  }

  void _onCepChanged() {
    final digits = widget.cepController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 8) {
      _fetchCep(digits);
    } else if (_cepResolved) {
      setState(() {
        _cepResolved = false;
        _cepError = null;
        widget.streetController.clear();
        widget.neighborhoodController.clear();
        widget.cityController.clear();
        widget.stateController.clear();
      });
    }
  }

  Future<void> _fetchCep(String digits) async {
    setState(() {
      _isFetchingCep = true;
      _cepError = null;
    });

    final result = await widget.viaCepClient.fetch(digits);

    if (!mounted) return;

    if (result == null) {
      setState(() {
        _isFetchingCep = false;
        _cepResolved = false;
        _cepError = AppStrings.cepNotFound;
      });
      return;
    }

    setState(() {
      _isFetchingCep = false;
      _cepResolved = true;
      widget.streetController.text = result.street;
      widget.neighborhoodController.text = result.neighborhood;
      widget.cityController.text = result.city;
      widget.stateController.text = result.state;
      if (result.complement.isNotEmpty &&
          widget.complementController.text.trim().isEmpty) {
        widget.complementController.text = result.complement;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          controller: widget.cepController,
          focusNode: widget.cepFocusNode,
          hintText: AppStrings.cep,
          prefixIcon: Icons.pin_drop_outlined,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
            CepInputFormatter(),
          ],
          onFieldSubmitted: (_) => focusNext(context, widget.streetFocusNode),
          validator: Validators.cep,
          suffixIcon: _isFetchingCep
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
        ),
        if (_cepError != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _cepError!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: AppTextField(
                controller: widget.streetController,
                focusNode: widget.streetFocusNode,
                hintText: AppStrings.street,
                prefixIcon: Icons.signpost_outlined,
                textInputAction: TextInputAction.next,
                enabled: _cepResolved,
                onFieldSubmitted: (_) => focusNext(context, widget.numberFocusNode),
                validator: (value) =>
                    Validators.required(value, fieldName: AppStrings.street),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                controller: widget.numberController,
                focusNode: widget.numberFocusNode,
                hintText: AppStrings.numberHint,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                enabled: _cepResolved,
                onFieldSubmitted: (_) =>
                    focusNext(context, widget.complementFocusNode),
                validator: (value) =>
                    Validators.required(value, fieldName: AppStrings.number),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: widget.complementController,
          focusNode: widget.complementFocusNode,
          hintText: AppStrings.complement,
          prefixIcon: Icons.apartment_outlined,
          textInputAction: TextInputAction.next,
          enabled: _cepResolved,
          onFieldSubmitted: (_) => focusNext(context, widget.neighborhoodFocusNode),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: widget.neighborhoodController,
          focusNode: widget.neighborhoodFocusNode,
          hintText: AppStrings.neighborhood,
          prefixIcon: Icons.location_city_outlined,
          textInputAction: TextInputAction.next,
          enabled: _cepResolved,
          onFieldSubmitted: (_) {
            final next = widget.onNextAfterNeighborhood;
            if (next != null) {
              focusNext(context, next);
            }
          },
          validator: (value) => Validators.required(
            value,
            fieldName: AppStrings.neighborhood,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: AppTextField(
                controller: widget.cityController,
                hintText: AppStrings.city,
                prefixIcon: Icons.map_outlined,
                readOnly: true,
                enabled: _cepResolved,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                controller: widget.stateController,
                hintText: AppStrings.stateHint,
                readOnly: true,
                enabled: _cepResolved,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
