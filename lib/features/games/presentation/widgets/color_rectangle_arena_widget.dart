import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/color_game_option.dart';

/// High-Performance Industry-Standard Rectangular Arena Widget for Color Prediction Game.
/// - Pure high-contrast vibrant colors (Casino Red, Electric Royal Violet, Neon Emerald Green).
/// - Fast pure-color cycling during standard betting phase (260ms).
/// - Hyper-fast intense shuffle (75ms) during the critical final 5-second suspense draw window.
/// - Instant lock-on and celebratory reveal when the round settles on the winning color.
class ColorRectangleArenaWidget extends StatefulWidget {
  final int timeLeft;
  final bool isRevealing;
  final ColorGameOption? revealedColor;
  final bool didWin;
  final String? resultBanner;
  final double redMultiplier;
  final double violetMultiplier;
  final double greenMultiplier;
  final double adminCommissionPercent;

  const ColorRectangleArenaWidget({
    super.key,
    required this.timeLeft,
    required this.isRevealing,
    required this.revealedColor,
    required this.didWin,
    this.resultBanner,
    this.redMultiplier = 2.0,
    this.violetMultiplier = 5.0,
    this.greenMultiplier = 2.0,
    this.adminCommissionPercent = 5.0,
  });

  @override
  State<ColorRectangleArenaWidget> createState() =>
      _ColorRectangleArenaWidgetState();
}

