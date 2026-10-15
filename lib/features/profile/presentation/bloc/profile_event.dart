import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfileEvent extends ProfileEvent {}

class RechargeCoinsEvent extends ProfileEvent {
  final double amount;

  const RechargeCoinsEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}

class WithdrawGemsEvent extends ProfileEvent {
  final double gems;
  final String gateway;
  final String accountNumber;

  const WithdrawGemsEvent(this.gems, {this.gateway = 'bKash', this.accountNumber = ''});

  @override
  List<Object?> get props => [gems, gateway, accountNumber];
}

class UpdateProfileDetailsEvent extends ProfileEvent {
  final String? nickname;
  final String? avatarUrl;
  final String? country;
  final String? gender;
  final int? age;

  const UpdateProfileDetailsEvent({
    this.nickname,
    this.avatarUrl,
    this.country,
    this.gender,
    this.age,
  });

  @override
  List<Object?> get props => [nickname, avatarUrl, country, gender, age];
}
