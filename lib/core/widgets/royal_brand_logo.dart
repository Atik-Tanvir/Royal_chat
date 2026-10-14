import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class RoyalBrandLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final TextStyle? titleStyle;

  const RoyalBrandLogo({
    super.key,
    this.size = 36.0,
    this.showText = false,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.gemEmerald.withValues(alpha: 0.25),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: AppColors.goldCoin.withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/royal_chat_logo_transparent.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback if asset isn't ready
          return Icon(
            Icons.workspace_premium_rounded,
            size: size * 0.8,
            color: AppColors.goldCoin,
          );
        },
      ),
    );

    if (!showText) {
      return imageWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        imageWidget,
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFFFDF00),
                  Color(0xFFF59E0B),
                  Color(0xFF34D399),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'Royal Chat',
                style: titleStyle ??
                    const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'LIVE PARTY',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Color(0xFF6EE7B7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
