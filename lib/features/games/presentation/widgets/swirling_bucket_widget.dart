import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/bucket_game_item.dart';

/// Unified payload for revealing a winning item OR a winning color + name inside the bucket.
class BucketRevealBadge {
  final String label;
  final String? icon;
  final Color accentColor;
  final List<Color>? colorSwatch;

  const BucketRevealBadge({
    required this.label,
    required this.accentColor,
    this.icon,
    this.colorSwatch,
  });
}

/// Visual theme separating Game #1 (Ocean/Gold Bucket) from Game #2 (Neon Tricolor Cauldron).
enum BucketVisualTheme {
  aquaGold,
  tricolorNeon,
}

/// Center animated Bucket/Bowl filled with continuously swirling multi-color water.
/// Shows a glowing floating `❓` while counting down, and rises the winning item/color
/// with its name up from the water after 35 seconds.
class SwirlingBucketWidget extends StatefulWidget {
  final bool isUrgentSpin; // True in last 5 seconds or revealing
  final BucketGameItem? revealedItem;
  final BucketRevealBadge? revealBadge;
  final BucketVisualTheme theme;
  final double size;

  const SwirlingBucketWidget({
    super.key,
    this.isUrgentSpin = false,
    this.revealedItem,
    this.revealBadge,
    this.theme = BucketVisualTheme.aquaGold,
    this.size = 152,
  });

  @override
  State<SwirlingBucketWidget> createState() => _SwirlingBucketWidgetState();
}

