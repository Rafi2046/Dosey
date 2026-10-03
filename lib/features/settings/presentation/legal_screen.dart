import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/cream_scaffold.dart';
import '../domain/legal_document.dart';

/// Privacy policy, terms of use or medical disclaimer, readable in-app (in
/// the current language).
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CreamScaffold(
      title: document.title(l10n),
      onDark: true,
      body: ListView(
        padding: AppSpacing.screenPadding.copyWith(bottom: AppSpacing.xxl),
        children: [
          Text(
            l10n.lastUpdated(AppDateFormat.date(AppConstants.legalUpdated)),
            style: AppTextStyles.caption,
          ),
          AppSpacing.gapLg,
          for (final (heading, body) in document.sections(l10n)) ...[
            Text(heading, style: AppTextStyles.cardTitle),
            AppSpacing.gapXs,
            Text(body, style: AppTextStyles.body),
            AppSpacing.gapXl,
          ],
        ],
      ),
    );
  }
}
