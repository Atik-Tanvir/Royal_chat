import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfileEvent extends ProfileEvent {}

class LoadTransactionsEvent extends ProfileEvent {}

class RechargeCoinsEvent extends ProfileEvent {
  final double amount;
  final String gateway;
  final String packageTitle;

  const RechargeCoinsEvent(
    this.amount, {
    this.gateway = 'Google Play',
    this.packageTitle = 'Coin Top-up',
  });

  @override
  List<Object?> get props => [amount, gateway, packageTitle];
}

class WithdrawGemsEvent extends ProfileEvent {
  final double gems;
  final String gateway;
  final String accountNumber;

  const WithdrawGemsEvent(
    this.gems, {
    this.gateway = 'bKash',
    this.accountNumber = '',
  });

  @override
  List<Object?> get props => [gems, gateway, accountNumber];
}

class ConvertGemsToCoinsEvent extends ProfileEvent {
  final double gems;
  final double coins;

  const ConvertGemsToCoinsEvent({
    required this.gems,
    required this.coins,
  });

  @override
  List<Object?> get props => [gems, coins];
}

class ClaimDailyRewardEvent extends ProfileEvent {
  final int dayNumber;
  final double rewardCoins;

  const ClaimDailyRewardEvent({
    required this.dayNumber,
    required this.rewardCoins,
  });

  @override
  List<Object?> get props => [dayNumber, rewardCoins];
}

class ProfileBalancesUpdatedFromRealtimeEvent extends ProfileEvent {
  final double? coinBalance;
  final double? gemBalance;

  const ProfileBalancesUpdatedFromRealtimeEvent({
    this.coinBalance,
    this.gemBalance,
  });

  @override
  List<Object?> get props => [coinBalance, gemBalance];
}

class UpdateProfileDetailsEvent extends ProfileEvent {
  final String? nickname;
  final String? avatarUrl;
  final String? country;
  final String? countryFlag;
  final String? language;
  final String? bio;
  final String? gender;
  final int? age;

  const UpdateProfileDetailsEvent({
    this.nickname,
    this.avatarUrl,
    this.country,
    this.countryFlag,
    this.language,
    this.bio,
    this.gender,
    this.age,
  });

  @override
  List<Object?> get props => [
        nickname,
        avatarUrl,
        country,
        countryFlag,
        language,
        bio,
        gender,
        age,
      ];
}

class SignOutEvent extends ProfileEvent {}
