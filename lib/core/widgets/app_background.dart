// background.dart
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class AppBackground extends StatefulWidget {
  const AppBackground({super.key});

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;

  final List<_Particle> _particles = [];
  final Random _rnd = Random();

  Offset _pointer = Offset.zero;
  double _parallaxX = 0.0;
  double _parallaxY = 0.0;

  // Charcoal tones (medium contrast)
  final Color charcoal1 = const Color(0xFF222222);
  final Color charcoal2 = const Color(0xFF2E2E2E);
  final Color charcoal3 = const Color(0xFF1A1A1A);

  // safety helper
  double _safe(double v) => v.isFinite ? v : 0.0;

  @override
  void initState() {
    super.initState();

    // duration-based controller (repeat valid)
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(_onTick);

    // initialize particles (positions will be clamped at paint time)
    for (int i = 0; i < 30; i++) {
      _particles.add(_Particle.random(_rnd));
    }

    // start animation after first frame (safe layout)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ticker.repeat();
    });
  }

  void _onTick() {
    // safe time value (avoid null)
    final time = (_ticker.lastElapsedDuration?.inMilliseconds ?? 0).toDouble();

    // update particles
    for (var p in _particles) {
      p.update(time, _rnd);
    }

    // cleanup dead
    _particles.removeWhere((p) => p.dead);

    // refill pool if needed
    if (_particles.length < 20) {
      _particles.add(_Particle.random(_rnd));
    }

    // single setState per tick -> no flicker
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  // pointer update from mouse/touch, safe-clamped
  void _updatePointer(Offset localPos) {
    final s = context.size;
    if (s == null || s.width <= 0 || s.height <= 0) return;

    final dx = ((localPos.dx.clamp(0.0, s.width) / s.width) - 0.5) * 2.0;
    final dy = ((localPos.dy.clamp(0.0, s.height) / s.height) - 0.5) * 2.0;

    // clamp to [-1,1]
    _pointer = Offset(dx.clamp(-1.0, 1.0), dy.clamp(-1.0, 1.0));

    // update parallax safely and clamp to finite values
    _parallaxX = _safe(
      _parallaxX + (_pointer.dx - _parallaxX) * 0.05,
    ).clamp(-1.0, 1.0);
    _parallaxY = _safe(
      _parallaxY + (_pointer.dy - _parallaxY) * 0.05,
    ).clamp(-1.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    // pass safe time to painter
    final time = (_ticker.lastElapsedDuration?.inMilliseconds ?? 0).toDouble();

    // Use SizedBox.expand to give CustomPaint finite constraints and avoid layout errors
    return Listener(
      onPointerHover: (e) => _updatePointer(e.localPosition),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) => _updatePointer(d.localPosition),
        onTapDown: (d) {
          // small burst on tap
          for (int i = 0; i < 12; i++) {
            _particles.add(_Particle.burst(d.localPosition, _rnd));
          }
        },
        child: SizedBox.expand(
          child: CustomPaint(
            painter: _NeonPainter(
              particles: _particles,
              time: time,
              px: _parallaxX,
              py: _parallaxY,
              c1: charcoal1,
              c2: charcoal2,
              c3: charcoal3,
            ),
            isComplex: true,
            willChange: true,
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// PAINTER - hardened to avoid any NaN/invalid gradients
////////////////////////////////////////////////////////////////////////////////////////////////////

class _NeonPainter extends CustomPainter {
  final List<_Particle> particles;
  final double time;
  final double px;
  final double py;
  final Color c1;
  final Color c2;
  final Color c3;

  _NeonPainter({
    required this.particles,
    required this.time,
    required this.px,
    required this.py,
    required this.c1,
    required this.c2,
    required this.c3,
  });

  // clamp a point inside the canvas bounds
  Offset _clampOffset(Offset p, Size s) {
    final dx = p.dx.isFinite ? p.dx.clamp(0.0, s.width) : (s.width * 0.5);
    final dy = p.dy.isFinite ? p.dy.clamp(0.0, s.height) : (s.height * 0.5);
    return Offset(dx, dy);
  }

  // ensure radius is finite and not zero
  double _safeRadius(double r, Size s) {
    final rr = r.isFinite ? r : s.shortestSide * 0.1;
    return rr.clamp(8.0, max(8.0, s.longestSide));
  }

  @override
  void paint(Canvas canvas, Size size) {
    // guard early
    if (size.width <= 0 || size.height <= 0) return;

    // background: white
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    // parallax offsets scaled to pixels (safe finite values)
    final pxOff = (px.isFinite ? px : 0.0) * 12.0;
    final pyOff = (py.isFinite ? py : 0.0) * 12.0;

    _drawWaves(canvas, size, pxOff, pyOff);
    _drawOrbs(canvas, size, pxOff, pyOff);
    _drawParticles(canvas, size);
    _drawVignette(canvas, size);
  }

  void _drawWaves(Canvas c, Size s, double pxOff, double pyOff) {
    _drawWave(c, s, s.height * 0.30 + pyOff, 26.0, 0.0006, c1);
    _drawWave(c, s, s.height * 0.50 + (pyOff * 1.2), 38.0, 0.00045, c2);
    _drawWave(c, s, s.height * 0.72 + (pyOff * 1.5), 20.0, 0.00085, c3);
  }

  void _drawWave(
    Canvas c,
    Size s,
    double oy,
    double amp,
    double speed,
    Color color,
  ) {
    final path = Path();
    const steps = 140;

    // ensure oy finite
    final baseOy = oy.isFinite ? oy : s.height * 0.5;

    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final x = (t * s.width).clamp(0.0, s.width);
      final wave1 = sin((time * speed) + t * 4.0) * amp;
      final wave2 = cos((time * speed * 1.3) + t * 2.0) * amp * 0.28;
      final pulse = sin(time * 0.00035) * 3.5;
      final y = baseOy + wave1 + wave2 + pulse;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // blurred glow
    c.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = color.withOpacity(0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // thin crisp
    c.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = color.withOpacity(0.38),
    );
  }

  void _drawOrbs(Canvas c, Size s, double pxOff, double pyOff) {
    // radius safe
    final radius = _safeRadius(s.width * 0.14, s);

    final rawPositions = [
      Offset(s.width * 0.18 + pxOff, s.height * 0.22 + pyOff),
      Offset(s.width * 0.82 + pxOff * 0.9, s.height * 0.26 + pyOff * 0.9),
      Offset(s.width * 0.30 + pxOff * 0.5, s.height * 0.75 + pyOff * 1.2),
    ];

    final colors = [
      c1.withOpacity(0.10),
      c2.withOpacity(0.08),
      c3.withOpacity(0.07),
    ];

    for (int i = 0; i < rawPositions.length; i++) {
      final p = _clampOffset(rawPositions[i], s);
      final r = _safeRadius(radius, s);

      // safe radial gradient (explicit stops, clamped center and radius)
      final shader = ui.Gradient.radial(
        p,
        r,
        [colors[i], Colors.transparent],
        [0.0, 1.0],
      );

      c.drawCircle(p, r, Paint()..shader = shader);
    }
  }

  void _drawParticles(Canvas c, Size s) {
    // render particles; ignore those with invalid pos
    c.saveLayer(Offset.zero & s, Paint());
    for (var p in particles) {
      final px = (p.pos.dx.isFinite ? p.pos.dx : s.width * 0.5).clamp(
        0.0,
        s.width,
      );
      final py = (p.pos.dy.isFinite ? p.pos.dy : s.height * 0.5).clamp(
        0.0,
        s.height,
      );
      final pos = Offset(px, py);

      final scaledSize = (p.size.isFinite ? p.size : 2.0).clamp(0.5, 36.0);
      final alpha = (p.alpha.isFinite ? p.alpha : 0.0).clamp(0.0, 1.0);

      c.drawCircle(
        pos,
        scaledSize,
        Paint()
          ..color = p.color.withOpacity(alpha * 0.7)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, scaledSize),
      );
    }
    c.restore();
  }

  void _drawVignette(Canvas c, Size s) {
    final radius = _safeRadius(max(s.width, s.height), s);

    final shader = ui.Gradient.radial(
      Offset(s.width * 0.5, s.height * 0.5),
      radius,
      [Colors.transparent, Colors.black.withOpacity(0.08)],
      [0.0, 1.0],
    );

    c.drawRect(Offset.zero & s, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _NeonPainter old) => true;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// PARTICLE MODEL
////////////////////////////////////////////////////////////////////////////////////////////////////

class _Particle {
  Offset pos;
  Offset vel;
  double size;
  double birth;
  double life;
  double alpha;
  Color color;
  bool dead = false;

  _Particle({
    required this.pos,
    required this.vel,
    required this.size,
    required this.birth,
    required this.life,
    required this.alpha,
    required this.color,
  });

  static _Particle random(Random r) {
    final now = DateTime.now().millisecondsSinceEpoch.toDouble();
    return _Particle(
      pos: Offset(r.nextDouble() * 800, r.nextDouble() * 800),
      vel: Offset((r.nextDouble() - 0.5) * 0.4, (r.nextDouble() - 0.5) * 0.4),
      size: 2 + r.nextDouble() * 6,
      birth: now,
      life: 6000 + r.nextDouble() * 8000,
      alpha: 1.0,
      color: const Color(0xFF1A1A1A),
    );
  }

  static _Particle burst(Offset origin, Random r) {
    final now = DateTime.now().millisecondsSinceEpoch.toDouble();
    final ang = r.nextDouble() * pi * 2.0;
    final spd = 0.6 + r.nextDouble() * 3.0;
    return _Particle(
      pos: origin,
      vel: Offset(cos(ang) * spd, sin(ang) * spd),
      size: 2.0 + r.nextDouble() * 5.0,
      birth: now,
      life: 300 + r.nextDouble() * 800,
      alpha: 1.0,
      color: const Color(0xFF222222),
    );
  }

  void update(double time, Random r) {
    // guard values
    if (!pos.dx.isFinite || !pos.dy.isFinite) {
      pos = Offset(0.0, 0.0);
    }

    pos = Offset(pos.dx + vel.dx * 0.6, pos.dy + vel.dy * 0.6);

    // gentle random drift
    vel = Offset(
      vel.dx + (r.nextDouble() - 0.5) * 0.01,
      vel.dy + (r.nextDouble() - 0.5) * 0.01,
    );

    final age = time - birth;
    if (age > life) {
      dead = true;
    } else {
      alpha = (1.0 - (age / life)).clamp(0.0, 1.0);
    }
  }
}
