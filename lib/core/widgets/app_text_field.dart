import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/constants.dart';
import 'labeled_field.dart';

/// Labeled text input for cream form screens.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.prefixText,
    this.textCapitalization = TextCapitalization.sentences,
    this.inputFormatters,
  });

  /// Numeric input allowing one decimal point.
  const AppTextField.decimal({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.prefixText,
  }) : keyboardType = const TextInputType.numberWithOptions(decimal: true),
       maxLines = 1,
       textCapitalization = TextCapitalization.none,
       inputFormatters = null;

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final String? prefixText;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  /// Shared "required" validator.
  static String? required(String? value) =>
      (value == null || value.trim().isEmpty)
      ? ErrorStrings.fieldRequired
      : null;

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: label,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        minLines: 1,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        style: AppTextStyles.inputOnLight,
        cursorColor: AppColors.ink,
        decoration: InputDecoration(
          hintText: hint,
          prefixText: prefixText,
          prefixStyle: AppTextStyles.inputOnLight,
        ),
      ),
    );
  }
}
