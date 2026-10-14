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

  const WithdrawGemsEvent(this.gems);

  @override
  List<Object?> get props => [gems];
}
