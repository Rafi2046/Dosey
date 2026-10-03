import 'package:flutter/material.dart';

import '../constants/constants.dart';
import 'labeled_field.dart';

/// A text field that also suggests values as you type (specialties,
/// hospitals…). Free text is always allowed; picking a suggestion fills the
/// field and calls [onSelected].
class SuggestField<T extends Object> extends StatefulWidget {
  const SuggestField({
    super.key,
    required this.label,
    required this.controller,
    required this.suggestions,
    required this.labelOf,
    this.subtitleOf,
    this.onSelected,
    this.hint,
    this.icon,
    this.textCapitalization = TextCapitalization.words,
  });

  final String label;
  final TextEditingController controller;

  /// Matches for the current text (may be empty).
  final List<T> Function(String text) suggestions;
  final String Function(T) labelOf;
  final String? Function(T)? subtitleOf;
  final ValueChanged<T>? onSelected;
  final String? hint;
  final IconData? icon;
  final TextCapitalization textCapitalization;

  @override
  State<SuggestField<T>> createState() => _SuggestFieldState<T>();
}

class _SuggestFieldState<T extends Object> extends State<SuggestField<T>> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: widget.label,
      child: RawAutocomplete<T>(
        textEditingController: widget.controller,
        focusNode: _focus,
        optionsBuilder: (value) => widget.suggestions(value.text),
        displayStringForOption: widget.labelOf,
        onSelected: (option) => widget.onSelected?.call(option),
        fieldViewBuilder: (context, controller, focusNode, onSubmitted) =>
            TextFormField(
              controller: controller,
              focusNode: focusNode,
              textCapitalization: widget.textCapitalization,
              style: AppTextStyles.inputOnLight,
              cursorColor: AppColors.ink,
              onFieldSubmitted: (_) => onSubmitted(),
              decoration: InputDecoration(
                hintText: widget.hint,
                suffixIcon: widget.icon == null
                    ? null
                    : Icon(widget.icon, color: AppColors.inkMuted),
              ),
            ),
        optionsViewBuilder: (context, onSelected, options) => Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Material(
              color: AppColors.creamLight,
              elevation: AppSpacing.xs,
              shadowColor: AppColors.shadow,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: AppSpacing.suggestionsMaxHeight,
                  maxWidth: AppSpacing.suggestionsMaxWidth,
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: [
                    for (final option in options)
                      ListTile(
                        dense: true,
                        title: Text(
                          widget.labelOf(option),
                          style: AppTextStyles.inputOnLight,
                        ),
                        subtitle: switch (widget.subtitleOf?.call(option)) {
                          final s? when s.isNotEmpty => Text(
                            s,
                            style: AppTextStyles.captionOnLight,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          _ => null,
                        },
                        onTap: () => onSelected(option),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
