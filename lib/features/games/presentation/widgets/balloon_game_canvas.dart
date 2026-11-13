import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/balloon_game_entity.dart';
import '../../domain/entities/games_control_config.dart';
import '../bloc/balloon_game_bloc.dart';

/// 60fps interactive Hot Air Balloon playfield matching the Play Store offline game UI:
/// - Clean pure white background, top-left formatted score (`911 155` style), top-right pause
/// - Yellow-Blue-Red striped hot air balloon steered smoothly via drag/touch
/// - Horizontal black spike bars with downward teeth, outlined floating bubbles,
///   yellow shield ring, magnet ring, and sharp speed boost past 40 seconds
class BalloonGameCanvas extends StatefulWidget {
  final BalloonGamePhase phase;
  final BalloonPlayMode playMode;
  final int runSeedTick;
  final int activeRunStake;
  final int bestScore;
  final BalloonRunSummary? lastRunSummary;
  final int doubleTargetSeconds;
  final double doubleStakeMultiplier;
  final int standardBubbleCoins;
  final int goldBubbleCoins;
  final int speedBoostAfterSeconds;
  final VoidCallback onStartTap;
  final VoidCallback onTogglePauseTap;
  final void Function({
    required int score,
    required int bubbleCoinsEarned,
    required double survivedSeconds,
    required bool doubleTargetCleared,
  }) onRunFinished;

  const BalloonGameCanvas({
    super.key,
    required this.phase,
    required this.playMode,
    required this.runSeedTick,
    required this.activeRunStake,
    required this.bestScore,
    required this.lastRunSummary,
    this.doubleTargetSeconds = 40,
    this.doubleStakeMultiplier = 2.0,
    this.standardBubbleCoins = 10,
    this.goldBubbleCoins = 50,
    this.speedBoostAfterSeconds = 40,
    required this.onStartTap,
    required this.onTogglePauseTap,
    required this.onRunFinished,
  });

  @override
  State<BalloonGameCanvas> createState() => _BalloonGameCanvasState();
}

