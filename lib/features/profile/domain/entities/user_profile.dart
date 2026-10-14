import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String userId;
  final String nickname;
  final String avatarUrl;
  final String country;
  final String gender;
  final int age;
  final int level;
  final bool isVip;
  final int friendsCount;
  final int followingCount;
  final int fansCount;
  final int visitorsCount;
  final double gemBalance;
  final double coinBalance;

  const UserProfile({
    required this.userId,
    required this.nickname,
    required this.avatarUrl,
    required this.country,
    required this.gender,
    required this.age,
    required this.level,
    required this.isVip,
    required this.friendsCount,
    required this.followingCount,
    required this.fansCount,
    required this.visitorsCount,
    required this.gemBalance,
    required this.coinBalance,
  });

  String get formattedCoins {
    if (coinBalance >= 1000) {
      return '${(coinBalance / 1000).toStringAsFixed(2)}K';
    }
    return coinBalance.toStringAsFixed(0);
  }

  String get formattedGems {
    return gemBalance.toStringAsFixed(0);
  }

  @override
  List<Object?> get props => [
        userId,
        nickname,
        avatarUrl,
        country,
        gender,
        age,
        level,
        isVip,
        friendsCount,
        followingCount,
        fansCount,
        visitorsCount,
        gemBalance,
        coinBalance,
      ];
}
