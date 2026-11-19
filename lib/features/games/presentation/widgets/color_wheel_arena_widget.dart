import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../domain/entities/color_game_option.dart';
import '../../domain/entities/games_control_config.dart';

/// Pixel-perfect 3-Color Wheel Spinner matching user mockup:
/// - Single frame-rate ticker for 100% reliable physics & glitch-free spin.
/// - Normal steady spin when timeLeft > 5.
/// - Hyper-fast high-speed spin (32 rad/s) during final 5 seconds before draw.
/// - Smooth deceleration and exact landing on winning sector during draw settlement.
/// - Center hub dynamically reflects the sector passing under the pointer.
/// - Large, prominent white diamond pointer at 12 o'clock.
class ColorWheelArenaWidget extends StatefulWidget {
  final int timeLeft;
  final bool isRevealing;
  final ColorGameOption? revealedColor;
  final bool didWin;
  final double redMultiplier;
  final double violetMultiplier;
  final double greenMultiplier;

  const ColorWheelArenaWidget({
    super.key,
    required this.timeLeft,
    required this.isRevealing,
    required this.revealedColor,
    required this.didWin,
    this.redMultiplier = 2.0,
    this.violetMultiplier = 5.0,
    this.greenMultiplier = 2.0,
  });

  @override
  State<ColorWheelArenaWidget> createState() => _ColorWheelArenaWidgetState();
}

