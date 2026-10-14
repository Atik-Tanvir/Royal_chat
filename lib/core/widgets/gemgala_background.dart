import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A custom widget rendering the signature Gemgala checkered-diamond emerald background.
class GemgalaBackground extends StatelessWidget {
  final Widget child;

  const GemgalaBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.bgLightGreen,
                AppColors.bgMidGreen,
                AppColors.bgDarkGreen,
              ],
            ),
          ),
        ),
        // Subtle diamond pattern overlay
        Positioned.fill(
          child: CustomPaint(
            painter: _DiamondPatternPainter(),
          ),
        ),
        // Child content on top
        Positioned.fill(
          child: SafeArea(
            bottom: false,
            child: child,
          ),
        ),
      ],
    );
  }
}

class _DiamondPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final lightPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double tileSize = 56.0;
    const double half = tileSize / 2.0;

    for (double y = -tileSize; y < size.height + tileSize; y += tileSize) {
      for (double x = -tileSize; x < size.width + tileSize; x += tileSize) {
        final path = Path()
          ..moveTo(x + half, y)
          ..lineTo(x + tileSize, y + half)
          ..lineTo(x + half, y + tileSize)
          ..lineTo(x, y + half)
          ..close();

        // Alternate fill on checkerboard pattern
        final int col = (x / tileSize).round();
        final int row = (y / tileSize).round();
        if ((col + row) % 2 == 0) {
          canvas.drawPath(path, lightPaint);
        }
        canvas.drawPath(path, outlinePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
