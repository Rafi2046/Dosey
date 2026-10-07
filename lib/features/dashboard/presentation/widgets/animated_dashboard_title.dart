import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';

/// Animated typewriter / ticker headline for the dashboard title.
/// Types in with Nothing OS dot-matrix styling and a blinking accent cursor,
/// holds, and smoothly cycles.
class AnimatedDashboardTitle extends StatefulWidget {
  const AnimatedDashboardTitle({
    super.key,
    required this.title,
    this.secondaryTitle,
  });

  final String title;
  final String? secondaryTitle;

  @override
  State<AnimatedDashboardTitle> createState() => _AnimatedDashboardTitleState();
}

class _AnimatedDashboardTitleState extends State<AnimatedDashboardTitle>
    with SingleTickerProviderStateMixin {
  late final List<String> _phrases;
  int _currentPhraseIndex = 0;
  int _charIndex = 0;
  bool _isDeleting = false;
  Timer? _timer;
  bool _showCursor = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _phrases = [
      widget.title,
      if (widget.secondaryTitle != null && widget.secondaryTitle!.isNotEmpty)
        widget.secondaryTitle!,
    ];

    // Blinking cursor timer (Nothing dot / cursor pulse)
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (t) {
      if (mounted) {
        setState(() => _showCursor = !_showCursor);
      }
    });

    _scheduleNextTick(const Duration(milliseconds: 300));
  }

  @override
  void didUpdateWidget(covariant AnimatedDashboardTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title ||
        oldWidget.secondaryTitle != widget.secondaryTitle) {
      _phrases
        ..clear()
        ..add(widget.title);
      if (widget.secondaryTitle != null &&
          widget.secondaryTitle!.isNotEmpty) {
        _phrases.add(widget.secondaryTitle!);
      }
      _charIndex = 0;
      _isDeleting = false;
      _scheduleNextTick(const Duration(milliseconds: 100));
    }
  }

  void _scheduleNextTick(Duration delay) {
    _timer?.cancel();
    _timer = Timer(delay, _tick);
  }

  void _tick() {
    if (!mounted) return;

    final currentPhrase = _phrases[_currentPhraseIndex % _phrases.length];

    setState(() {
      if (!_isDeleting) {
        // Typing forward
        if (_charIndex < currentPhrase.length) {
          _charIndex++;
          _scheduleNextTick(const Duration(milliseconds: 65));
        } else {
          // Finished typing phrase, hold before deleting/cycling
          _scheduleNextTick(const Duration(milliseconds: 3500));
          _isDeleting = true;
        }
      } else {
        // Deleting backward
        if (_charIndex > 0) {
          _charIndex--;
          _scheduleNextTick(const Duration(milliseconds: 35));
        } else {
          // Finished deleting, switch to next phrase and start typing
          _isDeleting = false;
          _currentPhraseIndex = (_currentPhraseIndex + 1) % _phrases.length;
          _scheduleNextTick(const Duration(milliseconds: 600));
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPhrase = _phrases[_currentPhraseIndex % _phrases.length];
    final displayedText = currentPhrase.substring(0, _charIndex.clamp(0, currentPhrase.length));

    final hasBangla = RegExp(r'[\u0980-\u09FF]').hasMatch(currentPhrase);
    final titleStyle = hasBangla
        ? TextStyle(
            fontFamily: 'NotoSansBengali',
            fontFamilyFallback: AppTextStyles.fallback,
            fontSize: AppSpacing.fontDisplay - 4,
            fontWeight: FontWeight.w800,
            color: AppColors.textOnDark,
            height: AppSpacing.lineHeightTight,
            letterSpacing: -0.2,
          )
        : AppTextStyles.display;

    // Measure or preserve stable container height to avoid layout shift
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 84),
        child: RichText(
          text: TextSpan(
            style: titleStyle,
            children: [
              TextSpan(text: displayedText),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: AnimatedOpacity(
                  opacity: _showCursor ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 120),
                  child: Container(
                    margin: const EdgeInsets.only(left: 3),
                    width: 7,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
