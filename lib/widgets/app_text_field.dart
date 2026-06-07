import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.focusNode,
    this.onFieldSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.readOnly = false,
    this.inputFormatters,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      textCapitalization: widget.textCapitalization,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: AppColors.textSecondary)
            : null,
        suffixIcon: widget.obscureText
            ? IconButton(
                tooltip: _obscureText ? 'Mostrar senha' : 'Ocultar senha',
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() => _obscureText = !_obscureText);
                },
              )
            : widget.suffixIcon,
      ),
    );
  }
}
