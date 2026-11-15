import 'package:equatable/equatable.dart';

class GameControlItemConfig extends Equatable {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final int minBet;
  final int maxBet;
  final int rtp;
  final int roundSeconds;
  final int betLockSeconds;
  final Map<String, double> multipliers;

  const GameControlItemConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.minBet,
    required this.maxBet,
    required this.rtp,
    required this.roundSeconds,
    required this.betLockSeconds,
    required this.multipliers,
  });

  double multiplierFor(String outcomeKey, {double fallback = 2.0}) {
    final val = multipliers[outcomeKey];
    if (val != null && val > 0) return val;
    // Backward-compatibility aliases for legacy keys
    if (outcomeKey == 'apple') return multipliers['bucket'] ?? fallback;
    if (outcomeKey == 'watermelon') return multipliers['mug'] ?? fallback;
    if (outcomeKey == 'bell') return multipliers['flower'] ?? fallback;
    if (outcomeKey == 'lucky7') return multipliers['star'] ?? fallback;
    if (outcomeKey == 'rocket') return multipliers['gift'] ?? fallback;
    return fallback;
  }

  int intParamFor(String key, {required int fallback}) {
    final val = multipliers[key];
    if (val == null || val <= 0) return fallback;
    return val.round();
  }

  factory GameControlItemConfig.fromJson(Map<String, dynamic> json) {
    final rawMults = json['multipliers'];
    final parsedMults = <String, double>{};
    if (rawMults is Map) {
      for (final entry in rawMults.entries) {
        final key = entry.key.toString();
        final numVal = (entry.value is num)
            ? (entry.value as num).toDouble()
            : double.tryParse(entry.value.toString());
        if (numVal != null && numVal > 0) {
          parsedMults[key] = numVal;
        }
      }
    }

    final roundSec = (json['roundSeconds'] as num?)?.toInt() ?? 35;
    final lockSec = (json['betLockSeconds'] as num?)?.toInt() ?? 30;
    final minB = (json['minBet'] as num?)?.toInt() ?? 100;
    final maxB = (json['maxBet'] as num?)?.toInt() ?? 10000;

    return GameControlItemConfig(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      isActive: json['isActive'] != false,
      minBet: minB < 10 ? 10 : minB,
      maxBet: maxB < minB ? minB : maxB,
      rtp: (json['rtp'] as num?)?.toInt() ?? 93,
      roundSeconds: roundSec < 10 ? 10 : roundSec,
      betLockSeconds: lockSec > roundSec ? roundSec : (lockSec < 5 ? 5 : lockSec),
      multipliers: parsedMults,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        isActive,
        minBet,
        maxBet,
        rtp,
        roundSeconds,
        betLockSeconds,
        multipliers,
      ];
}

class GamesControlConfig extends Equatable {
  final bool emergencyLockdown;
  final Map<String, GameControlItemConfig> gamesById;
  final String updatedAt;

  const GamesControlConfig({
    this.emergencyLockdown = false,
    this.gamesById = const {},
    this.updatedAt = '',
  });

  static const GamesControlConfig defaults = GamesControlConfig(
    emergencyLockdown: false,
    gamesById: {
      'game_bucket_8': GameControlItemConfig(
        id: 'game_bucket_8',
        name: 'Bucket Spin (8 Items)',
        description: '8-slot spinning cauldron prediction game (Solo & Group).',
        isActive: true,
        minBet: 100,
        maxBet: 10000,
        rtp: 94,
        roundSeconds: 35,
        betLockSeconds: 30,
        multipliers: {
          'apple': 2.0,
          'watermelon': 2.0,
          'bell': 2.0,
          'lucky7': 2.0,
          'diamond': 2.0,
          'crown': 2.0,
          'rocket': 2.0,
          'heart': 2.0,
        },
      ),
      'game_color_3': GameControlItemConfig(
        id: 'game_color_3',
        name: 'Color Spin (Red / Violet / Green)',
        description: '3-color cauldron prediction arena with per-color odds control.',
        isActive: true,
        minBet: 100,
        maxBet: 10000,
        rtp: 93,
        roundSeconds: 35,
        betLockSeconds: 30,
        multipliers: {
          'red': 2.0,
          'violet': 4.5,
          'green': 2.0,
        },
      ),
      'game_7up_7down': GameControlItemConfig(
        id: 'game_7up_7down',
        name: '7 Up 7 Down (Dice)',
        description: 'Fast 18-second dice prediction board (8~12, 7, 2~6).',
        isActive: true,
        minBet: 100,
        maxBet: 10000,
        rtp: 92,
        roundSeconds: 18,
        betLockSeconds: 15,
        multipliers: {
          'up': 2.0,
          'seven': 5.0,
          'down': 2.0,
        },
      ),
      'game_balloon_sky': GameControlItemConfig(
        id: 'game_balloon_sky',
        name: 'Balloon Sky (Arcade)',
        description: 'Solo endless flight with Free Earn coin bubbles and 2x Double Stake mode.',
        isActive: true,
        minBet: 100,
        maxBet: 5000,
        rtp: 95,
        roundSeconds: 40,
        betLockSeconds: 40,
        multipliers: {
          'standardBubbleCoins': 10.0,
          'goldBubbleCoins': 50.0,
          'distanceBonusPer4s': 5.0,
          'targetScore': 1000.0,
          'doubleTargetSeconds': 40.0,
          'doubleStakeMultiplier': 2.0,
          'speedBoostAfterSeconds': 40.0,
        },
      ),
    },
  );

