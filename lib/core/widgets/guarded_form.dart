import 'package:flutter/material.dart';

import 'confirm_dialog.dart';

/// A [Form] for a full-screen editor: once any field has been edited, back
/// (button, gesture or the back arrow) asks before discarding the changes.
/// Saving still closes the page with `Navigator.pop`, which isn't blocked.
class GuardedForm extends StatefulWidget {
  const GuardedForm({super.key, required this.formKey, required this.child});

  final GlobalKey<FormState> formKey;
  final Widget child;

  @override
  State<GuardedForm> createState() => _GuardedFormState();
}

class _GuardedFormState extends State<GuardedForm> {
  bool _dirty = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      // A fixed field clears its error as soon as it is valid again.
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      onChanged: () {
        if (!_dirty) setState(() => _dirty = true);
      },
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await confirmDiscard(context)) navigator.pop();
      },
      child: widget.child,
    );
  }
}
