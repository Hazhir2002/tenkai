import 'package:flutter/material.dart';
import 'package:tenkai/core/theme/tenkai_semantic_colors.dart';
import 'package:tenkai/core/tokens/tenkai_curves.dart';
import 'package:tenkai/core/tokens/tenkai_duration.dart';
import 'package:tenkai/core/tokens/tenkai_typography.dart';
import 'package:tenkai/features/goal_tracker/models/goal.dart';
import 'package:tenkai/features/goal_tracker/models/goal_log.dart';
import 'package:tenkai/features/goal_tracker/widgets/goal_ui.dart';

/// A pace chart: the straight "expected" line (initial → target across the
/// schedule) vs the actual logged-value line, with the area under the actual
/// line tinted by the goal's pace. Animates the actual line on build.
///
/// Falls back to a hint when there isn't enough history to draw a trend.
class GoalPaceChart extends StatelessWidget {
  const GoalPaceChart({
    super.key,
    required this.goal,
    required this.logs,
    this.height = 160,
  });

  final Goal goal;
  final List<GoalLog> logs;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    if (logs.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            logs.isEmpty
                ? 'Log a value to start your trend'
                : 'Log another value to see your pace',
            style: TenkaiTypography.bodySmall.copyWith(
              color: c.secondaryForeground,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: TenkaiDuration.glow,
        curve: TenkaiCurves.spring,
        builder: (_, t, __) => CustomPaint(
          painter: _GoalPacePainter(
            goal: goal,
            logs: logs,
            t: t,
            gridColor: c.border,
            guideColor: c.secondaryForeground,
            todayColor: c.border,
          ),
        ),
      ),
    );
  }
}

class _GoalPacePainter extends CustomPainter {
  _GoalPacePainter({
    required this.goal,
    required this.logs,
    required this.t,
    required this.gridColor,
    required this.guideColor,
    required this.todayColor,
  });

  final Goal goal;
  final List<GoalLog> logs;
  final double t;
  final Color gridColor;
  final Color guideColor;
  final Color todayColor;

  @override
  void paint(Canvas canvas, Size size) {
    const padL = 8.0, padR = 8.0, padT = 12.0, padB = 12.0;
    final w = size.width - padL - padR;
    final h = size.height - padT - padB;

    final hasSchedule = goal.startDate != null && goal.endDate != null;
    final firstLog = logs.first.loggedAt;
    final lastLog = logs.last.loggedAt;

    final xStart = goal.startDate ?? firstLog;
    var xEnd = goal.endDate ?? lastLog;
    var startMs = xStart.millisecondsSinceEpoch.toDouble();
    var endMs = xEnd.millisecondsSinceEpoch.toDouble();
    if (endMs <= startMs) endMs = startMs + 1;

    // Value axis spans everything we plot so nothing clips out of frame.
    final values = <double>[
      goal.initialValue,
      goal.targetValue,
      ...logs.map((l) => l.value),
    ];
    var yLow = values.reduce((a, b) => a < b ? a : b);
    var yHigh = values.reduce((a, b) => a > b ? a : b);
    if (yHigh <= yLow) yHigh = yLow + 1;
    final pad = (yHigh - yLow) * 0.08;
    yLow -= pad;
    yHigh += pad;

    Offset toPx(DateTime time, double value) {
      final x =
          (time.millisecondsSinceEpoch.toDouble() - startMs) /
          (endMs - startMs);
      final y = (value - yLow) / (yHigh - yLow);
      return Offset(
        padL + x.clamp(0.0, 1.0) * w,
        padT + (1 - y.clamp(0.0, 1.0)) * h,
      );
    }

    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;
    canvas.drawLine(Offset(padL, padT + h), Offset(padL + w, padT + h), grid);
    canvas.drawLine(Offset(padL, padT), Offset(padL + w, padT), grid);

    // Expected line (initial → target across the schedule).
    if (hasSchedule) {
      final a = toPx(goal.startDate!, goal.initialValue);
      final b = toPx(goal.endDate!, goal.targetValue);
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = guideColor
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round,
      );

      // "Today" marker.
      final now = DateTime.now();
      if (now.isAfter(xStart) && now.isBefore(xEnd)) {
        final todayX = toPx(now, goal.initialValue).dx;
        canvas.drawLine(
          Offset(todayX, padT),
          Offset(todayX, padT + h),
          Paint()
            ..color = todayColor
            ..strokeWidth = 0.5,
        );
      }
    }

    // Actual logged-value line + area fill, colored by pace.
    final paceColor = goal.pace.color;
    final pts = logs.map((l) => toPx(l.loggedAt, l.value)).toList();
    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      line.lineTo(pts[i].dx, pts[i].dy);
    }

    final metric = line.computeMetrics().first;
    final shown = metric.extractPath(0, metric.length * t);

    final endPt = pts[(pts.length * t).floor().clamp(0, pts.length - 1)];
    final area = Path.from(shown)
      ..lineTo(endPt.dx, padT + h)
      ..lineTo(pts.first.dx, padT + h)
      ..close();
    canvas.drawPath(area, Paint()..color = paceColor.withOpacity(0.10));

    canvas.drawPath(
      shown,
      Paint()
        ..color = paceColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawCircle(endPt, 3.5, Paint()..color = paceColor);
  }

  @override
  bool shouldRepaint(_GoalPacePainter old) =>
      old.t != t ||
      old.goal != goal ||
      old.logs != logs ||
      old.gridColor != gridColor ||
      old.guideColor != guideColor ||
      old.todayColor != todayColor;
}
