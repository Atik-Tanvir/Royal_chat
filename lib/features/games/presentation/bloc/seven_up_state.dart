import 'package:equatable/equatable.dart';
import '../../domain/entities/bucket_game_item.dart';
import '../../domain/entities/games_control_config.dart';
import '../../domain/entities/rewarded_ad_item.dart';
import '../../domain/entities/seven_up_game_entity.dart';

class SevenUpState extends Equatable {
  final bool isGroupMode;
  final bool isPartyLockedRoom;
  final String groupRoomId;
  final String groupRoomName;
  final int elapsedSeconds; // 0..18 progressive accelerating round timer
  final double speedMultiplier; // Smooth ramp -> fast at >=12s -> turbo >=15s
  final int roundNumber;
  final bool isRevealing;
  final DiceRollOutcome? revealedOutcome;
  final String? roundResultBanner;
  final bool didWinLastRound;
  final Map<String, int> userBets;
  final Map<String, int> groupBetsByZone;
  final List<GroupBetRecord> recentGroupActivity;
  final List<DiceRollOutcome> rollHistory;
  final int totalPoolCount;
  final int betInputAmount;
  final double syncedUserCoinBalance;
  final double guestFallbackBalance;
  final String? lastGroupWinnersSummary;
  final int profileBalanceSyncTick;
  final String? uiFeedbackMessage;
  final bool uiFeedbackNeedsAdRefill;
  final int uiFeedbackTick;
  final RewardedAdsConfig rewardedAdsConfig;
  final GamesControlConfig gamesConfig;
  final bool isLoadingAds;
  final int openWatchAdModalTick;

  const SevenUpState({
    this.isGroupMode = false,
    this.isPartyLockedRoom = false,
    this.groupRoomId = 'royal_group_1',
    this.groupRoomName = 'Royal Group #1',
    this.elapsedSeconds = 0,
    this.speedMultiplier = 1.0,
    this.roundNumber = 1,
    this.isRevealing = false,
    this.revealedOutcome,
    this.roundResultBanner,
    this.didWinLastRound = false,
    this.userBets = const {},
    this.groupBetsByZone = const {},
    this.recentGroupActivity = const [],
    this.rollHistory = const [],
    this.totalPoolCount = 131251,
    this.betInputAmount = 100,
    this.syncedUserCoinBalance = 0,
    this.guestFallbackBalance = 50000,
    this.lastGroupWinnersSummary,
    this.profileBalanceSyncTick = 0,
    this.uiFeedbackMessage,
    this.uiFeedbackNeedsAdRefill = false,
    this.uiFeedbackTick = 0,
    this.rewardedAdsConfig = const RewardedAdsConfig(),
    this.gamesConfig = GamesControlConfig.defaults,
    this.isLoadingAds = false,
    this.openWatchAdModalTick = 0,
  });

  int get configuredRoundSeconds =>
      gamesConfig.roundSecondsFor('game_7up_7down', fallback: 18);

  int get configuredBetLockSeconds =>
      gamesConfig.betLockSecondsFor('game_7up_7down', fallback: 15);

  bool get isBettingLocked =>
      !gamesConfig.isGamePlayable('game_7up_7down') ||
      elapsedSeconds >= configuredBetLockSeconds ||
      isRevealing;

  SevenUpState copyWith({
    bool? isGroupMode,
    bool? isPartyLockedRoom,
    String? groupRoomId,
    String? groupRoomName,
    int? elapsedSeconds,
    double? speedMultiplier,
    int? roundNumber,
    bool? isRevealing,
    DiceRollOutcome? revealedOutcome,
    bool clearRevealedOutcome = false,
    String? roundResultBanner,
    bool clearRoundResultBanner = false,
    bool? didWinLastRound,
    Map<String, int>? userBets,
    Map<String, int>? groupBetsByZone,
    List<GroupBetRecord>? recentGroupActivity,
    List<DiceRollOutcome>? rollHistory,
    int? totalPoolCount,
    int? betInputAmount,
    double? syncedUserCoinBalance,
    double? guestFallbackBalance,
    String? lastGroupWinnersSummary,
    bool clearGroupWinners = false,
    int? profileBalanceSyncTick,
    String? uiFeedbackMessage,
    bool? uiFeedbackNeedsAdRefill,
    int? uiFeedbackTick,
    RewardedAdsConfig? rewardedAdsConfig,
    GamesControlConfig? gamesConfig,
    bool? isLoadingAds,
    int? openWatchAdModalTick,
  }) {
    return SevenUpState(
      isGroupMode: isGroupMode ?? this.isGroupMode,
      isPartyLockedRoom: isPartyLockedRoom ?? this.isPartyLockedRoom,
      groupRoomId: groupRoomId ?? this.groupRoomId,
      groupRoomName: groupRoomName ?? this.groupRoomName,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      roundNumber: roundNumber ?? this.roundNumber,
      isRevealing: isRevealing ?? this.isRevealing,
      revealedOutcome: clearRevealedOutcome
          ? null
          : (revealedOutcome ?? this.revealedOutcome),
      roundResultBanner: clearRoundResultBanner
          ? null
          : (roundResultBanner ?? this.roundResultBanner),
      didWinLastRound: didWinLastRound ?? this.didWinLastRound,
      userBets: userBets ?? this.userBets,
      groupBetsByZone: groupBetsByZone ?? this.groupBetsByZone,
      recentGroupActivity: recentGroupActivity ?? this.recentGroupActivity,
      rollHistory: rollHistory ?? this.rollHistory,
      totalPoolCount: totalPoolCount ?? this.totalPoolCount,
      betInputAmount: betInputAmount ?? this.betInputAmount,
      syncedUserCoinBalance: syncedUserCoinBalance ?? this.syncedUserCoinBalance,
      guestFallbackBalance: guestFallbackBalance ?? this.guestFallbackBalance,
      lastGroupWinnersSummary: clearGroupWinners
          ? null
          : (lastGroupWinnersSummary ?? this.lastGroupWinnersSummary),
      profileBalanceSyncTick: profileBalanceSyncTick ?? this.profileBalanceSyncTick,
      uiFeedbackMessage: uiFeedbackMessage ?? this.uiFeedbackMessage,
      uiFeedbackNeedsAdRefill:
          uiFeedbackNeedsAdRefill ?? this.uiFeedbackNeedsAdRefill,
      uiFeedbackTick: uiFeedbackTick ?? this.uiFeedbackTick,
      rewardedAdsConfig: rewardedAdsConfig ?? this.rewardedAdsConfig,
      gamesConfig: gamesConfig ?? this.gamesConfig,
      isLoadingAds: isLoadingAds ?? this.isLoadingAds,
      openWatchAdModalTick: openWatchAdModalTick ?? this.openWatchAdModalTick,
    );
  }

  @override
  List<Object?> get props => [
        isGroupMode,
        isPartyLockedRoom,
        groupRoomId,
        groupRoomName,
        elapsedSeconds,
        speedMultiplier,
        roundNumber,
        isRevealing,
        revealedOutcome,
        roundResultBanner,
        didWinLastRound,
        userBets,
        groupBetsByZone,
        recentGroupActivity,
        rollHistory,
        totalPoolCount,
        betInputAmount,
        syncedUserCoinBalance,
        guestFallbackBalance,
        lastGroupWinnersSummary,
        profileBalanceSyncTick,
        uiFeedbackMessage,
        uiFeedbackNeedsAdRefill,
        uiFeedbackTick,
        rewardedAdsConfig,
        gamesConfig,
        isLoadingAds,
        openWatchAdModalTick,
      ];
}
