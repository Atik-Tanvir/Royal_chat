import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../domain/entities/balloon_game_entity.dart';
import '../../domain/entities/games_control_config.dart';
import '../../domain/repositories/bucket_game_repository.dart';
import 'balloon_game_event.dart';
import 'balloon_game_state.dart';

/// BLoC for Game #4: Hot Air Balloon (Single-Player Arcade Survival).
/// - Standard Free Play earns coins via floating bubbles + distance flown.
/// - Optional Double Coin (2x) Stake Mode starts faster and accelerates steeper;
///   surviving past the Admin-configured target unlocks staked multiplier + bubble coins!
/// - Speed jumps sharply after Admin-configured `speedBoostAfterSeconds` (default 40s).
class BalloonGameBloc extends Bloc<BalloonGameEvent, BalloonGameState> {
  static const String _gameId = 'game_balloon_sky';

  final BucketGameRepository repository;

  BalloonGameBloc({required this.repository}) : super(const BalloonGameState()) {
    on<InitBalloonGameEvent>(_onInit);
    on<SyncBalloonUserBalanceEvent>(_onSyncBalance);
    on<SelectBalloonPlayModeEvent>(_onSelectPlayMode);
    on<StepBalloonStakeCoinEvent>(_onStepStakeCoin);
    on<SetBalloonPresetStakeEvent>(_onSetPresetStake);
    on<UpdateBalloonCustomStakeTextEvent>(_onUpdateCustomStakeText);
    on<StartBalloonRunEvent>(_onStartRun);
    on<TogglePauseBalloonRunEvent>(_onTogglePause);
    on<FinishBalloonRunEvent>(_onFinishRun);
    on<FetchBalloonRewardedAdsEvent>(_onFetchRewardedAds);
    on<ClaimBalloonAdRewardEvent>(_onClaimAdReward);
    on<FetchBalloonGamesControlEvent>(_onFetchGamesControl);
  }

  /// Continuous progressive speed curve:
  /// - Standard Free Play: steady up to `boostAfterSeconds` (1.0x -> 2.3x), then jumps fast.
  /// - Double Stake (2x) Mode: noticeably speedier right from launch and ramps steeper.
  static double calculateSpeedMultiplier({
    required double elapsedSeconds,
    required bool isDoubleStake,
    required bool slowPowerUpActive,
    int boostAfterSeconds = 40,
  }) {
    final boostThreshold = max(10.0, boostAfterSeconds.toDouble());
    final midThreshold = boostThreshold * 0.5;

    double baseSpeed;
    if (isDoubleStake) {
      if (elapsedSeconds <= midThreshold) {
        baseSpeed = 1.35 + (elapsedSeconds / midThreshold) * 0.80;
      } else if (elapsedSeconds <= boostThreshold) {
        baseSpeed = 2.15 + ((elapsedSeconds - midThreshold) / (boostThreshold - midThreshold)) * 1.15;
      } else {
        baseSpeed = min(7.8, 4.60 + (elapsedSeconds - boostThreshold) * 0.16);
      }
    } else {
      if (elapsedSeconds <= midThreshold) {
        baseSpeed = 1.00 + (elapsedSeconds / midThreshold) * 0.55;
      } else if (elapsedSeconds <= boostThreshold) {
        baseSpeed = 1.55 + ((elapsedSeconds - midThreshold) / (boostThreshold - midThreshold)) * 0.75;
      } else {
        baseSpeed = min(6.8, 3.50 + (elapsedSeconds - boostThreshold) * 0.14);
      }
    }

    return slowPowerUpActive ? max(0.85, baseSpeed * 0.62) : baseSpeed;
  }

  void _onInit(InitBalloonGameEvent event, Emitter<BalloonGameState> emit) {
    emit(state.copyWith(
      syncedUserCoinBalance: event.initialUserCoinBalance,
      phase: BalloonGamePhase.ready,
    ));
    add(const FetchBalloonGamesControlEvent());
  }

  void _onSyncBalance(
    SyncBalloonUserBalanceEvent event,
    Emitter<BalloonGameState> emit,
  ) {
    emit(state.copyWith(syncedUserCoinBalance: event.newBalance));
  }

  void _onSelectPlayMode(
    SelectBalloonPlayModeEvent event,
    Emitter<BalloonGameState> emit,
  ) {
    if (state.phase == BalloonGamePhase.playing ||
        state.phase == BalloonGamePhase.paused) {
      return;
    }
    emit(state.copyWith(
      playMode: event.mode,
      phase: BalloonGamePhase.ready,
      clearLastRunSummary: true,
    ));
  }

  void _onStepStakeCoin(
    StepBalloonStakeCoinEvent event,
    Emitter<BalloonGameState> emit,
  ) {
    int current = state.stakeInputAmount;
    final int step = current >= 10000
        ? 1000
        : current >= 1000
            ? 500
            : 50;

    if (event.isIncrement) {
      current += step;
    } else {
      current = max(10, current - step);
    }
    emit(state.copyWith(stakeInputAmount: current));
  }