class _ColorWheelArenaWidgetState extends State<ColorWheelArenaWidget>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _currentAngle = 0.0;
  Duration? _lastTimestamp;

  bool _isSettling = false;
  double _settleStartAngle = 0.0;
  double _settleTargetAngle = 0.0;
  DateTime? _settleStartTime;
  static const int _settleDurationMs = 1900;

  bool get _isUrgent =>
      widget.timeLeft <= 5 && widget.timeLeft > 0 && !widget.isRevealing;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant ColorWheelArenaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isRevealing && !oldWidget.isRevealing) {
      _startSettle();
    } else if (!widget.isRevealing && oldWidget.isRevealing) {
      _isSettling = false;
      _settleStartTime = null;
    }
  }

  void _startSettle() {
    _isSettling = true;
    _settleStartTime = DateTime.now();
    _settleStartAngle = _currentAngle;

    // Target landing angle so the winning color aligns precisely under the 12 o'clock pointer:
    // VIOLET is centered at -90 deg (target offset = 0.0)
    // GREEN is centered at +30 deg (target offset = +240 deg = +4pi/3)
    // RED is centered at +150 deg (target offset = +120 deg = +2pi/3)
    double targetOffset = 0.0;
    final winId = widget.revealedColor?.id ?? 'violet';
    if (winId == 'green') {
      targetOffset = 4 * pi / 3;
    } else if (winId == 'red') {
      targetOffset = 2 * pi / 3;
    } else {
      targetOffset = 0.0;
    }

    final currentNorm = _settleStartAngle % (2 * pi);
    double delta = (targetOffset - currentNorm) % (2 * pi);
    if (delta < 0) delta += 2 * pi;

    // Add 6 full fast rotations so it continues spinning at hyper-speed before smoothly braking on the winner
    _settleTargetAngle = _settleStartAngle + delta + 6 * (2 * pi);
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    if (_lastTimestamp == null) {
      _lastTimestamp = elapsed;
      return;
    }

    final dtSeconds = (elapsed - _lastTimestamp!).inMicroseconds / 1000000.0;
    _lastTimestamp = elapsed;
    final dt = dtSeconds.clamp(0.001, 0.05);

    if (_isSettling && _settleStartTime != null) {
      final elapsedMs =
          DateTime.now().difference(_settleStartTime!).inMilliseconds;
      if (elapsedMs >= _settleDurationMs) {
        _currentAngle = _settleTargetAngle;
      } else {
        final progress = (elapsedMs / _settleDurationMs).clamp(0.0, 1.0);
        final curved = Curves.easeOutCubic.transform(progress);
        _currentAngle =
            _settleStartAngle + (_settleTargetAngle - _settleStartAngle) * curved;
      }
    } else {
      final isUrgent =
          widget.timeLeft <= 5 && widget.timeLeft > 0 && !widget.isRevealing;
      // Hyper-fast rotation (32 rad/s = ~5.1 spins/second) during last 5 seconds
      // Smooth steady spin (1.8 rad/s = ~3.5s per spin) during normal betting
      final speed = isUrgent ? 32.0 : 1.8;
      _currentAngle += speed * dt;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  String _getActiveSectorLabel(double rotationAngle) {
    if (widget.isRevealing && !_isSettling && widget.revealedColor != null) {
      return widget.revealedColor!.name;
    }

    // Angle on the wheel currently under the 12 o'clock pointer (-pi/2)
    final norm = ((-pi / 2 - rotationAngle) % (2 * pi) + 2 * pi) % (2 * pi);
    // VIOLET sector: from 210 deg (7pi/6) to 330 deg (11pi/6)
    if (norm >= (7 * pi / 6) && norm < (11 * pi / 6)) {
      return 'VIOLET';
    } else if (norm >= (11 * pi / 6) || norm < (pi / 2)) {
      return 'GREEN';
    } else {
      return 'RED';
    }
  }

  Color _getActiveSectorColor(String label) {
    if (label == 'RED') return const Color(0xFFFF001E);
    if (label == 'GREEN') return const Color(0xFF00C853);
    return const Color(0xFF7C00FF);
  }

  @override
  Widget build(BuildContext context) {
    final activeLabel = _getActiveSectorLabel(_currentAngle);
    final activeColor = _getActiveSectorColor(activeLabel);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE879F9).withValues(alpha: 0.22),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Badge: RED 2x
          _buildSidePill(
            color: const Color(0xFFFF001E),
            label: 'RED',
            multiplier: GamesControlConfig.formatMultiplier(widget.redMultiplier),
            height: 66,
            width: 74,
          ),

          // Center 3-Color Wheel with Metallic Ring and Large Diamond Pointer
          SizedBox(
            width: 176,
            height: 176,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Outer Chrome / Silver Metallic Ring
                Container(
                  width: 172,
                  height: 172,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const SweepGradient(
                      colors: [
                        Color(0xFFE2E8F0),
                        Color(0xFF94A3B8),
                        Color(0xFFFFFFFF),
                        Color(0xFF64748B),
                        Color(0xFFE2E8F0),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: _isUrgent ? 0.8 : 0.4),
                        blurRadius: _isUrgent ? 24 : 14,
                        spreadRadius: _isUrgent ? 3 : 1,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(5.5),
                  child: ClipOval(
                    child: Transform.rotate(
                      angle: _currentAngle,
                      child: CustomPaint(
                        painter: _TriColorWheelPainter(),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),

                // Center Hub with Active/Winning Color Name
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activeColor,
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 2.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.65),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      activeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),

                // Prominent Extra-Large White Diamond Pointer at 12 o'clock (pointing DOWN)
                Positioned(
                  top: -8,
                  child: _buildProminentPointer(),
                ),
              ],
            ),
          ),

          // Right Badges: VIOLET 5x and GREEN 2x
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSidePill(
                color: const Color(0xFF7C00FF),
                label: 'VIOLET',
                multiplier: GamesControlConfig.formatMultiplier(widget.violetMultiplier),
                height: 52,
                width: 74,
              ),
              const SizedBox(height: 8),
              _buildSidePill(
                color: const Color(0xFF00C853),
                label: 'GREEN',
                multiplier: GamesControlConfig.formatMultiplier(widget.greenMultiplier),
                height: 52,
                width: 74,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Prominent, extra-large white diamond pointer at 12 o'clock pointing down at the wheel.
  Widget _buildProminentPointer() {
    return Container(
      width: 32,
      height: 34,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _DiamondPointerPainter(),
      ),
    );
  }

  /// Flanking solid pill matching user mockup
  Widget _buildSidePill({
    required Color color,
    required String label,
    required String multiplier,
    required double height,
    required double width,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            multiplier,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the 3-Sector Color Wheel (Violet, Green, Red)
class _TriColorWheelPainter extends CustomPainter {
  static const Color _red = Color(0xFFFF001E);
  static const Color _violet = Color(0xFF7C00FF);
  static const Color _green = Color(0xFF00C853);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final sectorSweep = 2 * pi / 3; // 120 degrees

    final paint = Paint()..style = PaintingStyle.fill;

    // Sector 1: VIOLET (centered at -90 deg / 12 o'clock, from -150 deg to -30 deg)
    paint.color = _violet;
    canvas.drawArc(rect, -5 * pi / 6, sectorSweep, true, paint);

    // Sector 2: GREEN (from -30 deg to 90 deg)
    paint.color = _green;
    canvas.drawArc(rect, -pi / 6, sectorSweep, true, paint);

    // Sector 3: RED (from 90 deg to 210 deg)
    paint.color = _red;
    canvas.drawArc(rect, pi / 2, sectorSweep, true, paint);

    // Thin Crisp Dividers between sectors
    final dividerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 3; i++) {
      final angle = -5 * pi / 6 + i * sectorSweep;
      final edge = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(center, edge, dividerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Extra-Large White Diamond Pointer pointing downwards at the wheel
class _DiamondPointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w / 2, 0) // Top vertex
      ..lineTo(w, h * 0.42) // Right vertex
      ..lineTo(w / 2, h) // Bottom tip pointing down
      ..lineTo(0, h * 0.42) // Left vertex
      ..close();

    // Solid bright white fill
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 3D inner shade on right facet
    final rightShadePath = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, h * 0.42)
      ..lineTo(w / 2, h)
      ..close();

    final shadePaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawPath(rightShadePath, shadePaint);

    // Metallic silver outline
    final strokePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
