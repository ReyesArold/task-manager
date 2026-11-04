import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A lively animated background with softly drifting colored glow blobs.
///
/// Draws translucent radial-gradient orbs that slowly float across a base
/// color, giving the app a dynamic, living backdrop. Works in both light and
/// dark mode. Set [GlowBackground.animate] to `false` to render a static
/// frame (used by widget tests so `pumpAndSettle` can finish).
class GlowBackground extends StatefulWidget {
  const GlowBackground({super.key, required this.child});

  final Widget child;

  /// Master switch for the looping motion. Disable in tests/static builds.
  static bool animate = true;

  @override
  State<GlowBackground> createState() => _GlowBackgroundState();
}

class _GlowBackgroundState extends State<GlowBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  );

  @override
  void initState() {
    super.initState();
    if (GlowBackground.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _GlowPainter(t: _controller.value, isDark: isDark),
            ),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter({required this.t, required this.isDark});

  final double t;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final base = Paint()
      ..color = isDark ? const Color(0xFF0A0E21) : const Color(0xFFE9F1FF);
    canvas.drawRect(Offset.zero & size, base);

    double px(double fx) => w * fx;
    double py(double fy) => h * fy;

    void blob(
      Color color,
      double fx,
      double fy,
      double radius,
      double amp,
      double speed,
      double phase,
    ) {
      final dx = px(fx + amp * math.sin(2 * math.pi * (t * speed + phase)));
      final dy = py(fy + amp * 0.7 * math.sin(2 * math.pi * (t * speed * 0.8 + phase * 1.7)));
      final p = Paint()
        ..shader = ui.Gradient.radial(
          Offset(dx, dy),
          radius,
          [
            color.withValues(alpha: isDark ? 0.50 : 0.34),
            color.withValues(alpha: isDark ? 0.30 : 0.16),
            color.withValues(alpha: 0.0),
          ],
          [0.0, 0.55, 1.0],
        );
      canvas.drawCircle(Offset(dx, dy), radius, p);
    }

    final r = math.max(w, h) * 0.55;
    blob(const Color(0xFF3B82F6), 0.15, -0.10, r, 0.06, 1.0, 0.00);
    blob(const Color(0xFF8B5CF6), 0.85, 0.10, r * 0.92, 0.05, 0.8, 0.35);
    blob(const Color(0xFFEC4899), 0.90, 0.78, r * 0.85, 0.05, 0.6, 0.20);
    blob(const Color(0xFF14B8A6), 0.02, 0.88, r * 0.80, 0.06, 0.9, 0.60);
    blob(const Color(0xFF6366F1), 0.50, 0.50, r * 0.95, 0.04, 0.5, 0.12);

    for (var i = 0; i < 10; i++) {
      final ox = ((i * 0.107) % 1.0) + 0.03 * math.sin(2 * math.pi * (t * 0.5 + i));
      final oy = ((i * 0.157 + 0.29) % 1.0) + 0.03 * math.cos(2 * math.pi * (t * 0.42 + i));
      final or = 8.0 + (i % 3) * 6.0;
      final color = (i.isEven ? const Color(0xFF93C5FD) : const Color(0xFFE9D5FF));
      canvas.drawCircle(
        Offset(px(ox), py(oy)),
        or,
        Paint()
          ..color = color.withValues(alpha: isDark ? 0.45 : 0.30),
      );
    }

    if (isDark) {
      final vignette = Paint()
        ..shader = ui.Gradient.radial(
          Offset(w / 2, h / 2),
          math.max(w, h) * 0.78,
          [
            const Color(0x00000000),
            const Color(0x66050812),
          ],
        );
      canvas.drawRect(Offset.zero & size, vignette);
    }
  }

  @override
  bool shouldRepaint(covariant _GlowPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.isDark != isDark;
}