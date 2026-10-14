import 'package:flutter/material.dart';

class CatMascotWidget extends StatelessWidget {
  final double size;
  final bool withHat;

  const CatMascotWidget({
    super.key,
    this.size = 80,
    this.withHat = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CatMascotPainter(withHat: withHat),
      ),
    );
  }
}

class _CatMascotPainter extends CustomPainter {
  final bool withHat;

  _CatMascotPainter({required this.withHat});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + (withHat ? size.height * 0.08 : 0));
    final radius = size.width * 0.40;

    // Cat face fill (pure white/creamy)
    final facePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Cat stroke outline
    final strokePaint = Paint()
      ..color = const Color(0xFF1E3A34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.035
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Ears path
    final earPath = Path();
    // Left ear
    earPath.moveTo(center.dx - radius * 0.85, center.dy - radius * 0.3);
    earPath.lineTo(center.dx - radius * 0.95, center.dy - radius * 0.95);
    earPath.lineTo(center.dx - radius * 0.35, center.dy - radius * 0.75);
    // Right ear
    earPath.moveTo(center.dx + radius * 0.35, center.dy - radius * 0.75);
    earPath.lineTo(center.dx + radius * 0.95, center.dy - radius * 0.95);
    earPath.lineTo(center.dx + radius * 0.85, center.dy - radius * 0.3);

    canvas.drawPath(earPath, facePaint);
    canvas.drawPath(earPath, strokePaint);

    // Inner pink ears
    final pinkEarPaint = Paint()
      ..color = const Color(0xFFFFB4C8)
      ..style = PaintingStyle.fill;
    final leftInnerEar = Path()
      ..moveTo(center.dx - radius * 0.8, center.dy - radius * 0.35)
      ..lineTo(center.dx - radius * 0.88, center.dy - radius * 0.85)
      ..lineTo(center.dx - radius * 0.45, center.dy - radius * 0.7)
      ..close();
    canvas.drawPath(leftInnerEar, pinkEarPaint);

    final rightInnerEar = Path()
      ..moveTo(center.dx + radius * 0.45, center.dy - radius * 0.7)
      ..lineTo(center.dx + radius * 0.88, center.dy - radius * 0.85)
      ..lineTo(center.dx + radius * 0.8, center.dy - radius * 0.35)
      ..close();
    canvas.drawPath(rightInnerEar, pinkEarPaint);

    // Head circle / oval
    final headRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawOval(headRect, facePaint);
    canvas.drawOval(headRect, strokePaint);

    // Closed happy eyes (^ ^)
    final eyePaint = Paint()
      ..color = const Color(0xFF1E3A34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;

    final leftEye = Path()
      ..moveTo(center.dx - radius * 0.55, center.dy - radius * 0.05)
      ..quadraticBezierTo(center.dx - radius * 0.4, center.dy - radius * 0.25, center.dx - radius * 0.25, center.dy - radius * 0.05);
    canvas.drawPath(leftEye, eyePaint);

    final rightEye = Path()
      ..moveTo(center.dx + radius * 0.25, center.dy - radius * 0.05)
      ..quadraticBezierTo(center.dx + radius * 0.4, center.dy - radius * 0.25, center.dx + radius * 0.55, center.dy - radius * 0.05);
    canvas.drawPath(rightEye, eyePaint);

    // Rosy pink cheeks
    final cheekPaint = Paint()
      ..color = const Color(0xFFFF9EAA).withOpacity(0.65)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - radius * 0.55, center.dy + radius * 0.2), radius * 0.16, cheekPaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.55, center.dy + radius * 0.2), radius * 0.16, cheekPaint);

    // Mouth (:3 style or tongue)
    final mouthPath = Path()
      ..moveTo(center.dx - radius * 0.2, center.dy + radius * 0.2)
      ..quadraticBezierTo(center.dx - radius * 0.1, center.dy + radius * 0.3, center.dx, center.dy + radius * 0.2)
      ..quadraticBezierTo(center.dx + radius * 0.1, center.dy + radius * 0.3, center.dx + radius * 0.2, center.dy + radius * 0.2);
    canvas.drawPath(mouthPath, eyePaint);

    // Whiskers
    final whiskerPaint = Paint()
      ..color = const Color(0xFF1E3A34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.025
      ..strokeCap = StrokeCap.round;

    // Left whiskers
    canvas.drawLine(Offset(center.dx - radius * 0.65, center.dy + radius * 0.05), Offset(center.dx - radius * 0.95, center.dy), whiskerPaint);
    canvas.drawLine(Offset(center.dx - radius * 0.65, center.dy + radius * 0.2), Offset(center.dx - radius * 0.95, center.dy + radius * 0.22), whiskerPaint);

    // Right whiskers
    canvas.drawLine(Offset(center.dx + radius * 0.65, center.dy + radius * 0.05), Offset(center.dx + radius * 0.95, center.dy), whiskerPaint);
    canvas.drawLine(Offset(center.dx + radius * 0.65, center.dy + radius * 0.2), Offset(center.dx + radius * 0.95, center.dy + radius * 0.22), whiskerPaint);

    // Optional stylish bowler hat (like Screenshot 1!)
    if (withHat) {
      final hatPaint = Paint()
        ..color = const Color(0xFF222831)
        ..style = PaintingStyle.fill;
      final hatRibbonPaint = Paint()
        ..color = const Color(0xFFFF5252)
        ..style = PaintingStyle.fill;

      // Brim
      final brimRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + radius * 0.2, center.dy - radius * 0.8),
          width: radius * 1.0,
          height: radius * 0.25,
        ),
        const Radius.circular(8),
      );
      canvas.drawRRect(brimRect, hatPaint);

      // Crown
      final crownRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + radius * 0.2, center.dy - radius * 1.05),
          width: radius * 0.65,
          height: radius * 0.45,
        ),
        const Radius.circular(10),
      );
      canvas.drawRRect(crownRect, hatPaint);

      // Ribbon
      final ribbonRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + radius * 0.2, center.dy - radius * 0.92),
          width: radius * 0.66,
          height: radius * 0.12,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(ribbonRect, hatRibbonPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
