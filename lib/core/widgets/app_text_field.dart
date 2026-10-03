import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/constants.dart';
import 'labeled_field.dart';
import '../localization/l10n.dart';

/// Labeled text input for cream form screens.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.bottomGap = AppSpacing.fieldGap,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.prefixText,
    this.textCapitalization = TextCapitalization.sentences,
    this.inputFormatters,
    this.autofocus = false,
    this.onSubmitted,
  });

  /// Numeric input allowing one decimal point.
  const AppTextField.decimal({
    super.key,
    required this.label,
    this.bottomGap = AppSpacing.fieldGap,
    required this.controller,
    this.hint,
    this.validator,
    this.prefixText,
  }) : keyboardType = const TextInputType.numberWithOptions(decimal: true),
       maxLines = 1,
       textCapitalization = TextCapitalization.none,
       inputFormatters = null,
       autofocus = false,
       onSubmitted = null;

  final String label;

  /// See [LabeledField.bottomGap].
  final double bottomGap;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final String? prefixText;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;

  /// Keyboard "done"; also makes the action key say done.
  final ValueChanged<String>? onSubmitted;

  /// Shared "required" validator (message in the current language).
  static String? required(String? value) =>
      (value == null || value.trim().isEmpty)
      ? AppLocale.l10n.fieldRequired
      : null;

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: label,
      bottomGap: bottomGap,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        minLines: 1,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        autofocus: autofocus,
        onFieldSubmitted: onSubmitted,
        textInputAction: onSubmitted == null ? null : TextInputAction.done,
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
