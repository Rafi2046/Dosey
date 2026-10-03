import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/widgets/choice_pills.dart';
import '../../../core/widgets/cream_scaffold.dart';
import '../../../core/widgets/labeled_field.dart';
import '../providers/settings_providers.dart';

/// App preferences. For now: the language (phone default, English, Bengali).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// Null = follow the phone.
  static const List<String?> _languages = [null, 'en', 'bn'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final language = ref.watch(languageProvider);
    return CreamScaffold(
      title: l10n.settingsTitle,
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          LabeledField(
            label: l10n.settingsLanguage,
            child: ChoicePills<String?>(
              options: _languages,
              selected: {language},
              iconOf: (code) =>
                  code == null ? Icons.smartphone_rounded : Icons.translate,
              labelOf: (code) => switch (code) {
                'en' => l10n.languageEnglish,
                'bn' => l10n.languageBangla,
                _ => l10n.languageSystem,
              },
              onChanged: (s) =>
                  ref.read(languageProvider.notifier).choose(s.single),
            ),
          ),
          Text(l10n.settingsLanguageHint, style: AppTextStyles.captionOnLight),
        ],
      ),
    );
  }
}