  GameControlItemConfig gameFor(String gameId) {
    return gamesById[gameId] ??
        defaults.gamesById[gameId] ??
        GameControlItemConfig(
          id: gameId,
          name: gameId,
          description: '',
          isActive: true,
          minBet: 100,
          maxBet: 10000,
          rtp: 93,
          roundSeconds: 35,
          betLockSeconds: 30,
          multipliers: const {},
        );
  }

  bool isGamePlayable(String gameId) {
    if (emergencyLockdown) return false;
    return gameFor(gameId).isActive;
  }

  int minBetFor(String gameId) => gameFor(gameId).minBet;

  int maxBetFor(String gameId) => gameFor(gameId).maxBet;

  int roundSecondsFor(String gameId, {int fallback = 35}) {
    final val = gameFor(gameId).roundSeconds;
    return val > 0 ? val : fallback;
  }

  int betLockSecondsFor(String gameId, {int fallback = 30}) {
    final g = gameFor(gameId);
    return g.betLockSeconds > 0 ? g.betLockSeconds : fallback;
  }

  double multiplierFor(
    String gameId,
    String outcomeKey, {
    double fallback = 2.0,
  }) {
    return gameFor(gameId).multiplierFor(outcomeKey, fallback: fallback);
  }

  int intParamFor(
    String gameId,
    String key, {
    required int fallback,
  }) {
    return gameFor(gameId).intParamFor(key, fallback: fallback);
  }

  /// Formats a numeric multiplier cleanly (e.g. `2.0 -> "2x"`, `4.5 -> "4.5x"`).
  static String formatMultiplier(double multiplier) {
    final roundedInt = multiplier.roundToDouble();
    if ((multiplier - roundedInt).abs() < 0.01) {
      return '${roundedInt.toInt()}x';
    }
    return '${multiplier.toStringAsFixed(1)}x';
  }

  /// Formats win-ratio badge (e.g. `2.0 -> "Win 1:2"`, `4.5 -> "Win 1:4.5"`).
  static String formatWinRatio(double multiplier, {String prefix = 'Win 1:'}) {
    final roundedInt = multiplier.roundToDouble();
    final numText = (multiplier - roundedInt).abs() < 0.01
        ? '${roundedInt.toInt()}'
        : multiplier.toStringAsFixed(1);
    return '$prefix$numText';
  }

  factory GamesControlConfig.fromJson(Map<String, dynamic> json) {
    final merged = Map<String, GameControlItemConfig>.from(defaults.gamesById);
    final rawGames = json['games'];
    if (rawGames is List) {
      for (final raw in rawGames) {
        if (raw is Map) {
          final item = GameControlItemConfig.fromJson(
            Map<String, dynamic>.from(raw),
          );
          if (item.id.isNotEmpty) {
            merged[item.id] = item;
          }
        }
      }
    }
    return GamesControlConfig(
      emergencyLockdown: json['emergencyLockdown'] == true,
      gamesById: merged,
      updatedAt: (json['updatedAt'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [emergencyLockdown, gamesById, updatedAt];
}
