import 'package:equatable/equatable.dart';

/// Play mode for Game #4 (Hot Air Balloon — Solo Arcade).
/// - [freeEarn]: Play without risking balance; earn coins from bubbles & flight distance.
/// - [doubleStake]: Stake coins to earn 2x payout on clearing target flight time (runs speedier!).
enum BalloonPlayMode {
  freeEarn,
  doubleStake,
}

enum BalloonGamePhase {
  ready,
  playing,
  paused,
  gameOver,
}

enum BalloonPowerUpType {
  shield, // Temporary yellow ring immunity against spike bars
  magnet, // Pulls nearby bubbles automatically
  slower, // Temporarily slows down scroll speed
}

/// Horizontal black pixel spike bar hazard falling from the top.
class BalloonSpikeBar {
  double xNorm; // Left X normalized (0.0 .. 1.0)
  double yNorm; // Top Y normalized (0.0 .. 1.0+)
  final double widthNorm; // Bar width fraction of canvas width (e.g. 0.16 .. 0.50)

  BalloonSpikeBar({
    required this.xNorm,
    required this.yNorm,
    required this.widthNorm,
  });
}

/// Collectible floating bubble (standard, gold coin, or power-up ring).
class BalloonBubble {
  double xNorm;
  double yNorm;
  final double radiusPx;
  final bool isCoinBubble;
  final BalloonPowerUpType? powerUp;

  BalloonBubble({
    required this.xNorm,
    required this.yNorm,
    this.radiusPx = 10.5,
    this.isCoinBubble = false,
    this.powerUp,
  });
}

/// Result summary emitted when a flight ends.
class BalloonRunSummary extends Equatable {
  final int score;
  final int earnedCoins;
  final int stakedCoins;
  final bool doubleWon;
  final double survivedSeconds;

  const BalloonRunSummary({
    required this.score,
    required this.earnedCoins,
    required this.stakedCoins,
    required this.doubleWon,
    required this.survivedSeconds,
  });

  @override
  List<Object?> get props => [
        score,
        earnedCoins,
        stakedCoins,
        doubleWon,
        survivedSeconds,
      ];
}
