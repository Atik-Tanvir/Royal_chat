import 'package:equatable/equatable.dart';
import '../../domain/entities/balloon_game_entity.dart';
import '../../domain/entities/games_control_config.dart';
import '../../domain/entities/rewarded_ad_item.dart';

class BalloonGameState extends Equatable {
  static const int defaultDoubleTargetSeconds = 25;

  final BalloonPlayMode playMode;
  final BalloonGamePhase phase;
  final int stakeInputAmount;
  final int activeRunStake;
  final int runSeedTick;
  final int bestScore;
  final BalloonRunSummary? lastRunSummary;
  final double syncedUserCoinBalance;
  final double guestFallbackBalance;
  final int profileBalanceSyncTick;
  final String? uiFeedbackMessage;
  final bool uiFeedbackNeedsAdRefill;
  final int uiFeedbackTick;
  final RewardedAdsConfig rewardedAdsConfig;
  final GamesControlConfig gamesConfig;
  final bool isLoadingAds;
  final int openWatchAdModalTick;

  const BalloonGameState({
    this.playMode = BalloonPlayMode.freeEarn,
    this.phase = BalloonGamePhase.ready,
    this.stakeInputAmount = 100,
    this.activeRunStake = 0,
    this.runSeedTick = 0,
    this.bestScore = 0,
    this.lastRunSummary,
    this.syncedUserCoinBalance = 0,
    this.guestFallbackBalance = 50000,
    this.profileBalanceSyncTick = 0,
    this.uiFeedbackMessage,
    this.uiFeedbackNeedsAdRefill = false,
    this.uiFeedbackTick = 0,
    this.rewardedAdsConfig = const RewardedAdsConfig(),
    this.gamesConfig = GamesControlConfig.defaults,
    this.isLoadingAds = false,
    this.openWatchAdModalTick = 0,
  });

  int get targetScore => gamesConfig.intParamFor(
        'game_balloon_sky',
        'targetScore',
        fallback: 1000,
      );

  int get doubleTargetSeconds => gamesConfig.intParamFor(
        'game_balloon_sky',
        'doubleTargetSeconds',
        fallback: 40,
      );

  double get doubleStakeMultiplier => gamesConfig.multiplierFor(
        'game_balloon_sky',
        'doubleStakeMultiplier',
        fallback: 2.0,
      );

  int get standardBubbleCoins => gamesConfig.intParamFor(
        'game_balloon_sky',
        'standardBubbleCoins',
        fallback: 10,
      );

  int get goldBubbleCoins => gamesConfig.intParamFor(
        'game_balloon_sky',
        'goldBubbleCoins',
        fallback: 50,
      );

  int get distanceBonusPer4s => gamesConfig.intParamFor(
        'game_balloon_sky',
        'distanceBonusPer4s',
        fallback: 5,
      );

  int get speedBoostAfterSeconds => gamesConfig.intParamFor(
        'game_balloon_sky',
        'speedBoostAfterSeconds',
        fallback: 40,
      );

  BalloonGameState copyWith({
    BalloonPlayMode? playMode,
    BalloonGamePhase? phase,
    int? stakeInputAmount,
    int? activeRunStake,
    int? runSeedTick,
    int? bestScore,
    BalloonRunSummary? lastRunSummary,
    bool clearLastRunSummary = false,
    double? syncedUserCoinBalance,
    double? guestFallbackBalance,
    int? profileBalanceSyncTick,
    String? uiFeedbackMessage,
    bool? uiFeedbackNeedsAdRefill,
    int? uiFeedbackTick,
    RewardedAdsConfig? rewardedAdsConfig,
    GamesControlConfig? gamesConfig,
    bool? isLoadingAds,
    int? openWatchAdModalTick,
  }) {
    return BalloonGameState(
      playMode: playMode ?? this.playMode,
      phase: phase ?? this.phase,
      stakeInputAmount: stakeInputAmount ?? this.stakeInputAmount,
      activeRunStake: activeRunStake ?? this.activeRunStake,
      runSeedTick: runSeedTick ?? this.runSeedTick,
      bestScore: bestScore ?? this.bestScore,
      lastRunSummary: clearLastRunSummary
          ? null
          : (lastRunSummary ?? this.lastRunSummary),
      syncedUserCoinBalance:
          syncedUserCoinBalance ?? this.syncedUserCoinBalance,
      guestFallbackBalance: guestFallbackBalance ?? this.guestFallbackBalance,
      profileBalanceSyncTick:
          profileBalanceSyncTick ?? this.profileBalanceSyncTick,
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
        playMode,
        phase,
        stakeInputAmount,
        activeRunStake,
        runSeedTick,
        bestScore,
        lastRunSummary,
        syncedUserCoinBalance,
        guestFallbackBalance,
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
