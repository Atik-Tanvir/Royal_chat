import 'package:equatable/equatable.dart';
import '../../domain/entities/bucket_game_item.dart';
import '../../domain/entities/rewarded_ad_item.dart';
import '../../domain/entities/seven_up_game_entity.dart';

abstract class SevenUpEvent extends Equatable {
  const SevenUpEvent();

  @override
  List<Object?> get props => [];
}

class InitSevenUpEvent extends SevenUpEvent {
  final String? partyRoomId;
  final String? partyRoomName;
  final double initialUserCoinBalance;

  const InitSevenUpEvent({
    this.partyRoomId,
    this.partyRoomName,
    required this.initialUserCoinBalance,
  });

  @override
  List<Object?> get props => [partyRoomId, partyRoomName, initialUserCoinBalance];
}

class SyncSevenUpUserBalanceEvent extends SevenUpEvent {
  final double coinBalance;

  const SyncSevenUpUserBalanceEvent(this.coinBalance);

  @override
  List<Object?> get props => [coinBalance];
}

class SwitchSevenUpModeEvent extends SevenUpEvent {
  final bool isGroupMode;

  const SwitchSevenUpModeEvent(this.isGroupMode);

  @override
  List<Object?> get props => [isGroupMode];
}

class ChangeSevenUpGroupRoomEvent extends SevenUpEvent {
  final String roomId;
  final String roomName;

  const ChangeSevenUpGroupRoomEvent({
    required this.roomId,
    required this.roomName,
  });

  @override
  List<Object?> get props => [roomId, roomName];
}

class TickSevenUpTimerEvent extends SevenUpEvent {
  const TickSevenUpTimerEvent();
}

class FinishSevenUpSoloRevealEvent extends SevenUpEvent {
  const FinishSevenUpSoloRevealEvent();
}

class PlaceSevenUpBetEvent extends SevenUpEvent {
  final SevenUpZone zone;

  const PlaceSevenUpBetEvent(this.zone);

  @override
  List<Object?> get props => [zone];
}

class StepSevenUpBetCoinEvent extends SevenUpEvent {
  final bool isIncrement;

  const StepSevenUpBetCoinEvent({required this.isIncrement});

  @override
  List<Object?> get props => [isIncrement];
}

class SetSevenUpPresetCoinEvent extends SevenUpEvent {
  final int amount;

  const SetSevenUpPresetCoinEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}

class UpdateSevenUpCustomCoinTextEvent extends SevenUpEvent {
  final String rawText;

  const UpdateSevenUpCustomCoinTextEvent(this.rawText);

  @override
  List<Object?> get props => [rawText];
}

class RemoteSevenUpBetReceivedEvent extends SevenUpEvent {
  final GroupBetRecord bet;
  final int round;

  const RemoteSevenUpBetReceivedEvent({
    required this.bet,
    required this.round,
  });

  @override
  List<Object?> get props => [bet, round];
}

class FetchSevenUpRewardedAdsEvent extends SevenUpEvent {
  final bool openDialogAfterFetch;

  const FetchSevenUpRewardedAdsEvent({this.openDialogAfterFetch = false});

  @override
  List<Object?> get props => [openDialogAfterFetch];
}

class ClaimSevenUpAdRewardEvent extends SevenUpEvent {
  final RewardedAdItem ad;

  const ClaimSevenUpAdRewardEvent(this.ad);

  @override
  List<Object?> get props => [ad];
}

class FetchSevenUpGamesControlEvent extends SevenUpEvent {
  const FetchSevenUpGamesControlEvent();
}
