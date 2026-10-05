import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/pill_button.dart';

/// Edit a name: the user's own by default, or a family profile's with
/// [label] / [hint]. Returns the new text (blank = remove), or null if
/// dismissed.
Future<String?> showNameSheet(
  BuildContext context, {
  String? current,
  String? label,
  String? hint,
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _NameSheet(current: current, label: label, hint: hint),
);

class _NameSheet extends StatefulWidget {
  const _NameSheet({this.current, this.label, this.hint});

  final String? current;
  final String? label;
  final String? hint;

  @override
  State<_NameSheet> createState() => _NameSheetState();
}

class _NameSheetState extends State<_NameSheet> {
  late final _name = TextEditingController(text: widget.current);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      // Stay above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding.copyWith(bottom: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: widget.label ?? l10n.yourName,
                controller: _name,
                hint: widget.hint ?? l10n.settingsNameHint,
                textCapitalization: TextCapitalization.words,
                autofocus: true,
                onSubmitted: (v) => Navigator.pop(context, v),
              ),
              PillButton(
                label: l10n.save,
                onPressed: () => Navigator.pop(context, _name.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