  void _onSetPresetStake(
    SetBalloonPresetStakeEvent event,
    Emitter<BalloonGameState> emit,
  ) {
    emit(state.copyWith(stakeInputAmount: event.amount));
  }

  void _onUpdateCustomStakeText(
    UpdateBalloonCustomStakeTextEvent event,
    Emitter<BalloonGameState> emit,
  ) {
    final parsed = int.tryParse(event.rawText.trim());
    if (parsed != null && parsed >= 0) {
      emit(state.copyWith(stakeInputAmount: parsed));
    } else if (event.rawText.trim().isEmpty) {
      emit(state.copyWith(stakeInputAmount: 0));
    }
  }

  Future<void> _onStartRun(
    StartBalloonRunEvent event,
    Emitter<BalloonGameState> emit,
  ) async {
    final latestConfig = await repository.fetchGamesControlConfig();
    if (isClosed) return;

    if (!latestConfig.isGamePlayable(_gameId)) {
      emit(state.copyWith(
        gamesConfig: latestConfig,
        uiFeedbackMessage: '⛔ This game is temporarily paused by Admin.',
        uiFeedbackNeedsAdRefill: false,
        uiFeedbackTick: state.uiFeedbackTick + 1,
      ));
      return;
    }

    int runStake = 0;

    final uid = AuthSessionManager.currentUserId;
    final isGuest = uid == null || uid.isEmpty;
    final currentBalance = isGuest
        ? state.guestFallbackBalance
        : state.syncedUserCoinBalance;

    double nextSynced = state.syncedUserCoinBalance;
    double nextGuest = state.guestFallbackBalance;
    int nextSyncTick = state.profileBalanceSyncTick;

    final minBet = latestConfig.minBetFor(_gameId);
    final maxBet = latestConfig.maxBetFor(_gameId);
    if (state.stakeInputAmount <= 0 ||
        state.stakeInputAmount < minBet ||
        state.stakeInputAmount > maxBet) {
      emit(state.copyWith(
        gamesConfig: latestConfig,
        uiFeedbackMessage:
            'Please invest between $minBet and $maxBet coins to fly.',
        uiFeedbackNeedsAdRefill: false,
        uiFeedbackTick: state.uiFeedbackTick + 1,
      ));
      return;
    }

    if (currentBalance <= 0 || currentBalance < state.stakeInputAmount) {
      emit(state.copyWith(
        gamesConfig: latestConfig,
        uiFeedbackMessage:
            'Need more coins! Watch a quick video ad to get free coins.',
        uiFeedbackNeedsAdRefill: true,
        uiFeedbackTick: state.uiFeedbackTick + 1,
      ));
      add(const FetchBalloonRewardedAdsEvent(openDialogAfterFetch: true));
      return;
    }

    runStake = state.stakeInputAmount;
    final deducted = currentBalance - runStake;
    if (isGuest) {
      nextGuest = deducted;
    } else {
      nextSynced = deducted;
      nextSyncTick++;
    }

    emit(state.copyWith(
      gamesConfig: latestConfig,
      phase: BalloonGamePhase.playing,
      activeRunStake: runStake,
      runSeedTick: state.runSeedTick + 1,
      clearLastRunSummary: true,
      syncedUserCoinBalance: nextSynced,
      guestFallbackBalance: nextGuest,
      profileBalanceSyncTick: nextSyncTick,
    ));

    if (runStake > 0 && !isGuest) {
      await repository.updateUserCoinBalance(
        userId: uid,
        newBalance: nextSynced,
      );
    }
  }

  void _onTogglePause(
    TogglePauseBalloonRunEvent event,
    Emitter<BalloonGameState> emit,
  ) {
    if (state.phase == BalloonGamePhase.playing) {
      emit(state.copyWith(phase: BalloonGamePhase.paused));
    } else if (state.phase == BalloonGamePhase.paused) {
      emit(state.copyWith(phase: BalloonGamePhase.playing));
    }
  }

