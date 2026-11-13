import 'package:equatable/equatable.dart';
import '../../domain/entities/bucket_game_item.dart';
import '../../domain/entities/rewarded_ad_item.dart';

abstract class BucketGameEvent extends Equatable {
  const BucketGameEvent();

  @override
  List<Object?> get props => [];
}

class InitBucketGameEvent extends BucketGameEvent {
  final String? partyRoomId;
  final String? partyRoomName;
  final double initialUserCoinBalance;

  const InitBucketGameEvent({
    this.partyRoomId,
    this.partyRoomName,
    required this.initialUserCoinBalance,
  });

  @override
  List<Object?> get props => [partyRoomId, partyRoomName, initialUserCoinBalance];
}

class SyncUserCoinBalanceEvent extends BucketGameEvent {
  final double coinBalance;

  const SyncUserCoinBalanceEvent(this.coinBalance);

  @override
  List<Object?> get props => [coinBalance];
}

class SwitchBucketGameModeEvent extends BucketGameEvent {
  final bool isGroupMode;

  const SwitchBucketGameModeEvent(this.isGroupMode);

  @override
  List<Object?> get props => [isGroupMode];
}

class ChangeGroupRoomEvent extends BucketGameEvent {
  final String roomId;
  final String roomName;

  const ChangeGroupRoomEvent({
    required this.roomId,
    required this.roomName,
  });

  @override
  List<Object?> get props => [roomId, roomName];
}

class TickBucketTimerEvent extends BucketGameEvent {
  const TickBucketTimerEvent();
}

class FinishSoloRevealEvent extends BucketGameEvent {
  const FinishSoloRevealEvent();
}

class PlaceBucketBetEvent extends BucketGameEvent {
  final BucketGameItem item;

  const PlaceBucketBetEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class StepBetCoinEvent extends BucketGameEvent {
  final bool isIncrement;

  const StepBetCoinEvent({required this.isIncrement});

  @override
  List<Object?> get props => [isIncrement];
}

class SetPresetBetCoinEvent extends BucketGameEvent {
  final int amount;

  const SetPresetBetCoinEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}

class UpdateCustomBetCoinTextEvent extends BucketGameEvent {
  final String rawText;

  const UpdateCustomBetCoinTextEvent(this.rawText);

  @override
  List<Object?> get props => [rawText];
}

class RemoteGroupBetReceivedEvent extends BucketGameEvent {
  final GroupBetRecord bet;
  final int round;

  const RemoteGroupBetReceivedEvent({
    required this.bet,
    required this.round,
  });

  @override
  List<Object?> get props => [bet, round];
}

class FetchRewardedAdsEvent extends BucketGameEvent {
  final bool openDialogAfterFetch;

  const FetchRewardedAdsEvent({this.openDialogAfterFetch = false});

  @override
  List<Object?> get props => [openDialogAfterFetch];
}

class ClaimAdRewardEvent extends BucketGameEvent {
  final RewardedAdItem ad;

  const ClaimAdRewardEvent(this.ad);

  @override
  List<Object?> get props => [ad];
}

class FetchBucketGamesControlEvent extends BucketGameEvent {
  const FetchBucketGamesControlEvent();
}
