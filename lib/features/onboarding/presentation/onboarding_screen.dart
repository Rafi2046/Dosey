import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/widgets/pill_button.dart';
import '../providers/permissions_provider.dart';
import '../../settings/providers/settings_providers.dart';
import 'pages/features_page.dart';
import 'pages/name_page.dart';
import 'pages/permissions_page.dart';
import 'pages/welcome_page.dart';
import 'widgets/page_dots.dart';
import '../../../core/widgets/back_arrow_button.dart';

/// First-run flow: welcome + language → name (optional) → what Dosey does
/// → permissions.
/// "Finish" unlocks once the essential permissions are granted.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.onFinished,
    this.initialPage = 0,
  });

  static const int namePage = 1;
  static const int permissionsPage = 3;
  static const int pageCount = 4;

  /// [permissionsPage] when only permissions are missing (already onboarded
  /// once, then revoked one).
  final int initialPage;
  final VoidCallback onFinished;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pages = PageController(
    initialPage: widget.initialPage,
  );
  late int _page = widget.initialPage;
  final _name = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Coming back to onboarding: show the name already saved.
    ref.read(userNameProvider.future).then((saved) {
      if (mounted && saved != null && _name.text.isEmpty) _name.text = saved;
    });
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pages.dispose();
    _name.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    // Leaving the name page (button, swipe or back): keep what was typed.
    if (_page == OnboardingScreen.namePage) {
      FocusScope.of(context).unfocus();
      ref.read(userNameProvider.notifier).set(_name.text);
    }
    setState(() => _page = page);
  }

  void _goTo(int page) => _pages.animateToPage(
    page,
    duration: AppSpacing.animSlow,
    curve: Curves.easeOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLast = _page == OnboardingScreen.permissionsPage;
    final granted = ref.watch(permissionsProvider).value ?? const {};
    final canFinish = granted.hasEssentials;

    return PopScope(
      // System back steps through the pages before leaving the app.
      canPop: _page == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goTo(_page - 1);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: AppSpacing.circleButton + AppSpacing.lg,
                child: Padding(
                  padding: AppSpacing.screenPadding.copyWith(
                    top: AppSpacing.md,
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: AnimatedOpacity(
                      opacity: _page > 0 ? 1 : 0,
                      duration: AppSpacing.animFast,
                      child: IgnorePointer(
                        ignoring: _page == 0,
                        child: BackArrowButton(
                          onPressed: () => _goTo(_page - 1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pages,
                  onPageChanged: _onPageChanged,
                  children: [
                    const WelcomePage(),
                    NamePage(
                      controller: _name,
                      onDone: () => _goTo(OnboardingScreen.namePage + 1),
                    ),
                    const FeaturesPage(),
                    const PermissionsPage(),
                  ],
                ),
              ),
              Padding(
                padding: AppSpacing.bottomBarPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PageDots(count: OnboardingScreen.pageCount, current: _page),
                    AppSpacing.gapLg,
                    AnimatedSwitcher(
                      duration: AppSpacing.animMedium,
                      child: isLast && !canFinish
                          ? Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: Text(
                                // iOS has no exact-alarm setting to grant.
                                Platform.isIOS
                                    ? l10n.onboardingEssentialHintIos
                                    : l10n.onboardingEssentialHint,
                                style: AppTextStyles.caption,
                                textAlign: TextAlign.center,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    PillButton(
                      label: switch (_page) {
                        0 => l10n.onboardingContinue,
                        // Nothing typed: the same button skips the name.
                        OnboardingScreen.namePage =>
                          _name.text.trim().isEmpty
                              ? l10n.skip
                              : l10n.onboardingContinue,
                        OnboardingScreen.permissionsPage =>
                          l10n.onboardingFinish,
                        _ => l10n.next,
                      },
                      showRingChevron: true,
                      onPressed: !isLast
                          ? () => _goTo(_page + 1)
                          : canFinish
                          ? widget.onFinished
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
