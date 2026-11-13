import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/seven_up_game_entity.dart';

/// Top Shaker Cup Stage for Game #3 (7 UP 7 DOWN) — Simplified with NO character.
/// Uses continuous frame-by-frame phase integration via [Ticker] so shaking speed
/// accelerates smoothly across the 18s round -> fast >=12s -> turbo >=15s.
class SevenUpDealerStage extends StatefulWidget {
  final int elapsedSeconds;
  final double speedMultiplier;
  final bool isBettingLocked;
  final DiceRollOutcome? revealedOutcome;

  const SevenUpDealerStage({
    super.key,
    required this.elapsedSeconds,
    required this.speedMultiplier,
    required this.isBettingLocked,
    this.revealedOutcome,
  });

  @override
  State<SevenUpDealerStage> createState() => _SevenUpDealerStageState();
}

class _SevenUpDealerStageState extends State<SevenUpDealerStage>
    with TickerProviderStateMixin {
  late final Ticker _ticker;
  late final AnimationController _revealController;

  Duration _lastElapsed = Duration.zero;
  double _shakePhase = 0.0;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _ticker = createTicker((elapsed) {
      final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
      _lastElapsed = elapsed;
      if (dt > 0 && dt < 0.2) {
        setState(() {
          // Continuously integrate phase by live speedMultiplier for butter-smooth acceleration
          _shakePhase += dt * widget.speedMultiplier * 4.2;
        });
      }
    })
      ..start();
  }

  @override
  void didUpdateWidget(covariant SevenUpDealerStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.revealedOutcome != null && oldWidget.revealedOutcome == null) {
      _revealController.forward(from: 0.0);
    } else if (widget.revealedOutcome == null && oldWidget.revealedOutcome != null) {
      _revealController.reset();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = widget.elapsedSeconds;
    final isPastFast = elapsed >= 12;
    final isTurbo = elapsed >= 15;

    final auraColor = isTurbo
        ? const Color(0xFFFF2E63)
        : isPastFast
            ? const Color(0xFFFF9F1C)
            : AppColors.goldCoin;

    final shakeAmp = widget.revealedOutcome != null
        ? 0.0
        : isTurbo
            ? 8.5
            : isPastFast
                ? 5.0
                : 2.0;

    final dx = sin(_shakePhase) * shakeAmp;
    final dy = cos(_shakePhase * 1.7) * (shakeAmp * 0.42);
    final tilt = sin(_shakePhase * 0.9) * (isTurbo ? 0.14 : isPastFast ? 0.08 : 0.035);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 5, 12, 5),
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3E0A14), Color(0xFF210409)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.goldCoin.withValues(alpha: 0.55),
          width: 1.4,
        ),
      ),
      child: Column(
        children: [
          // Simplified Arena Row: Top Holders (Left) | Character-Free Shaker Podium (Center) | Recent Winners (Right)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _buildSideLeaderboard(
                  title: 'RICHEST',
                  color: const Color(0xFFFFD700),
                  entries: const [
                    {'name': 'Karan', 'amt': '3.5K'},
                    {'name': 'Tania', 'amt': '1.7K'},
                    {'name': 'Prince', 'amt': '950'},
                  ],
                ),
              ),

              // Center: Simplified No-Character Dice Shaker Dome & Tray
              SizedBox(
                width: 122,
                height: 74,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulsing Speed Aura
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: auraColor.withValues(
                              alpha: isTurbo ? 0.55 : isPastFast ? 0.38 : 0.22,
                            ),
                            blurRadius: isTurbo ? 22 : 14,
                            spreadRadius: isTurbo ? 3 : 1,
                          ),
                        ],
                      ),
                    ),

                    // Dice Tray Base
                    Positioned(
                      bottom: 4,
                      child: Container(
                        width: 102,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1F2937), Color(0xFF030712)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.goldCoin, width: 1.5),
                        ),
                      ),
                    ),

                    // Revealed 2 Dice on tray at 18s
                    if (widget.revealedOutcome != null)
                      Positioned(
                        bottom: 10,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DiceFaceWidget(
                              value: widget.revealedOutcome!.die1,
                              size: 30,
                            ),
                            const SizedBox(width: 8),
                            DiceFaceWidget(
                              value: widget.revealedOutcome!.die2,
                              size: 30,
                            ),
                          ],
                        ),
                      ),

                    // Animated Shaker Cup (no dealer character)
                    AnimatedBuilder(
                      animation: _revealController,
                      builder: (context, child) {
                        final liftOffset =
                            Curves.easeOutBack.transform(_revealController.value) * -42.0;
                        final opacity =
                            (1.0 - _revealController.value * 0.85).clamp(0.0, 1.0);
                        return Positioned(
                          bottom: 10 - liftOffset,
                          child: Opacity(
                            opacity: opacity,
                            child: Transform.translate(
                              offset: Offset(dx, dy),
                              child: Transform.rotate(
                                angle: tilt,
                                child: child,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 52,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF374151),
                              Color(0xFF111827),
                              Color(0xFF030712),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                            bottom: Radius.circular(6),
                          ),
                          border: Border.all(color: AppColors.goldCoin, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.7),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '🎲',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _buildSideLeaderboard(
                  title: 'WINNERS',
                  color: const Color(0xFF34D399),
                  entries: const [
                    {'name': 'Zoya', 'amt': '2.4K'},
                    {'name': 'Rafi', 'amt': '1.2K'},
                    {'name': 'Siam', 'amt': '600'},
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          // Progressive Speed & 18s Round Progress Bar + Status Pill
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: auraColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: auraColor, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isTurbo ? Icons.whatshot_rounded : Icons.speed_rounded,
                      size: 12,
                      color: auraColor,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${widget.speedMultiplier.toStringAsFixed(1)}x',
                      style: TextStyle(
                        color: auraColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (elapsed / 18.0).clamp(0.0, 1.0),
                    minHeight: 7,
                    backgroundColor: Colors.black54,
                    valueColor: AlwaysStoppedAnimation<Color>(auraColor),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.isBettingLocked
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF10B981).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.isBettingLocked
                        ? Colors.white54
                        : const Color(0xFF34D399),
                  ),
                ),
                child: Text(
                  widget.isBettingLocked ? 'BET LOCKED!' : 'BET OPEN',
                  style: TextStyle(
                    color: widget.isBettingLocked
                        ? Colors.white
                        : const Color(0xFF6EE7B7),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSideLeaderboard({
    required String title,
    required Color color,
    required List<Map<String, String>> entries,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        ...entries.map((e) {
          return Container(
            margin: const EdgeInsets.only(bottom: 3),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    e['name']!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 9),
                  ),
                ),
                Text(
                  e['amt']!,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

/// Custom-painted sharp 6-sided Dice face widget with exact pip patterns (1..6).
class DiceFaceWidget extends StatelessWidget {
  final int value;
  final double size;

  const DiceFaceWidget({
    super.key,
    required this.value,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _DicePipsPainter(value: value),
      ),
    );
  }
}

class _DicePipsPainter extends CustomPainter {
  final int value;

  const _DicePipsPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final dotRadius = w * 0.11;
    final paint = Paint()
      ..color = value == 1 || value == 4
          ? const Color(0xFFDC2626)
          : const Color(0xFF111827);

    final c = Offset(w * 0.5, h * 0.5);
    final tl = Offset(w * 0.25, h * 0.25);
    final tr = Offset(w * 0.75, h * 0.25);
    final ml = Offset(w * 0.25, h * 0.5);
    final mr = Offset(w * 0.75, h * 0.5);
    final bl = Offset(w * 0.25, h * 0.75);
    final br = Offset(w * 0.75, h * 0.75);

    List<Offset> dots;
    switch (value) {
      case 1:
        dots = [c];
        break;
      case 2:
        dots = [tr, bl];
        break;
      case 3:
        dots = [tr, c, bl];
        break;
      case 4:
        dots = [tl, tr, bl, br];
        break;
      case 5:
        dots = [tl, tr, c, bl, br];
        break;
      case 6:
      default:
        dots = [tl, tr, ml, mr, bl, br];
        break;
    }

    for (final dot in dots) {
      canvas.drawCircle(dot, dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DicePipsPainter oldDelegate) =>
      oldDelegate.value != value;
}
