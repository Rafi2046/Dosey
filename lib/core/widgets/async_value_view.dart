import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/constants.dart';

/// Renders an [AsyncValue] with consistent loading and error states. Keeps
/// showing previous data while refreshing.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({super.key, required this.value, required this.data});

  final AsyncValue<T> value;
  final Widget Function(T data) data;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnReload: true,
      data: data,
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Text(
          AppStrings.genericError,
          style: AppTextStyles.bodyMuted,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
