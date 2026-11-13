import 'package:equatable/equatable.dart';
import '../../domain/entities/balloon_game_entity.dart';
import '../../domain/entities/rewarded_ad_item.dart';

abstract class BalloonGameEvent extends Equatable {
  const BalloonGameEvent();

  @override
  List<Object?> get props => [];
}

class InitBalloonGameEvent extends BalloonGameEvent {
  final double initialUserCoinBalance;

  const InitBalloonGameEvent({this.initialUserCoinBalance = 0});

  @override
  List<Object?> get props => [initialUserCoinBalance];
}

class SyncBalloonUserBalanceEvent extends BalloonGameEvent {
  final double newBalance;

  const SyncBalloonUserBalanceEvent(this.newBalance);

  @override
  List<Object?> get props => [newBalance];
}

class SelectBalloonPlayModeEvent extends BalloonGameEvent {
  final BalloonPlayMode mode;

  const SelectBalloonPlayModeEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}

class StepBalloonStakeCoinEvent extends BalloonGameEvent {
  final bool isIncrement;

  const StepBalloonStakeCoinEvent({required this.isIncrement});

  @override
  List<Object?> get props => [isIncrement];
}

class SetBalloonPresetStakeEvent extends BalloonGameEvent {
  final int amount;

  const SetBalloonPresetStakeEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}

class UpdateBalloonCustomStakeTextEvent extends BalloonGameEvent {
  final String rawText;

  const UpdateBalloonCustomStakeTextEvent(this.rawText);

  @override
  List<Object?> get props => [rawText];
}

class StartBalloonRunEvent extends BalloonGameEvent {
  const StartBalloonRunEvent();
}

class TogglePauseBalloonRunEvent extends BalloonGameEvent {
  const TogglePauseBalloonRunEvent();
}

class FinishBalloonRunEvent extends BalloonGameEvent {
  final int score;
  final int bubbleCoinsEarned;
  final double survivedSeconds;
  final bool doubleTargetCleared;

  const FinishBalloonRunEvent({
    required this.score,
    required this.bubbleCoinsEarned,
    required this.survivedSeconds,
    required this.doubleTargetCleared,
  });

  @override
  List<Object?> get props => [
        score,
        bubbleCoinsEarned,
        survivedSeconds,
        doubleTargetCleared,
      ];
}

class FetchBalloonRewardedAdsEvent extends BalloonGameEvent {
  final bool openDialogAfterFetch;

  const FetchBalloonRewardedAdsEvent({this.openDialogAfterFetch = true});

  @override
  List<Object?> get props => [openDialogAfterFetch];
}

class ClaimBalloonAdRewardEvent extends BalloonGameEvent {
  final RewardedAdItem ad;

  const ClaimBalloonAdRewardEvent(this.ad);

  @override
  List<Object?> get props => [ad];
}

class FetchBalloonGamesControlEvent extends BalloonGameEvent {
  const FetchBalloonGamesControlEvent();
}
