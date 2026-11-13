import 'package:equatable/equatable.dart';
import '../../domain/entities/bucket_game_item.dart';
import '../../domain/entities/color_game_option.dart';
import '../../domain/entities/rewarded_ad_item.dart';

abstract class ColorGameEvent extends Equatable {
  const ColorGameEvent();

  @override
  List<Object?> get props => [];
}

class InitColorGameEvent extends ColorGameEvent {
  final String? partyRoomId;
  final String? partyRoomName;
  final double initialUserCoinBalance;

  const InitColorGameEvent({
    this.partyRoomId,
    this.partyRoomName,
    required this.initialUserCoinBalance,
  });

  @override
  List<Object?> get props => [partyRoomId, partyRoomName, initialUserCoinBalance];
}

class SyncColorUserBalanceEvent extends ColorGameEvent {
  final double coinBalance;

  const SyncColorUserBalanceEvent(this.coinBalance);

  @override
  List<Object?> get props => [coinBalance];
}

class SwitchColorGameModeEvent extends ColorGameEvent {
  final bool isGroupMode;

  const SwitchColorGameModeEvent(this.isGroupMode);

  @override
  List<Object?> get props => [isGroupMode];
}

class ChangeColorGroupRoomEvent extends ColorGameEvent {
  final String roomId;
  final String roomName;

  const ChangeColorGroupRoomEvent({
    required this.roomId,
    required this.roomName,
  });

  @override
  List<Object?> get props => [roomId, roomName];
}

class TickColorTimerEvent extends ColorGameEvent {
  const TickColorTimerEvent();
}

class FinishColorSoloRevealEvent extends ColorGameEvent {
  const FinishColorSoloRevealEvent();
}

class PlaceColorBetEvent extends ColorGameEvent {
  final ColorGameOption option;

  const PlaceColorBetEvent(this.option);

  @override
  List<Object?> get props => [option];
}

class StepColorBetCoinEvent extends ColorGameEvent {
  final bool isIncrement;

  const StepColorBetCoinEvent({required this.isIncrement});

  @override
  List<Object?> get props => [isIncrement];
}

class SetColorPresetCoinEvent extends ColorGameEvent {
  final int amount;

  const SetColorPresetCoinEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}

class UpdateColorCustomCoinTextEvent extends ColorGameEvent {
  final String rawText;

  const UpdateColorCustomCoinTextEvent(this.rawText);

  @override
  List<Object?> get props => [rawText];
}

class RemoteColorGroupBetReceivedEvent extends ColorGameEvent {
  final GroupBetRecord bet;
  final int round;

  const RemoteColorGroupBetReceivedEvent({
    required this.bet,
    required this.round,
  });

  @override
  List<Object?> get props => [bet, round];
}

class FetchColorRewardedAdsEvent extends ColorGameEvent {
  final bool openDialogAfterFetch;

  const FetchColorRewardedAdsEvent({this.openDialogAfterFetch = false});

  @override
  List<Object?> get props => [openDialogAfterFetch];
}

class ClaimColorAdRewardEvent extends ColorGameEvent {
  final RewardedAdItem ad;

  const ClaimColorAdRewardEvent(this.ad);

  @override
  List<Object?> get props => [ad];
}

class FetchColorGamesControlEvent extends ColorGameEvent {
  const FetchColorGamesControlEvent();
}
