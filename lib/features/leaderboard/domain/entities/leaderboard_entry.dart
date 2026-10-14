import 'package:equatable/equatable.dart';

enum LeaderboardType { wealth, game, charm, invitation }
enum LeaderboardTimeframe { daily, monthly }

class LeaderboardEntry extends Equatable {
  final int rank;
  final String username;
  final String? avatarUrl;
  final String flagEmoji;
  final String gender;
  final int age;
  final int level;
  final String levelType; // 'LV', 'LVO', etc.
  final double amount;
  final String amountFormatted;
  final bool isGems; // true for charm, false for coins
  final double usdEquivalent;
  final bool isVip;

  const LeaderboardEntry({
    required this.rank,
    required this.username,
    this.avatarUrl,
    required this.flagEmoji,
    required this.gender,
    required this.age,
    required this.level,
    this.levelType = 'LV',
    required this.amount,
    required this.amountFormatted,
    this.isGems = false,
    required this.usdEquivalent,
    this.isVip = false,
  });

  @override
  List<Object?> get props => [
        rank,
        username,
        avatarUrl,
        flagEmoji,
        gender,
        age,
        level,
        amountFormatted,
        isGems,
        usdEquivalent,
      ];
}
