import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/numbers.dart';
import '../../../../core/widgets/surface_card.dart';

/// The last [count] readings, oldest → newest: upper (systolic) and lower
/// (diastolic) numbers as two lines, with dashed 120 / 80 guides.
class BpTrendChart extends StatelessWidget {
  const BpTrendChart({super.key, required this.readings});

  static const int count = 14;

  /// Newest first (as stored); the chart flips it.
  final List<BloodPressureReading> readings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final points = readings.take(count).toList().reversed.toList();
    return SurfaceCard(
      color: AppColors.cream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Legend(color: AppColors.accent, label: l10n.bpSystolicLegend),
              AppSpacing.gapLg,
              _Legend(color: AppColors.tileMint, label: l10n.bpDiastolicLegend),
            ],
          ),
          AppSpacing.gapMd,
          SizedBox(
            height: AppSpacing.bpChartHeight,
            width: double.infinity,
            child: CustomPaint(
              painter: _TrendPainter(
                systolic: [for (final r in points) r.systolic],
                diastolic: [for (final r in points) r.diastolic],
                guideStyle: AppTextStyles.captionOnLight,
                gridColor: AppColors.divider,
                format: (v) => AppNumber.format(v),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: AppSpacing.md,
        height: AppSpacing.xs,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
      ),
      AppSpacing.gapXs,
      Text(label, style: AppTextStyles.captionOnLight),
    ],
  );
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.systolic,
    required this.diastolic,
    required this.guideStyle,
    required this.gridColor,
    required this.format,
  });

  final List<int> systolic;
  final List<int> diastolic;
  final TextStyle guideStyle;
  final Color gridColor;
  final String Function(int) format;

  static const List<int> _guides = [80, 120];
  static const double _labelWidth = 28;

  @override
  void paint(Canvas canvas, Size size) {
    final all = [...systolic, ...diastolic, ..._guides];
    // A little headroom so dots don't touch the edges.
    final lo = (all.reduce(math.min) - 10).toDouble();
    final hi = (all.reduce(math.max) + 10).toDouble();
    final left = _labelWidth;
    final width = size.width - left;
    double y(num v) => size.height * (1 - (v - lo) / (hi - lo));
    double x(int i) => systolic.length == 1
        ? left + width / 2
        : left + width * i / (systolic.length - 1);

    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final g in _guides) {
      final gy = y(g);
      for (var dx = left; dx < size.width; dx += 8) {
        canvas.drawLine(Offset(dx, gy), Offset(dx + 4, gy), grid);
      }
      final label = TextPainter(
        text: TextSpan(text: format(g), style: guideStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(0, gy - label.height / 2));
    }

    void series(List<int> values, Color color) {
      final line = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final path = Path();
      for (var i = 0; i < values.length; i++) {
        final p = Offset(x(i), y(values[i]));
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, line);
      final dot = Paint()..color = color;
      for (var i = 0; i < values.length; i++) {
        canvas.drawCircle(Offset(x(i), y(values[i])), 3.5, dot);
      }
    }

    series(diastolic, AppColors.tileMint);
    series(systolic, AppColors.accent);
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.systolic != systolic || old.diastolic != diastolic;
}