class _ColorRectangleArenaWidgetState extends State<ColorRectangleArenaWidget>
    with SingleTickerProviderStateMixin {
  int _activeColorIndex = 0;
  Timer? _shuffleTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  bool get _isUrgent => widget.timeLeft <= 5 && widget.timeLeft > 0 && !widget.isRevealing;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _syncShuffleSpeed();
  }

  @override
  void didUpdateWidget(covariant ColorRectangleArenaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isRevealing != oldWidget.isRevealing ||
        (widget.timeLeft <= 5) != (oldWidget.timeLeft <= 5)) {
      _syncShuffleSpeed();
    }
  }

  void _syncShuffleSpeed() {
    _shuffleTimer?.cancel();

    if (widget.isRevealing && widget.revealedColor != null) {
      // Find winner index
      final winnerIdx = kColorGameOptions.indexWhere(
        (opt) => opt.id == widget.revealedColor!.id,
      );
      if (winnerIdx != -1 && mounted) {
        setState(() => _activeColorIndex = winnerIdx);
      }
      return;
    }

    // Normal or Urgent speed
    final intervalMs = _isUrgent ? 75 : 260;
    _shuffleTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      if (!mounted) return;
      setState(() {
        _activeColorIndex = (_activeColorIndex + 1) % kColorGameOptions.length;
      });
    });
  }

  @override
  void dispose() {
    _shuffleTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeOption = widget.isRevealing && widget.revealedColor != null
        ? widget.revealedColor!
        : kColorGameOptions[_activeColorIndex];

    final isWinnerReveal = widget.isRevealing && widget.revealedColor != null;

    return AnimatedBuilder(
      animation: _pulseScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _isUrgent ? _pulseScale.value : 1.0,
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isWinnerReveal
                ? [
                    const Color(0xFFFFD700),
                    activeOption.accentColor,
                    const Color(0xFFFFD700),
                  ]
                : _isUrgent
                    ? [
                        const Color(0xFFFF0055),
                        const Color(0xFFFFD700),
                        const Color(0xFFFF0055),
                      ]
                    : [
                        activeOption.accentColor.withValues(alpha: 0.8),
                        const Color(0xFF3B0764),
                        activeOption.accentColor.withValues(alpha: 0.8),
                      ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: activeOption.accentColor.withValues(alpha: _isUrgent ? 0.75 : 0.4),
              blurRadius: _isUrgent ? 22 : 14,
              spreadRadius: _isUrgent ? 3 : 1,
            ),
          ],
        ),
        child: Container(
          height: 146,
          decoration: BoxDecoration(
            color: const Color(0xFF0D0214),
            borderRadius: BorderRadius.circular(18),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // Pure Dynamic Color Backdrop
                AnimatedContainer(
                  duration: Duration(milliseconds: _isUrgent ? 70 : 220),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isWinnerReveal
                          ? [
                              activeOption.gradientColors[0],
                              activeOption.gradientColors[1],
                              const Color(0xFF14021F),
                            ]
                          : [
                              activeOption.gradientColors[0].withValues(alpha: 0.35),
                              activeOption.gradientColors[1].withValues(alpha: 0.20),
                              const Color(0xFF0F0419),
                            ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // Diagonal Glass Sheen Reflection
                Positioned(
                  top: -60,
                  left: -40,
                  right: -40,
                  height: 120,
                  child: Transform.rotate(
                    angle: -0.15,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.12),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),

                // Main Rectangular Display Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Status Strip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildArenaBadge(
                            isWinnerReveal: isWinnerReveal,
                            isUrgent: _isUrgent,
                            activeColor: activeOption.accentColor,
                          ),
                          _buildCountdownOrWinnerPill(
                            isWinnerReveal: isWinnerReveal,
                            isUrgent: _isUrgent,
                          ),
                        ],
                      ),

                      // Center Display: Pure Color Card Showcasing Active or Winning Color
                      Expanded(
                        child: Center(
                          child: isWinnerReveal
                              ? _buildWinnerCelebrationCard(activeOption)
                              : _buildShufflingRectangleCard(activeOption),
                        ),
                      ),

                      // Bottom Live Odds & Admin Commission Info
                      _buildBottomOddsAndFeeRow(activeOption),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArenaBadge({
    required bool isWinnerReveal,
    required bool isUrgent,
    required Color activeColor,
  }) {
    if (isWinnerReveal) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD700).withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🏆', style: TextStyle(fontSize: 11)),
            SizedBox(width: 4),
            Text(
              'OFFICIAL DRAW RESULT',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      );
    }

    if (isUrgent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFF0055).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFF0055), width: 1.4),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('⚡', style: TextStyle(fontSize: 11)),
            SizedBox(width: 4),
            Text(
              'FINAL 5s DRAW SUSPENSE!',
              style: TextStyle(
                color: Color(0xFFFF416C),
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: activeColor.withValues(alpha: 0.6), width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🎯', style: TextStyle(fontSize: 11)),
          SizedBox(width: 4),
          Text(
            'COLOR SHUFFLE ARENA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownOrWinnerPill({
    required bool isWinnerReveal,
    required bool isUrgent,
  }) {
    if (isWinnerReveal) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF10B981), width: 1),
        ),
        child: const Text(
          'RESOLVED',
          style: TextStyle(
            color: Color(0xFF6EE7B7),
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    final secText = widget.timeLeft.toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: isUrgent
            ? const Color(0xFFFF0055).withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUrgent ? const Color(0xFFFF2A55) : const Color(0xFFE879F9).withValues(alpha: 0.5),
          width: isUrgent ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 11,
            color: isUrgent ? const Color(0xFFFF416C) : Colors.white70,
          ),
          const SizedBox(width: 4),
          Text(
            '00:$secText',
            style: TextStyle(
              color: isUrgent ? const Color(0xFFFF416C) : Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShufflingRectangleCard(ColorGameOption activeOption) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            activeOption.gradientColors[0],
            activeOption.gradientColors[1],
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: activeOption.accentColor.withValues(alpha: _isUrgent ? 0.9 : 0.6),
            blurRadius: _isUrgent ? 20 : 12,
            spreadRadius: _isUrgent ? 2 : 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            activeOption.emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 10),
          Text(
            activeOption.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  offset: Offset(1.5, 1.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white70, width: 1),
            ),
            child: Text(
              _formatMult(activeOption.id),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerCelebrationCard(ColorGameOption winOption) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            winOption.gradientColors[0],
            winOption.gradientColors[1],
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.8),
            blurRadius: 22,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('✨', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                'WINNER: ${winOption.name}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: Colors.black87,
                      offset: Offset(2, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(winOption.emoji, style: const TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0214).withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFFFD700), width: 0.8),
            ),
            child: Text(
              'PAYOUT ${_formatMult(winOption.id)} • ADMIN FEE ${widget.adminCommissionPercent.toInt()}%',
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomOddsAndFeeRow(ColorGameOption activeOption) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 3 mini pure color indicators
        Row(
          children: kColorGameOptions.map((opt) {
            final isCurrent = activeOption.id == opt.id;
            return Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isCurrent
                    ? opt.accentColor.withValues(alpha: 0.35)
                    : Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isCurrent ? opt.accentColor : Colors.white24,
                  width: isCurrent ? 1.4 : 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: opt.accentColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${opt.name} ${_formatMult(opt.id)}',
                    style: TextStyle(
                      color: isCurrent ? Colors.white : Colors.white70,
                      fontSize: 8.5,
                      fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),

        // Admin Commission Cut pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('👑', style: TextStyle(fontSize: 8.5)),
              const SizedBox(width: 3),
              Text(
                'Admin: ${widget.adminCommissionPercent.toInt()}%',
                style: const TextStyle(
                  color: Color(0xFFFDE68A),
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatMult(String id) {
    if (id == 'violet') {
      return '${widget.violetMultiplier.toStringAsFixed(widget.violetMultiplier % 1 == 0 ? 0 : 1)}x';
    } else if (id == 'green') {
      return '${widget.greenMultiplier.toStringAsFixed(widget.greenMultiplier % 1 == 0 ? 0 : 1)}x';
    }
    return '${widget.redMultiplier.toStringAsFixed(widget.redMultiplier % 1 == 0 ? 0 : 1)}x';
  }
}
