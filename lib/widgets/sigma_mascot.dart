import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Маскот: растровый арт (кот с книгой и лампочкой). При отсутствии ассета — мягкий градиентный запасной вариант.
class SigmaMascot extends StatelessWidget {
  final double size;

  const SigmaMascot({super.key, this.size = 112});

  static const String _assetPath = 'assets/images/mascot.png';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: 'Котёнок SigmaCards',
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          _assetPath,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, error, stackTrace) {
            return CustomPaint(
              painter: _SoftKittenPainter(isDark: isDark),
            );
          },
        ),
      ),
    );
  }
}

/// Запасной вариант: только заливки и градиенты, без чёрной обводки.
class _SoftKittenPainter extends CustomPainter {
  _SoftKittenPainter({required this.isDark});

  final bool isDark;

  Color get _furLight => isDark ? const Color(0xFFE8A070) : const Color(0xFFFFB088);
  Color get _furMid => isDark ? const Color(0xFFD89060) : const Color(0xFFFF9A65);
  Color get _furDeep => isDark ? const Color(0xFFC07850) : const Color(0xFFE88850);
  Color get _cream => isDark ? const Color(0xFFFFE8D0) : const Color(0xFFFFF5EB);
  Color get _pink => const Color(0xFFFFB0B8);
  Color get _glass => const Color(0xFF2D6B4E);
  Color get _glassHi => const Color(0xFF4A9D72);
  Color get _eyeDark => const Color(0xFF4A3020);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // Тень под лапами
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.black.withValues(alpha: 0.18), Colors.transparent],
      ).createShader(Rect.fromCenter(center: Offset(cx, h * 0.92), width: w * 0.7, height: h * 0.14));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.93), width: w * 0.58, height: h * 0.09),
      shadowPaint,
    );

    // Тело
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, h * 0.72), width: w * 0.58, height: h * 0.26),
      Radius.circular(w * 0.1),
    );
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_furLight, _furMid, _furDeep],
      ).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, bodyPaint);

    // Голова
    final headCenter = Offset(cx, h * 0.38);
    final headR = w * 0.30;
    final headPaint = Paint()
      ..shader = RadialGradient(
        colors: [_furLight, _furMid, _furDeep],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: headCenter, radius: headR));
    canvas.drawCircle(headCenter, headR, headPaint);

    // Пятно на морде (мягкое)
    final muzzlePaint = Paint()
      ..shader = RadialGradient(
        colors: [_cream.withValues(alpha: 0.95), _cream.withValues(alpha: 0.4)],
      ).createShader(Rect.fromCenter(center: Offset(cx, h * 0.44), width: w * 0.36, height: h * 0.22));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.44), width: w * 0.34, height: h * 0.19),
      muzzlePaint,
    );

    // Уши
    void drawEar(double sign) {
      final earPath = Path()
        ..moveTo(cx + sign * w * 0.12, h * 0.18)
        ..lineTo(cx + sign * w * 0.30, h * 0.09)
        ..lineTo(cx + sign * w * 0.24, h * 0.26)
        ..close();
      final earPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_furDeep, _furMid],
        ).createShader(earPath.getBounds());
      canvas.drawPath(earPath, earPaint);
      final inner = Path()
        ..moveTo(cx + sign * w * 0.17, h * 0.18)
        ..lineTo(cx + sign * w * 0.26, h * 0.13)
        ..lineTo(cx + sign * w * 0.22, h * 0.23)
        ..close();
      canvas.drawPath(inner, Paint()..color = _pink.withValues(alpha: 0.85));
    }

    drawEar(-1);
    drawEar(1);

    // Очки (без обводки — полупрозрачные «стёкла» + дужка)
    final glassR = w * 0.11;
    final leftC = Offset(cx - w * 0.11, h * 0.34);
    final rightC = Offset(cx + w * 0.11, h * 0.34);
    Paint glassLens(Offset c) => Paint()
      ..shader = RadialGradient(
        colors: [_glassHi.withValues(alpha: 0.55), _glass.withValues(alpha: 0.75)],
      ).createShader(Rect.fromCircle(center: c, radius: glassR));
    canvas.drawCircle(leftC, glassR, glassLens(leftC));
    canvas.drawCircle(rightC, glassR, glassLens(rightC));
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, h * 0.34), width: w * 0.08, height: w * 0.025),
      Paint()..color = _glass.withValues(alpha: 0.9),
    );

    // Глаза (зрачки)
    canvas.drawCircle(Offset(cx - w * 0.11, h * 0.35), w * 0.045, Paint()..color = _eyeDark);
    canvas.drawCircle(Offset(cx + w * 0.11, h * 0.35), w * 0.045, Paint()..color = _eyeDark);
    canvas.drawCircle(Offset(cx - w * 0.09, h * 0.33), w * 0.014, Paint()..color = Colors.white.withValues(alpha: 0.9));
    canvas.drawCircle(Offset(cx + w * 0.13, h * 0.33), w * 0.014, Paint()..color = Colors.white.withValues(alpha: 0.9));

    // Нос
    final nose = Path()
      ..moveTo(cx, h * 0.42)
      ..lineTo(cx - w * 0.035, h * 0.47)
      ..lineTo(cx + w * 0.035, h * 0.47)
      ..close();
    canvas.drawPath(
      nose,
      Paint()
        ..shader = RadialGradient(
          colors: [_pink, _pink.withValues(alpha: 0.7)],
        ).createShader(nose.getBounds()),
    );

    // Улыбка — мягкая дуга (коричневая заливка, не чёрный контур)
    final smilePath = Path()
      ..moveTo(cx - w * 0.08, h * 0.50)
      ..quadraticBezierTo(cx, h * 0.56, cx + w * 0.08, h * 0.50);
    canvas.drawPath(
      smilePath,
      Paint()
        ..color = _furDeep.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, w * 0.022)
        ..strokeCap = StrokeCap.round,
    );

    // Лапки
    void paw(double dx) {
      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + dx, h * 0.86), width: w * 0.14, height: h * 0.09),
        Radius.circular(w * 0.05),
      );
      canvas.drawRRect(
        r,
        Paint()
          ..shader = LinearGradient(
            colors: [_cream, _cream.withValues(alpha: 0.85)],
          ).createShader(r.outerRect),
      );
    }

    paw(-w * 0.14);
    paw(w * 0.14);

    // Хвост — мягкий градиентный «трубчатый» штрих
    final tailPath = Path()
      ..moveTo(cx + w * 0.22, h * 0.65)
      ..quadraticBezierTo(cx + w * 0.46, h * 0.52, cx + w * 0.42, h * 0.78);
    canvas.drawPath(
      tailPath,
      Paint()
        ..shader = LinearGradient(
          colors: [_furDeep, _furMid],
        ).createShader(tailPath.getBounds())
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.095
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SoftKittenPainter oldDelegate) => oldDelegate.isDark != isDark;
}