  Future<void> _onFinishRun(
    FinishBalloonRunEvent event,
    Emitter<BalloonGameState> emit,
  ) async {
    if (state.phase != BalloonGamePhase.playing &&
        state.phase != BalloonGamePhase.paused) {
      return;
    }

    final int stake = state.activeRunStake;
    final int target = state.targetScore;
    final bool wonDouble = stake > 0 &&
        (event.doubleTargetCleared || event.score >= target);

    // Survival coin bonus & stake payout controlled by Admin Games Control
    final int distanceBonusCoins =
        (event.survivedSeconds ~/ 4) * state.distanceBonusPer4s;
    final double stakeMult = state.doubleStakeMultiplier;
    final String stakeMultLabel = GamesControlConfig.formatMultiplier(stakeMult);
    final int doublePayout = wonDouble ? (stake * stakeMult).round() : 0;
    final int totalEarned =
        event.bubbleCoinsEarned + distanceBonusCoins + doublePayout;

    final uid = AuthSessionManager.currentUserId;
    final isGuest = uid == null || uid.isEmpty;

    double nextSynced = state.syncedUserCoinBalance;
    double nextGuest = state.guestFallbackBalance;
    int nextSyncTick = state.profileBalanceSyncTick;

    if (totalEarned > 0) {
      if (isGuest) {
        nextGuest += totalEarned;
      } else {
        nextSynced += totalEarned;
        nextSyncTick++;
      }
    }

    final summary = BalloonRunSummary(
      score: event.score,
      targetScore: target,
      earnedCoins: totalEarned,
      stakedCoins: stake,
      doubleWon: wonDouble,
      survivedSeconds: event.survivedSeconds,
    );

    final int nextBest = max(state.bestScore, event.score);
    final double finalBalance = isGuest ? nextGuest : nextSynced;

    String? toast;
    if (wonDouble) {
      toast =
          '🎉 TARGET REACHED ($target pts)! Won $stakeMultLabel (+$totalEarned Coins)!';
    } else if (stake > 0 && !wonDouble) {
      toast = totalEarned > 0
          ? '💥 Crashed before reaching $target pts! Earned +$totalEarned balloon coins.'
          : '💥 Crashed! Reach $target pts next run to win $stakeMultLabel!';
    } else if (totalEarned > 0) {
      toast = '🎈 Nice flight! Earned +$totalEarned Coins!';
    }

    emit(state.copyWith(
      phase: BalloonGamePhase.gameOver,
      activeRunStake: 0,
      bestScore: nextBest,
      lastRunSummary: summary,
      syncedUserCoinBalance: nextSynced,
      guestFallbackBalance: nextGuest,
      profileBalanceSyncTick: nextSyncTick,
      uiFeedbackMessage: toast,
      uiFeedbackNeedsAdRefill: stake > 0 && !wonDouble,
      uiFeedbackTick: toast != null ? state.uiFeedbackTick + 1 : state.uiFeedbackTick,
    ));

    if (totalEarned > 0 && !isGuest) {
      await repository.updateUserCoinBalance(
        userId: uid,
        newBalance: nextSynced,
      );
      await repository.recordGameWinTransaction(
        userId: uid,
        title: wonDouble
            ? 'Balloon Sky 2x Win (Score ${event.score})'
            : 'Balloon Sky Flight Reward (Score ${event.score})',
        winCoins: totalEarned,
        gateway: wonDouble ? 'Balloon Sky (2x Stake)' : 'Balloon Sky (Free Earn)',
      );
    }

    if (stake > 0 && !wonDouble && finalBalance < 10) {
      add(const FetchBalloonRewardedAdsEvent(openDialogAfterFetch: true));
    }
  }

  Future<void> _onFetchRewardedAds(
    FetchBalloonRewardedAdsEvent event,
    Emitter<BalloonGameState> emit,
  ) async {
    emit(state.copyWith(isLoadingAds: true));
    final config = await repository.fetchActiveRewardedAds();
    emit(state.copyWith(
      rewardedAdsConfig: config,
      isLoadingAds: false,
      openWatchAdModalTick: event.openDialogAfterFetch
          ? state.openWatchAdModalTick + 1
          : state.openWatchAdModalTick,
    ));
  }

  Future<void> _onClaimAdReward(
    ClaimBalloonAdRewardEvent event,
    Emitter<BalloonGameState> emit,
  ) async {
    final uid = AuthSessionManager.currentUserId;
    final isGuest = uid == null || uid.isEmpty;

    final currentBalance = isGuest
        ? state.guestFallbackBalance
        : state.syncedUserCoinBalance;
    final updatedBalance = currentBalance + event.ad.rewardCoins;

    emit(state.copyWith(
      syncedUserCoinBalance:
          isGuest ? state.syncedUserCoinBalance : updatedBalance,
      guestFallbackBalance: isGuest ? updatedBalance : state.guestFallbackBalance,
      profileBalanceSyncTick:
          isGuest ? state.profileBalanceSyncTick : state.profileBalanceSyncTick + 1,
      uiFeedbackMessage:
          '🎉 Earned +${event.ad.rewardCoins} Coins from ${event.ad.network}!',
      uiFeedbackNeedsAdRefill: false,
      uiFeedbackTick: state.uiFeedbackTick + 1,
    ));

    if (!isGuest) {
      await repository.updateUserCoinBalance(
        userId: uid,
        newBalance: updatedBalance,
      );
      await repository.recordAdRewardTransaction(
        userId: uid,
        ad: event.ad,
      );
    }
  }

  Future<void> _onFetchGamesControl(
    FetchBalloonGamesControlEvent event,
    Emitter<BalloonGameState> emit,
  ) async {
    final config = await repository.fetchGamesControlConfig();
    if (!isClosed) {
      emit(state.copyWith(gamesConfig: config));
    }
  }
}
