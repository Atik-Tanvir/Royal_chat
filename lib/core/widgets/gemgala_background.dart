import 'package:flutter/material.dart';

/// A luxury Royal Emerald ambient background with deep gradient depth and subtle starlight mesh.
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
        // Base Luxury Emerald Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF04221B), // Velvety rich dark emerald
                Color(0xFF07382D), // Deep royal jade
                Color(0xFF031A14), // Midnight emerald base
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),

        // Ambient Radial Glow 1 (Cyan/Mint top-right atmosphere)
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF10B981).withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Ambient Radial Glow 2 (Imperial Gold bottom-left glow)
        Positioned(
          bottom: 120,
          left: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFFD700).withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Subtle luxury micro-pattern overlay
        Positioned.fill(
          child: CustomPaint(
            painter: _RoyalMeshPainter(),
          ),
        ),

        // Foreground content with SafeArea
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

class _RoyalMeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = const Color(0xFF34D399).withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    const double spacing = 36.0;

    for (double y = 18; y < size.height; y += spacing) {
      for (double x = 18; x < size.width; x += spacing) {
        // Draw tiny subtle elegant dots
        canvas.drawCircle(Offset(x, y), 0.9, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
