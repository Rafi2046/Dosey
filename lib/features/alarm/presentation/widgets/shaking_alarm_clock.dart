import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';

/// The alarm-clock illustration, gently rattling while the alarm rings.
class ShakingAlarmClock extends StatefulWidget {
  const ShakingAlarmClock({
    super.key,
    this.height = AppSpacing.alarmIllustration,
  });

  final double height;

  @override
  State<ShakingAlarmClock> createState() => _ShakingAlarmClockState();
}

class _ShakingAlarmClockState extends State<ShakingAlarmClock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppSpacing.alarmShake,
  )..repeat(reverse: true);

  late final Animation<double> _turns = Tween<double>(
    begin: -AppSpacing.alarmShakeTurns,
    end: AppSpacing.alarmShakeTurns,
  ).chain(CurveTween(curve: Curves.elasticInOut)).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _turns,
      child: Image.asset(
        AppImages.alarmClock,
        height: widget.height,
        fit: BoxFit.contain,
      ),
    );
  }
}
