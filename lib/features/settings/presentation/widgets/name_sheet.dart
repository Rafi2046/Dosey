import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/pill_button.dart';

/// Edit the user's name. Returns the new text (blank = remove), or null if
/// dismissed.
Future<String?> showNameSheet(BuildContext context, {String? current}) =>
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _NameSheet(current: current),
    );

class _NameSheet extends StatefulWidget {
  const _NameSheet({this.current});

  final String? current;

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
                label: l10n.yourName,
                controller: _name,
                hint: l10n.settingsNameHint,
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
