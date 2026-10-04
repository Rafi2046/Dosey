import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/numbers.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/sugar_category.dart';

/// The last [count] readings, oldest → newest, over a shaded 3.9–7.8 mmol/L
/// band (in range for most of the day). Dots take their category's colour.
class SugarTrendChart extends StatelessWidget {
  const SugarTrendChart({super.key, required this.readings});

  static const int count = 14;

  /// Newest first (as stored); the chart flips it.
  final List<BloodSugarReading> readings;

  @override
  Widget build(BuildContext context) {
    final points = readings.take(count).toList().reversed.toList();
    return SurfaceCard(
      color: AppColors.cream,
      child: SizedBox(
        height: AppSpacing.bpChartHeight,
        width: double.infinity,
        child: CustomPaint(
          painter: _SugarPainter(
            values: [for (final r in points) r.mmol],
            colors: [
              for (final r in points) SugarCategory.of(r.mmol, r.context).color,
            ],
            labelStyle: AppTextStyles.captionOnLight,
            bandColor: AppColors.tileMint.withValues(alpha: 0.15),
            lineColor: AppColors.inkMuted,
          ),
        ),
      ),
    );
  }
}

class _SugarPainter extends CustomPainter {
  _SugarPainter({
    required this.values,
    required this.colors,
    required this.labelStyle,
    required this.bandColor,
    required this.lineColor,
  });

  final List<double> values;
  final List<Color> colors;
  final TextStyle labelStyle;
  final Color bandColor;
  final Color lineColor;

  static const double _bandLow = 3.9;
  static const double _bandHigh = 7.8;
  static const double _labelWidth = 28;

  @override
  void paint(Canvas canvas, Size size) {
    final all = [...values, _bandLow, _bandHigh];
    final lo = math.max(0.0, all.reduce(math.min) - 1);
    final hi = all.reduce(math.max) + 1;
    final left = _labelWidth;
    final width = size.width - left;
    double y(double v) => size.height * (1 - (v - lo) / (hi - lo));
    double x(int i) => values.length == 1
        ? left + width / 2
        : left + width * i / (values.length - 1);

    canvas.drawRect(
      Rect.fromLTRB(left, y(_bandHigh), size.width, y(_bandLow)),
      Paint()..color = bandColor,
    );
    for (final g in [_bandLow, _bandHigh]) {
      final label = TextPainter(
        text: TextSpan(text: AppNumber.format(g), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(0, y(g) - label.height / 2));
    }

    final line = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final p = Offset(x(i), y(values[i]));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, line);
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(
        Offset(x(i), y(values[i])),
        4.5,
        Paint()..color = colors[i],
      );
    }
  }

  @override
  bool shouldRepaint(_SugarPainter old) => old.values != values;
}
