import 'package:flutter/material.dart';
import 'package:tenkai/core/design_system/tenkai.dart';

import '../models/book_enums.dart';
import '../models/book_view.dart';

/// A small pace chart: the straight "expected" line (from the deadline or daily
/// goal) vs the actual reading progress line, with the area between tinted by
/// whether the reader is ahead or behind. Animates the actual line on build.
class BookPaceChart extends StatelessWidget {
  const BookPaceChart({super.key, required this.view, this.height = 150});

  final BookView view;
  final double height;

  Color get _paceColor => switch (view.paceState) {
    PaceState.ahead => TenkaiColors.success,
    PaceState.onTrack => TenkaiColors.success,
    PaceState.behind => TenkaiColors.warning,
    PaceState.finished => TenkaiColors.success,
    PaceState.noTarget => TenkaiColors.white,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: TenkaiDuration.glow,
        curve: TenkaiCurves.spring,
        builder: (_, t, __) => CustomPaint(
          painter: _PacePainter(view: view, paceColor: _paceColor, t: t),
        ),
      ),
    );
  }
}

class _PacePainter extends CustomPainter {
  _PacePainter({
    required this.view,
    required this.paceColor,
    required this.t,
  });

  final BookView view;
  final Color paceColor;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    const padL = 8.0, padR = 8.0, padT = 12.0, padB = 12.0;
    final w = size.width - padL - padR;
    final h = size.height - padT - padB;
    final maxPage = view.book.totalPages <= 0
        ? 1.0
        : view.book.totalPages.toDouble();
    final span = view.spanDays <= 0 ? 1.0 : view.spanDays;

    Offset toPx(BookChartPoint p) => Offset(
      padL + (p.day / span).clamp(0.0, 1.0) * w,
      padT + (1 - (p.page / maxPage).clamp(0.0, 1.0)) * h,
    );

    // Baseline + top gridline.
    final grid = Paint()
      ..color = TenkaiColors.gray800
      ..strokeWidth = 0.5;
    canvas.drawLine(
      Offset(padL, padT + h),
      Offset(padL + w, padT + h),
      grid,
    );
    canvas.drawLine(Offset(padL, padT), Offset(padL + w, padT), grid);

    // Expected line (thin, gray).
    if (view.expectedPoints.length == 2) {
      final a = toPx(view.expectedPoints[0]);
      final b = toPx(view.expectedPoints[1]);
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = TenkaiColors.gray500
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round,
      );
    }

    // "Today" vertical marker.
    final todayX = padL + (view.todayDay / span).clamp(0.0, 1.0) * w;
    canvas.drawLine(
      Offset(todayX, padT),
      Offset(todayX, padT + h),
      Paint()
        ..color = TenkaiColors.gray700
        ..strokeWidth = 0.5,
    );

    // Actual progress line + area fill.
    final pts = view.actualPoints.map(toPx).toList();
    if (pts.length >= 2) {
      final line = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (var i = 1; i < pts.length; i++) {
        line.lineTo(pts[i].dx, pts[i].dy);
      }

      // Animated reveal via path metrics.
      final metric = line.computeMetrics().first;
      final shown = metric.extractPath(0, metric.length * t);

      // Area under the shown portion.
      final endPt = pts[_indexForT(pts, t)];
      final area = Path.from(shown)
        ..lineTo(endPt.dx, padT + h)
        ..lineTo(pts.first.dx, padT + h)
        ..close();
      canvas.drawPath(
        area,
        Paint()..color = paceColor.withOpacity(0.10),
      );

      canvas.drawPath(
        shown,
        Paint()
          ..color = paceColor
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // Glow dot at the current end.
      canvas.drawCircle(
        endPt,
        3.5,
        Paint()..color = paceColor,
      );
      canvas.drawCircle(
        endPt,
        3.5,
        Paint()
          ..color = paceColor.withOpacity(0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
  }

  int _indexForT(List<Offset> pts, double t) {
    final idx = (pts.length * t).floor().clamp(0, pts.length - 1);
    return idx;
  }

  @override
  bool shouldRepaint(_PacePainter old) =>
      old.t != t || old.view != view || old.paceColor != paceColor;
}