class _SwirlingBucketWidgetState extends State<SwirlingBucketWidget>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _colorShiftController;
  late AnimationController _pulseController;
  late AnimationController _revealController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _colorShiftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  BucketRevealBadge? get _effectiveBadge {
    if (widget.revealBadge != null) return widget.revealBadge;
    if (widget.revealedItem != null) {
      return BucketRevealBadge(
        label: widget.revealedItem!.nameEn,
        icon: widget.revealedItem!.icon,
        accentColor: widget.revealedItem!.accentColor,
      );
    }
    return null;
  }

  @override
  void didUpdateWidget(covariant SwirlingBucketWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isUrgentSpin != oldWidget.isUrgentSpin) {
      _spinController.duration = Duration(
        milliseconds: widget.isUrgentSpin ? 650 : 2400,
      );
      if (_spinController.isAnimating) {
        _spinController.repeat();
      }
    }

    final hasNewReveal =
        widget.revealBadge != null || widget.revealedItem != null;
    final hadOldReveal =
        oldWidget.revealBadge != null || oldWidget.revealedItem != null;

    if (hasNewReveal && !hadOldReveal) {
      _revealController.forward(from: 0.0);
    } else if (!hasNewReveal && hadOldReveal) {
      _revealController.reset();
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    _colorShiftController.dispose();
    _pulseController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outerSize = widget.size;
    final waterSize = outerSize - 24;
    final badge = _effectiveBadge;
    final isTricolor = widget.theme == BucketVisualTheme.tricolorNeon;

    return SizedBox(
      width: outerSize + 28,
      height: outerSize + 12,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Bucket Metallic Side Ears / Handles
          Positioned(
            left: 2,
            child: _buildBucketHandleEar(isLeft: true, isTricolor: isTricolor),
          ),
          Positioned(
            right: 2,
            child: _buildBucketHandleEar(isLeft: false, isTricolor: isTricolor),
          ),

          // Ambient Colored Aura Glow Behind Bucket
          AnimatedBuilder(
            animation: _colorShiftController,
            builder: (context, _) {
              final Color glowColor;
              if (isTricolor) {
                const tri = [
                  Color(0xFFFF2E54),
                  Color(0xFF9333EA),
                  Color(0xFF10B981),
                ];
                final idx = (_colorShiftController.value * 3).floor() % 3;
                final next = (idx + 1) % 3;
                final t = (_colorShiftController.value * 3) % 1.0;
                glowColor = Color.lerp(tri[idx], tri[next], t) ?? tri[0];
              } else {
                const aqua = [
                  Color(0xFF06B6D4),
                  Color(0xFF0EA5E9),
                  Color(0xFF14B8A6),
                ];
                final idx = (_colorShiftController.value * 3).floor() % 3;
                final next = (idx + 1) % 3;
                final t = (_colorShiftController.value * 3) % 1.0;
                glowColor = Color.lerp(aqua[idx], aqua[next], t) ?? aqua[0];
              }
              return Container(
                width: outerSize + 8,
                height: outerSize + 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (badge?.accentColor ?? glowColor)
                          .withValues(alpha: widget.isUrgentSpin ? 0.58 : 0.36),
                      blurRadius: widget.isUrgentSpin ? 26 : 18,
                      spreadRadius: widget.isUrgentSpin ? 5 : 2,
                    ),
                  ],
                ),
              );
            },
          ),

          // Outer Rim: Gold Brass (Game #1) OR Silver-Chrome (Game #2)
          Container(
            width: outerSize,
            height: outerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isTricolor
                    ? const [
                        Color(0xFFF8FAFC),
                        Color(0xFFCBD5E1),
                        Color(0xFF475569),
                        Color(0xFFE2E8F0),
                      ]
                    : const [
                        Color(0xFFFFF3B0),
                        Color(0xFFFFD700),
                        Color(0xFFB45309),
                        Color(0xFFFFD700),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: isTricolor
                    ? const Color(0xFFE879F9).withValues(alpha: 0.85)
                    : const Color(0xFFFFFBEB),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.65),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              // Inner Bucket Wall + Swirling Colored Water Canvas
              child: Container(
                width: waterSize,
                height: waterSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isTricolor
                        ? const Color(0xFF3B0764)
                        : const Color(0xFF78350F),
                    width: 3,
                  ),
                  color: isTricolor
                      ? const Color(0xFF14041C)
                      : const Color(0xFF041626),
                ),
                child: ClipOval(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated Rotating Colored Water Vortex
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _spinController,
                          _colorShiftController,
                        ]),
                        builder: (context, _) {
                          return CustomPaint(
                            size: Size(waterSize, waterSize),
                            painter: _SwirlingWaterPainter(
                              spinProgress: _spinController.value,
                              colorProgress: _colorShiftController.value,
                              isUrgent: widget.isUrgentSpin,
                              theme: widget.theme,
                              winnerColor: badge?.accentColor,
                            ),
                          );
                        },
                      ),

                      // Subtle glossy glass reflection at top
                      Positioned(
                        top: 6,
                        child: Container(
                          width: waterSize * 0.55,
                          height: waterSize * 0.14,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.28),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Center Content: Floating ❓ OR Rising Winning Item/Color with Name
          if (badge == null)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 0.94 + (_pulseController.value * 0.14);
                final dy = sin(_pulseController.value * pi) * -3.5;
                return Transform.translate(
                  offset: Offset(0, dy),
                  child: Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isTricolor
                      ? const Color(0xFF1F062A).withValues(alpha: 0.78)
                      : const Color(0xFF041C32).withValues(alpha: 0.72),
                  border: Border.all(
                    color: isTricolor
                        ? const Color(0xFFE879F9)
                        : const Color(0xFF38BDF8),
                    width: 2.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isTricolor
                              ? const Color(0xFFD946EF)
                              : const Color(0xFF0EA5E9))
                          .withValues(alpha: 0.45),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '?',
                    style: TextStyle(
                      color: isTricolor
                          ? const Color(0xFFFDF4FF)
                          : const Color(0xFFFFFBEB),
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      shadows: const [
                        Shadow(color: Colors.black, blurRadius: 8),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            AnimatedBuilder(
              animation: _revealController,
              builder: (context, _) {
                final t = Curves.easeOutBack.transform(
                  _revealController.value.clamp(0.0, 1.0),
                );
                final scale = 0.3 + (0.75 * t);
                final liftY = (1.0 - t) * 28.0 - 4.0;

                return Transform.translate(
                  offset: Offset(0, liftY),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1E1038).withValues(alpha: 0.96),
                            badge.accentColor.withValues(alpha: 0.45),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFD700),
                          width: 2.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: badge.accentColor.withValues(alpha: 0.75),
                            blurRadius: 20,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (badge.colorSwatch != null &&
                              badge.colorSwatch!.length >= 2)
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: badge.colorSwatch!,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(color: Colors.white, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: badge.accentColor.withValues(alpha: 0.8),
                                    blurRadius: 14,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            )
                          else if (badge.icon != null)
                            Text(
                              badge.icon!,
                              style: const TextStyle(
                                fontSize: 38,
                                shadows: [
                                  Shadow(color: Colors.black54, blurRadius: 8),
                                ],
                              ),
                            ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: badge.colorSwatch != null
                                  ? badge.accentColor
                                  : const Color(0xFFFFD700),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              badge.label,
                              style: TextStyle(
                                color: badge.colorSwatch != null
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: badge.colorSwatch != null ? 1.0 : 0.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBucketHandleEar({
    required bool isLeft,
    required bool isTricolor,
  }) {
    return Container(
      width: 16,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isTricolor
              ? const [Color(0xFFE2E8F0), Color(0xFF475569)]
              : const [Color(0xFFFFE57F), Color(0xFFB45309)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? const Radius.circular(10) : Radius.zero,
          right: !isLeft ? const Radius.circular(10) : Radius.zero,
        ),
        border: Border.all(
          color: isTricolor ? const Color(0xFFC084FC) : const Color(0xFFFFF8E1),
          width: 1.2,
        ),
      ),
    );
  }
}

class _SwirlingWaterPainter extends CustomPainter {
  final double spinProgress;
  final double colorProgress;
  final bool isUrgent;
  final BucketVisualTheme theme;
  final Color? winnerColor;

  const _SwirlingWaterPainter({
    required this.spinProgress,
    required this.colorProgress,
    required this.isUrgent,
    required this.theme,
    this.winnerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Separate water color palettes between Game #1 (Ocean Aqua-Teal) and Game #2 (Red/Violet/Green)
    final Color c1;
    final Color c2;
    final Color c3;
    final Color c4;

    if (theme == BucketVisualTheme.tricolorNeon) {
      c1 = winnerColor ?? const Color(0xFFFF2E54); // Blazing Red
      c2 = const Color(0xFF9333EA); // Vivid Violet
      c3 = const Color(0xFF10B981); // Emerald Green
      c4 = const Color(0xFFBE185D); // Deep Magenta accent
    } else {
      final baseShift = sin(colorProgress * 2 * pi) * 14;
      c1 = winnerColor ??
          HSVColor.fromAHSV(1.0, (192 + baseShift) % 360, 0.88, 0.96).toColor();
      c2 = const Color(0xFF0EA5E9); // Ocean Sky Blue
      c3 = const Color(0xFF14B8A6); // Lagoon Teal
      c4 = const Color(0xFF1D4ED8); // Deep Royal Blue
    }

    final angle = spinProgress * 2 * pi;

    // 1. Rotating Multi-Color Sweep Liquid Base
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [c1, c2, c3, c4, c1],
        transform: GradientRotation(angle),
      ).createShader(rect);
    canvas.drawCircle(center, radius, sweepPaint);

    // 2. Inner Radial Depth Vignette (gives deep water vortex look)
    final radialPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(alpha: 0.48),
          Colors.transparent,
          Colors.black.withValues(alpha: 0.45),
        ],
        stops: const [0.0, 0.58, 1.0],
      ).createShader(rect);
    canvas.drawCircle(center, radius, radialPaint);

    // 3. Swirling Water Ripple Spiral Arcs
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int ring = 0; ring < 3; ring++) {
      final ringRadius = radius * (0.42 + ring * 0.21);
      final ringAngle = angle * (ring.isEven ? 1.0 : -1.3) + (ring * 1.1);
      arcPaint
        ..strokeWidth = isUrgent ? 4.0 : 3.0
        ..color = Colors.white.withValues(alpha: 0.34 - (ring * 0.06));

      for (int k = 0; k < 3; k++) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: ringRadius),
          ringAngle + (k * (2 * pi / 3)),
          0.95,
          false,
          arcPaint,
        );
      }
    }

    // 4. Sparkling Water Bubbles spinning along the vortex
    final bubblePaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 10; i++) {
      final theta = angle * (i.isEven ? 1 : 2) + (i * pi / 5);
      final r = radius * (0.28 + ((i % 4) * 0.16));
      final bx = center.dx + cos(theta) * r;
      final by = center.dy + sin(theta) * r;
      bubblePaint.color = Colors.white.withValues(alpha: 0.55);
      canvas.drawCircle(Offset(bx, by), i % 3 == 0 ? 2.6 : 1.7, bubblePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SwirlingWaterPainter oldDelegate) =>
      oldDelegate.spinProgress != spinProgress ||
      oldDelegate.colorProgress != colorProgress ||
      oldDelegate.isUrgent != isUrgent ||
      oldDelegate.theme != theme ||
      oldDelegate.winnerColor != winnerColor;
}
