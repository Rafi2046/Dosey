import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/constants.dart';
import '../localization/l10n.dart';
import 'skeleton.dart';

/// Renders an [AsyncValue] with consistent loading and error states. Keeps
/// showing previous data while refreshing. While loading it shows a
/// shimmering [skeleton] shaped like the content (cards by default).
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.skeleton = const Skeleton.cards(),
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget skeleton;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnReload: true,
      data: data,
      loading: () => skeleton,
      error: (_, _) => Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Text(
          context.l10n.genericError,
          style: AppTextStyles.bodyMuted,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
