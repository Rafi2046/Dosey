import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/widgets/circle_icon_button.dart';
import '../../../core/widgets/pill_button.dart';
import '../providers/permissions_provider.dart';
import 'pages/features_page.dart';
import 'pages/permissions_page.dart';
import 'pages/welcome_page.dart';
import 'widgets/page_dots.dart';

/// First-run flow: welcome + language → what Dosey does → permissions.
/// "Finish" unlocks once the essential permissions are granted.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.onFinished,
    this.initialPage = 0,
  });

  static const int permissionsPage = 2;
  static const int pageCount = 3;

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

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
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
                      child: CircleIconButton(
                        icon: Icons.chevron_left_rounded,
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).backButtonTooltip,
                        onPressed: _page > 0 ? () => _goTo(_page - 1) : null,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pages,
                  onPageChanged: (p) => setState(() => _page = p),
                  children: const [
                    WelcomePage(),
                    FeaturesPage(),
                    PermissionsPage(),
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
                                l10n.onboardingEssentialHint,
                                style: AppTextStyles.caption,
                                textAlign: TextAlign.center,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    PillButton(
                      label: switch (_page) {
                        0 => l10n.onboardingContinue,
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