class _BalloonGameCanvasState extends State<BalloonGameCanvas>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final Random _rng = Random();

  Duration _lastTick = Duration.zero;
  Size _canvasSize = const Size(360, 410);

  // Balloon normalized position (0..1)
  double _balloonX = 0.38;
  double _balloonY = 0.63;

  // Live run counters
  double _elapsedSeconds = 0.0;
  double _scoreAccumulator = 0.0;
  int _score = 0;
  int _bubbleCoins = 0;
  double _speedMultiplier = 1.0;

  // Active power-up timers (seconds remaining)
  double _shieldSeconds = 0.0;
  double _magnetSeconds = 0.0;
  double _slowSeconds = 0.0;

  // Dynamic entities
  final List<BalloonSpikeBar> _spikes = [];
  final List<BalloonBubble> _bubbles = [];
  double _spikeSpawnDist = 0.0;
  double _bubbleSpawnDist = 0.0;
  bool _hasReportedFinish = false;

  @override
  void initState() {
    super.initState();
    _seedPreviewScene();
    _ticker = createTicker(_onFrameTick)..start();
  }

  @override
  void didUpdateWidget(covariant BalloonGameCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.phase == BalloonGamePhase.playing &&
        (oldWidget.runSeedTick != widget.runSeedTick ||
            oldWidget.phase == BalloonGamePhase.ready ||
            oldWidget.phase == BalloonGamePhase.gameOver)) {
      _resetForNewRun();
    } else if (widget.phase == BalloonGamePhase.ready &&
        oldWidget.playMode != widget.playMode) {
      _seedPreviewScene();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _seedPreviewScene() {
    _balloonX = 0.38;
    _balloonY = 0.63;
    _elapsedSeconds = 0;
    _score = 0;
    _bubbleCoins = 0;
    _shieldSeconds = 0;
    _magnetSeconds = 0;
    _slowSeconds = 0;
    _speedMultiplier = BalloonGameBloc.calculateSpeedMultiplier(
      elapsedSeconds: 0,
      isDoubleStake: widget.playMode == BalloonPlayMode.doubleStake,
      slowPowerUpActive: false,
    );

    _spikes
      ..clear()
      ..addAll([
        BalloonSpikeBar(xNorm: 0.60, yNorm: 0.16, widthNorm: 0.13),
        BalloonSpikeBar(xNorm: 0.78, yNorm: 0.57, widthNorm: 0.22),
        BalloonSpikeBar(xNorm: 0.15, yNorm: 0.94, widthNorm: 0.56),
      ]);

    _bubbles
      ..clear()
      ..addAll([
        BalloonBubble(xNorm: 0.08, yNorm: 0.26),
        BalloonBubble(xNorm: 0.08, yNorm: 0.43),
        BalloonBubble(xNorm: 0.93, yNorm: 0.43),
        BalloonBubble(xNorm: 0.51, yNorm: 0.51, isCoinBubble: true),
        BalloonBubble(
          xNorm: 0.41,
          yNorm: 0.83,
          radiusPx: 14,
          powerUp: BalloonPowerUpType.shield,
        ),
        BalloonBubble(xNorm: 0.39, yNorm: 0.89),
        BalloonBubble(xNorm: 0.80, yNorm: 0.89),
      ]);
  }

  void _resetForNewRun() {
    _balloonX = 0.50;
    _balloonY = 0.68;
    _elapsedSeconds = 0.0;
    _scoreAccumulator = 0.0;
    _score = 0;
    _bubbleCoins = 0;
    _shieldSeconds = 2.0; // Brief 2s launch grace shield
    _magnetSeconds = 0.0;
    _slowSeconds = 0.0;
    _spikeSpawnDist = 0.15;
    _bubbleSpawnDist = 0.0;
    _hasReportedFinish = false;

    final isDouble = widget.playMode == BalloonPlayMode.doubleStake;
    _speedMultiplier = BalloonGameBloc.calculateSpeedMultiplier(
      elapsedSeconds: 0,
      isDoubleStake: isDouble,
      slowPowerUpActive: false,
    );

    _spikes
      ..clear()
      ..addAll([
        BalloonSpikeBar(xNorm: 0.58, yNorm: 0.06, widthNorm: 0.24),
        BalloonSpikeBar(xNorm: 0.05, yNorm: 0.32, widthNorm: 0.28),
      ]);

    _bubbles
      ..clear()
      ..addAll([
        BalloonBubble(xNorm: 0.25, yNorm: 0.20),
        BalloonBubble(xNorm: 0.72, yNorm: 0.36, isCoinBubble: true),
        BalloonBubble(xNorm: 0.48, yNorm: 0.45),
      ]);
  }

  void _onFrameTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1000000.0;
    _lastTick = elapsed;

    if (widget.phase != BalloonGamePhase.playing || _hasReportedFinish) {
      return;
    }
    if (dt <= 0 || dt > 0.12) return;

    final isDouble = widget.playMode == BalloonPlayMode.doubleStake;

    setState(() {
      _elapsedSeconds += dt;
      if (_shieldSeconds > 0) _shieldSeconds = max(0.0, _shieldSeconds - dt);
      if (_magnetSeconds > 0) _magnetSeconds = max(0.0, _magnetSeconds - dt);
      if (_slowSeconds > 0) _slowSeconds = max(0.0, _slowSeconds - dt);

      _speedMultiplier = BalloonGameBloc.calculateSpeedMultiplier(
        elapsedSeconds: _elapsedSeconds,
        isDoubleStake: isDouble,
        slowPowerUpActive: _slowSeconds > 0,
        boostAfterSeconds: widget.speedBoostAfterSeconds,
      );

      // Score ticks continuously with flight altitude & speed (Play Store style)
      _scoreAccumulator += dt * 115.0 * _speedMultiplier;
      _score += _scoreAccumulator.floor();
      _scoreAccumulator -= _scoreAccumulator.floor();

      // Normalized vertical scroll speed (base ~0.24 screen/sec * speedMultiplier)
      final scrollStep = dt * 0.23 * _speedMultiplier;
      _spikeSpawnDist += scrollStep;
      _bubbleSpawnDist += scrollStep;

      // Move spikes downward
      for (final s in _spikes) {
        s.yNorm += scrollStep;
      }
      _spikes.removeWhere((s) => s.yNorm > 1.12);

      // Spawn new spikes with guaranteed passable corridor
      final double spawnInterval = max(0.16, 0.29 - (_speedMultiplier * 0.015));
      if (_spikeSpawnDist >= spawnInterval) {
        _spikeSpawnDist = 0.0;
        _spawnNextSpikeBar();
      }

      // Move bubbles & pull toward balloon if magnet is active
      for (final b in _bubbles) {
        b.yNorm += scrollStep * 0.94;
        if (_magnetSeconds > 0 && b.powerUp == null) {
          final dx = _balloonX - b.xNorm;
          final dy = _balloonY - b.yNorm;
          final dist = sqrt(dx * dx + dy * dy);
          if (dist < 0.42 && dist > 0.001) {
            b.xNorm += (dx / dist) * dt * 0.65;
            b.yNorm += (dy / dist) * dt * 0.65;
          }
        }
      }
      _bubbles.removeWhere((b) => b.yNorm > 1.08);

      if (_bubbleSpawnDist >= 0.14) {
        _bubbleSpawnDist = 0.0;
        _spawnNextBubble();
      }

      // Check Bubble Collections & Spike Collisions in pixel space
      _checkCollisions();
    });
  }

  void _spawnNextSpikeBar() {
    // Harder / wider bars smoothly appear after 20s and past 40s
    final double difficultyFactor = (_elapsedSeconds / 55.0).clamp(0.0, 1.0);
    final double width = 0.18 + _rng.nextDouble() * (0.20 + 0.14 * difficultyFactor);
    final int pattern = _rng.nextInt(4);

    double x;
    if (pattern == 0) {
      x = 0.0; // Left wall spike bar
    } else if (pattern == 1) {
      x = 1.0 - width; // Right wall spike bar
    } else {
      x = 0.06 + _rng.nextDouble() * max(0.05, 0.88 - width);
    }

    _spikes.add(BalloonSpikeBar(
      xNorm: x,
      yNorm: -0.05,
      widthNorm: width,
    ));
  }

  void _spawnNextBubble() {
    final roll = _rng.nextInt(100);
    BalloonPowerUpType? powerUp;
    bool isCoin = false;
    double radius = 10.5;

    if (roll < 7) {
      powerUp = BalloonPowerUpType.shield;
      radius = 13.5;
    } else if (roll < 12) {
      powerUp = BalloonPowerUpType.magnet;
      radius = 13.5;
    } else if (roll < 16) {
      powerUp = BalloonPowerUpType.slower;
      radius = 13.5;
    } else if (roll < 36) {
      isCoin = true;
      radius = 11.5;
    }

    _bubbles.add(BalloonBubble(
      xNorm: 0.08 + _rng.nextDouble() * 0.84,
      yNorm: -0.04,
      radiusPx: radius,
      isCoinBubble: isCoin,
      powerUp: powerUp,
    ));
  }

  void _checkCollisions() {
    final w = _canvasSize.width;
    final h = _canvasSize.height;
    final bx = _balloonX * w;
    final by = _balloonY * h;

    // Balloon envelope center sits slightly above basket
    final envCenterX = bx;
    final envCenterY = by - 4;
    const double collectRadius = 28.0;

    // 1. Collect bubbles & power-ups
    _bubbles.removeWhere((b) {
      final px = b.xNorm * w;
      final py = b.yNorm * h;
      final dist = hypot(px - envCenterX, py - envCenterY);
      if (dist <= collectRadius + b.radiusPx) {
        if (b.powerUp != null) {
          switch (b.powerUp!) {
            case BalloonPowerUpType.shield:
              _shieldSeconds = 8.0;
              _score += 25;
              break;
            case BalloonPowerUpType.magnet:
              _magnetSeconds = 10.0;
              _score += 25;
              break;
            case BalloonPowerUpType.slower:
              _slowSeconds = 6.0;
              _score += 25;
              break;
          }
        } else if (b.isCoinBubble) {
          _score += 25;
          _bubbleCoins += widget.goldBubbleCoins;
        } else {
          _score += 10;
          _bubbleCoins += widget.standardBubbleCoins;
        }
        return true;
      }
      return false;
    });

    // 2. Check Spike Bar Collision (forgiving rim hitbox so near-misses feel fair)
    if (_shieldSeconds <= 0) {
      // Balloon ellipse bounding box (~32x42 total height including basket)
      final bLeft = bx - 13.5;
      final bRight = bx + 13.5;
      final bTop = by - 21.0;
      final bBottom = by + 20.0;

      for (final s in _spikes) {
        final sLeft = s.xNorm * w + 2;
        final sRight = (s.xNorm + s.widthNorm) * w - 2;
        final sTop = s.yNorm * h;
        final sBottom = sTop + 13.5;

        final overlapsX = bRight > sLeft && bLeft < sRight;
        final overlapsY = bBottom > sTop && bTop < sBottom;
        if (overlapsX && overlapsY) {
          _triggerCrash();
          break;
        }
      }
    }
  }

  double hypot(double dx, double dy) => sqrt(dx * dx + dy * dy);

  void _triggerCrash() {
    if (_hasReportedFinish) return;
    _hasReportedFinish = true;
    final clearedDouble = _elapsedSeconds >= widget.doubleTargetSeconds;
    widget.onRunFinished(
      score: _score,
      bubbleCoinsEarned: _bubbleCoins,
      survivedSeconds: _elapsedSeconds,
      doubleTargetCleared: clearedDouble,
    );
  }

  String _formatSpacedScore(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromEnd = s.length - i;
      if (i > 0 && posFromEnd % 3 == 0) {
        buf.write(' ');
      }
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPastBoost = _elapsedSeconds >= widget.speedBoostAfterSeconds;
    final bool isDouble = widget.playMode == BalloonPlayMode.doubleStake;
    final bool targetCleared = _elapsedSeconds >= widget.doubleTargetSeconds;
    final String stakeMultLabel =
        GamesControlConfig.formatMultiplier(widget.doubleStakeMultiplier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 360.0;
        const height = 408.0;
        _canvasSize = Size(width, height);

        return Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isPastBoost && widget.phase == BalloonGamePhase.playing
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF0EA5E9).withValues(alpha: 0.65),
              width: 2.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                if (widget.phase != BalloonGamePhase.playing) return;
                setState(() {
                  _balloonX =
                      (_balloonX + details.delta.dx / _canvasSize.width)
                          .clamp(0.07, 0.93);
                  _balloonY =
                      (_balloonY + details.delta.dy / _canvasSize.height)
                          .clamp(0.16, 0.90);
                });
              },
              onTapDown: (details) {
                if (widget.phase != BalloonGamePhase.playing) return;
                setState(() {
                  final targetX =
                      (details.localPosition.dx / _canvasSize.width)
                          .clamp(0.07, 0.93);
                  final targetY =
                      (details.localPosition.dy / _canvasSize.height)
                          .clamp(0.16, 0.90);
                  _balloonX = _balloonX + (targetX - _balloonX) * 0.45;
                  _balloonY = _balloonY + (targetY - _balloonY) * 0.45;
                });
              },
              child: Stack(
                children: [
                  // 1. Live Play Store Hot Air Balloon CustomPaint Canvas
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _BalloonPlayfieldPainter(
                        balloonX: _balloonX,
                        balloonY: _balloonY,
                        spikes: _spikes,
                        bubbles: _bubbles,
                        shieldActive: _shieldSeconds > 0,
                        magnetActive: _magnetSeconds > 0,
                        slowActive: _slowSeconds > 0,
                      ),
                    ),
                  ),

                  // 2. Top-Left Crisp Retro Score Counter (`911 155` style from image)
                  Positioned(
                    top: 10,
                    left: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatSpacedScore(_score),
                          style: const TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'monospace',
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (widget.bestScore > 0)
                          Text(
                            'Best: ${_formatSpacedScore(widget.bestScore)}',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 3. Top-Center Speed, Time & Coin Popped Pill
                  Positioned(
                    top: 9,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6).withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isPastBoost
                                ? const Color(0xFFEF4444)
                                : const Color(0xFFD1D5DB),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${_elapsedSeconds.floor()}s',
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: isPastBoost
                                    ? const Color(0xFFDC2626)
                                    : _elapsedSeconds >= (widget.speedBoostAfterSeconds * 0.5)
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFF0EA5E9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isPastBoost
                                    ? '🔥 ${_speedMultiplier.toStringAsFixed(1)}x'
                                    : '${_speedMultiplier.toStringAsFixed(1)}x',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '+🪙 $_bubbleCoins',
                              style: const TextStyle(
                                color: Color(0xFFB45309),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 4. Top-Right Pause Icon (just like screenshot)
                  Positioned(
                    top: 8,
                    right: 10,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isDouble &&
                            widget.phase == BalloonGamePhase.playing) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: targetCleared
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: targetCleared
                                    ? const Color(0xFF047857)
                                    : const Color(0xFFF59E0B),
                              ),
                            ),
                            child: Text(
                              targetCleared
                                  ? '✅ $stakeMultLabel Ready!'
                                  : '$stakeMultLabel: ${_elapsedSeconds.floor()}/${widget.doubleTargetSeconds}s',
                              style: TextStyle(
                                color: targetCleared
                                    ? Colors.white
                                    : const Color(0xFF92400E),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        GestureDetector(
                          onTap: widget.phase == BalloonGamePhase.playing ||
                                  widget.phase == BalloonGamePhase.paused
                              ? widget.onTogglePauseTap
                              : null,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              widget.phase == BalloonGamePhase.paused
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                              color: const Color(0xFF1F2937),
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 5. Ready / Paused / Game Over Overlay Card
                  if (widget.phase != BalloonGamePhase.playing)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.72),
                        child: Center(
                          child: _buildStatusCard(context),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final isDouble = widget.playMode == BalloonPlayMode.doubleStake;
    final summary = widget.lastRunSummary;

    return Container(
      width: 285,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldCoin, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.phase == BalloonGamePhase.paused) ...[
            const Text(
              '⏸ FLIGHT PAUSED',
              style: TextStyle(
                color: AppColors.goldCoin,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: widget.onTogglePauseTap,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text(
                'RESUME FLIGHT',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ] else if (widget.phase == BalloonGamePhase.gameOver &&
              summary != null) ...[
            Text(
              summary.doubleWon
                  ? '🏆 ${GamesControlConfig.formatMultiplier(widget.doubleStakeMultiplier)} VICTORY!'
                  : '💥 BALLOON POPPED!',
              style: TextStyle(
                color: summary.doubleWon
                    ? const Color(0xFF34D399)
                    : const Color(0xFFFCA5A5),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Score: ${_formatSpacedScore(summary.score)}  •  Time: ${summary.survivedSeconds.toStringAsFixed(1)}s',
              style: const TextStyle(color: Colors.white70, fontSize: 11.5),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: summary.earnedCoins > 0
                    ? const Color(0xFF10B981).withValues(alpha: 0.22)
                    : Colors.white10,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: summary.earnedCoins > 0
                      ? const Color(0xFF34D399)
                      : Colors.white24,
                ),
              ),
              child: Text(
                summary.earnedCoins > 0
                    ? '🪙 Earned: +${summary.earnedCoins} Coins'
                    : '🪙 Lost Stake: -${summary.stakedCoins} Coins',
                style: TextStyle(
                  color: summary.earnedCoins > 0
                      ? const Color(0xFF6EE7B7)
                      : const Color(0xFFFCA5A5),
                  fontWeight: FontWeight.w900,
                  fontSize: 12.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldCoin,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: widget.onStartTap,
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: Text(
                  isDouble ? 'STAKE & FLY AGAIN' : 'PLAY AGAIN',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ] else ...[
            const Text(
              '🎈 HOT AIR BALLOON',
              style: TextStyle(
                color: AppColors.goldCoin,
                fontSize: 15.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isDouble
                  ? 'Faster speed challenge! Survive ${widget.doubleTargetSeconds}s+ to win ${GamesControlConfig.formatMultiplier(widget.doubleStakeMultiplier)} your staked coins. Speed surges >${widget.speedBoostAfterSeconds}s!'
                  : 'Drag balloon to dodge black spikes & pop bubbles (+${widget.standardBubbleCoins}/+${widget.goldBubbleCoins} coins)! Speed boosts high after ${widget.speedBoostAfterSeconds}s.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDouble
                      ? AppColors.goldCoin
                      : const Color(0xFF0EA5E9),
                  foregroundColor: isDouble ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: widget.onStartTap,
                icon: const Icon(Icons.flight_takeoff_rounded, size: 18),
                label: Text(
                  isDouble
                      ? 'STAKE & START ${GamesControlConfig.formatMultiplier(widget.doubleStakeMultiplier)} RUN'
                      : 'START FLIGHT (FREE)',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// CustomPainter rendering the exact Play Store Hot Air Balloon visual aesthetic:
/// white canvas, outlined bubbles, yellow/cyan/purple power-up rings,
/// pixel-sharp black spike bars with downward teeth, and the iconic Yellow-Blue-Red balloon.
class _BalloonPlayfieldPainter extends CustomPainter {
  final double balloonX;
  final double balloonY;
  final List<BalloonSpikeBar> spikes;
  final List<BalloonBubble> bubbles;
  final bool shieldActive;
  final bool magnetActive;
  final bool slowActive;

  const _BalloonPlayfieldPainter({
    required this.balloonX,
    required this.balloonY,
    required this.spikes,
    required this.bubbles,
    required this.shieldActive,
    required this.magnetActive,
    required this.slowActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Clean Pure White Sky (matching screenshot)
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.white,
    );

    // 2. Floating Bubbles & Power-Up Rings
    for (final b in bubbles) {
      final center = Offset(b.xNorm * size.width, b.yNorm * size.height);
      if (b.powerUp != null) {
        _drawPowerUpRing(canvas, center, b.radiusPx, b.powerUp!);
      } else if (b.isCoinBubble) {
        _drawCoinBubble(canvas, center, b.radiusPx);
      } else {
        _drawStandardBubble(canvas, center, b.radiusPx);
      }
    }

    // 3. Horizontal Pixel Black Spike Bars with Downward Teeth
    for (final s in spikes) {
      _drawSpikeBar(
        canvas,
        left: s.xNorm * size.width,
        top: s.yNorm * size.height,
        width: s.widthNorm * size.width,
      );
    }

    // 4. Colorful Hot Air Balloon (Yellow / Cobalt Blue / Crimson Red)
    final bCenter = Offset(balloonX * size.width, balloonY * size.height);
    if (shieldActive || magnetActive || slowActive) {
      final ringColor = shieldActive
          ? const Color(0xFFFACC15)
          : magnetActive
              ? const Color(0xFF0EA5E9)
              : const Color(0xFF9333EA);
      canvas.drawCircle(
        bCenter,
        29,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2
          ..color = ringColor.withValues(alpha: 0.78),
      );
    }
    _drawHotAirBalloon(canvas, bCenter);
  }

  void _drawStandardBubble(Canvas canvas, Offset center, double r) {
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = const Color(0xFF4B5563)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    // Crisp specular shine arc inside bubble matching screenshot
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r * 0.62),
      -pi * 0.75,
      pi * 0.45,
      false,
      Paint()
        ..color = const Color(0xFF9CA3AF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawCoinBubble(Canvas canvas, Offset center, double r) {
    canvas.drawCircle(
      center,
      r,
      Paint()..color = const Color(0xFFFEF3C7),
    );
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = const Color(0xFFD97706)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    canvas.drawCircle(
      center,
      r * 0.55,
      Paint()..color = const Color(0xFFF59E0B),
    );
  }

  void _drawPowerUpRing(
    Canvas canvas,
    Offset center,
    double r,
    BalloonPowerUpType type,
  ) {
    final Color ringColor;
    switch (type) {
      case BalloonPowerUpType.shield:
        ringColor = const Color(0xFFEAB308); // Yellow ring matching image!
        break;
      case BalloonPowerUpType.magnet:
        ringColor = const Color(0xFF0EA5E9); // Sky cyan ring
        break;
      case BalloonPowerUpType.slower:
        ringColor = const Color(0xFF9333EA); // Violet time slow ring
        break;
    }

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = ringColor.withValues(alpha: 0.14)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6,
    );
  }

  void _drawSpikeBar(
    Canvas canvas, {
    required double left,
    required double top,
    required double width,
  }) {
    const double barHeight = 5.5;
    const double toothWidth = 7.5;
    const double toothHeight = 7.0;

    final barPaint = Paint()..color = const Color(0xFF374151);
    final toothPaint = Paint()..color = const Color(0xFF1F2937);

    // Top horizontal beam
    canvas.drawRect(Rect.fromLTWH(left, top, width, barHeight), barPaint);

    // Sharp downward triangular spikes along underside
    final int teethCount = max(2, (width / toothWidth).floor());
    final double actualToothW = width / teethCount;
    final path = Path();
    for (int i = 0; i < teethCount; i++) {
      final tx = left + i * actualToothW;
      path
        ..moveTo(tx + 0.5, top + barHeight)
        ..lineTo(tx + actualToothW - 0.5, top + barHeight)
        ..lineTo(tx + actualToothW / 2, top + barHeight + toothHeight)
        ..close();
    }
    canvas.drawPath(path, toothPaint);
  }

  void _drawHotAirBalloon(Canvas canvas, Offset c) {
    final envRect = Rect.fromCenter(
      center: Offset(c.dx, c.dy - 6),
      width: 30,
      height: 31,
    );

    canvas.save();
    // Balloon envelope silhouette clipping
    final envelopePath = Path()
      ..addOval(envRect)
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(c.dx, c.dy + 6),
            width: 14,
            height: 8,
          ),
          const Radius.circular(2),
        ),
      );
    canvas.clipPath(envelopePath);

    // Left panel: Bright Yellow (#FACC15)
    canvas.drawRect(
      Rect.fromLTRB(envRect.left, envRect.top, c.dx - 5, envRect.bottom + 6),
      Paint()..color = const Color(0xFFFACC15),
    );
    // Right panel: Bright Red (#EF4444)
    canvas.drawRect(
      Rect.fromLTRB(c.dx + 5, envRect.top, envRect.right, envRect.bottom + 6),
      Paint()..color = const Color(0xFFEF4444),
    );
    // Center oval panel: Vibrant Blue (#2563EB)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx, c.dy - 5),
        width: 14,
        height: 34,
      ),
      Paint()..color = const Color(0xFF2563EB),
    );

    // Crisp white dividing seams between stripes
    final ribPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx, c.dy - 5),
        width: 14,
        height: 34,
      ),
      ribPaint,
    );
    canvas.restore();

    // Connecting ropes from balloon base to basket
    final ropePaint = Paint()
      ..color = const Color(0xFF374151)
      ..strokeWidth = 1.4;
    canvas.drawLine(
      Offset(c.dx - 5, c.dy + 10),
      Offset(c.dx - 4, c.dy + 16),
      ropePaint,
    );
    canvas.drawLine(
      Offset(c.dx + 5, c.dy + 10),
      Offset(c.dx + 4, c.dy + 16),
      ropePaint,
    );

    // Wicker pixel basket underneath
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(c.dx, c.dy + 18.5),
          width: 11,
          height: 6.5,
        ),
        const Radius.circular(1.5),
      ),
      Paint()..color = const Color(0xFF374151),
    );
  }

  @override
  bool shouldRepaint(covariant _BalloonPlayfieldPainter oldDelegate) => true;
}
