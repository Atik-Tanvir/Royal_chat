import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../domain/entities/bucket_game_item.dart';
import '../../domain/entities/games_control_config.dart';
import '../../domain/entities/seven_up_game_entity.dart';
import '../../domain/repositories/bucket_game_repository.dart';
import 'seven_up_event.dart';
import 'seven_up_state.dart';

class SevenUpBloc extends Bloc<SevenUpEvent, SevenUpState> {
  static const String _gameId = 'game_7up_7down';
  static const int _revealSeconds = 3;

  int get _roundSeconds => state.configuredRoundSeconds;
  int get _cycleSeconds => _roundSeconds + _revealSeconds;

  final BucketGameRepository repository;
  final Random _random = Random();

  Timer? _tickTimer;
  Timer? _soloRevealTimer;
  int? _lastProcessedGroupRound;
  int _tickCounter = 0;

  SevenUpBloc({required this.repository}) : super(const SevenUpState()) {
    on<InitSevenUpEvent>(_onInit);
    on<SyncSevenUpUserBalanceEvent>(_onSyncUserBalance);
    on<SwitchSevenUpModeEvent>(_onSwitchMode);
    on<ChangeSevenUpGroupRoomEvent>(_onChangeGroupRoom);
    on<TickSevenUpTimerEvent>(_onTickTimer);
    on<FinishSevenUpSoloRevealEvent>(_onFinishSoloReveal);
    on<PlaceSevenUpBetEvent>(_onPlaceBet);
    on<StepSevenUpBetCoinEvent>(_onStepBetCoin);
    on<SetSevenUpPresetCoinEvent>(_onSetPresetCoin);
    on<UpdateSevenUpCustomCoinTextEvent>(_onUpdateCustomCoinText);
    on<RemoteSevenUpBetReceivedEvent>(_onRemoteGroupBetReceived);
    on<FetchSevenUpRewardedAdsEvent>(_onFetchRewardedAds);
    on<ClaimSevenUpAdRewardEvent>(_onClaimAdReward);
    on<FetchSevenUpGamesControlEvent>(_onFetchGamesControl);
  }

  @override
  Future<void> close() async {
    _tickTimer?.cancel();
    _soloRevealTimer?.cancel();
    await repository.unsubscribeGroupRoom();
    return super.close();
  }

  /// Progressive acceleration curve scaled cleanly inside an 18-second round:
  /// - 0..7s: Steady opening pace (1.0x -> 1.8x)
  /// - 8..11s: Noticeable speed ramp-up (2.3x -> 3.8x)
  /// - 12..14s: High-speed push before betting closes (5.2x -> 8.0x)
  /// - 15..18s: Ultra-fast turbo climax with BET LOCKED (10.0x -> 14.0x)
  static double calculateSpeedForElapsed(int elapsed) {
    if (elapsed <= 7) {
      return 1.0 + (elapsed / 7.0) * 0.8;
    } else if (elapsed <= 11) {
      return 1.8 + ((elapsed - 7) / 4.0) * 2.0;
    } else if (elapsed <= 14) {
      return 5.2 + ((elapsed - 11) / 3.0) * 2.8;
    } else {
      return 10.0 + ((elapsed - 14) / 4.0) * 4.0;
    }
  }

  void _onInit(InitSevenUpEvent event, Emitter<SevenUpState> emit) {
    final isGroup = event.partyRoomId != null;
    final roomId = event.partyRoomId ?? 'royal_group_1';
    final roomName = event.partyRoomName ?? 'Royal Group #1';

    // Seed authentic 2-dice history matching video stats bar
    const initialHistory = [
      DiceRollOutcome(die1: 3, die2: 3), // 6 (2~6)
      DiceRollOutcome(die1: 2, die2: 2), // 4 (2~6)
      DiceRollOutcome(die1: 3, die2: 3), // 6 (2~6)
      DiceRollOutcome(die1: 3, die2: 4), // 7 (7)
      DiceRollOutcome(die1: 5, die2: 4), // 9 (8~12)
      DiceRollOutcome(die1: 4, die2: 1), // 5 (2~6)
      DiceRollOutcome(die1: 5, die2: 3), // 8 (8~12)
      DiceRollOutcome(die1: 3, die2: 4), // 7 (7)
      DiceRollOutcome(die1: 6, die2: 4), // 10 (8~12)
      DiceRollOutcome(die1: 2, die2: 3), // 5 (2~6)
    ];

    emit(state.copyWith(
      isGroupMode: isGroup,
      isPartyLockedRoom: event.partyRoomId != null,
      groupRoomId: roomId,
      groupRoomName: roomName,
      syncedUserCoinBalance: event.initialUserCoinBalance,
      rollHistory: initialHistory,
      elapsedSeconds: 0,
      speedMultiplier: 1.0,
      clearRoundResultBanner: true,
    ));

    if (isGroup) {
      _subscribeRoom(roomId);
      _emitSyncedGroupClock(emit, allowSettlement: false);
    }

    _startPeriodicTick();
    add(const FetchSevenUpRewardedAdsEvent(openDialogAfterFetch: false));
    add(const FetchSevenUpGamesControlEvent());
  }

  void _onSyncUserBalance(
    SyncSevenUpUserBalanceEvent event,
    Emitter<SevenUpState> emit,
  ) {
    emit(state.copyWith(syncedUserCoinBalance: event.coinBalance));
  }

  Future<void> _onSwitchMode(
    SwitchSevenUpModeEvent event,
    Emitter<SevenUpState> emit,
  ) async {
    if (state.isGroupMode == event.isGroupMode) return;

    _tickTimer?.cancel();
    _soloRevealTimer?.cancel();
    await repository.unsubscribeGroupRoom();
    _lastProcessedGroupRound = null;

    emit(state.copyWith(
      isGroupMode: event.isGroupMode,
      userBets: const {},
      groupBetsByZone: const {},
      recentGroupActivity: const [],
      clearRevealedOutcome: true,
      clearRoundResultBanner: true,
      isRevealing: false,
      clearGroupWinners: true,
      totalPoolCount: event.isGroupMode ? 156400 : 131251,
      elapsedSeconds: 0,
      speedMultiplier: 1.0,
    ));

    if (event.isGroupMode) {
      _subscribeRoom(state.groupRoomId);
      _emitSyncedGroupClock(emit, allowSettlement: false);
    }

    _startPeriodicTick();
  }

  Future<void> _onChangeGroupRoom(
    ChangeSevenUpGroupRoomEvent event,
    Emitter<SevenUpState> emit,
  ) async {
    await repository.unsubscribeGroupRoom();
    _lastProcessedGroupRound = null;

    emit(state.copyWith(
      groupRoomId: event.roomId,
      groupRoomName: event.roomName,
      userBets: const {},
      groupBetsByZone: const {},
      recentGroupActivity: const [],
      clearRevealedOutcome: true,
      clearRoundResultBanner: true,
      clearGroupWinners: true,
    ));

    _subscribeRoom(event.roomId);
    if (state.isGroupMode) {
      _emitSyncedGroupClock(emit, allowSettlement: false);
    }
  }

  void _subscribeRoom(String roomId) {
    repository.subscribeToGroupRoom(
      channelName: 'game:7up7down:$roomId',
      onRemoteBetReceived: (record, round) {
        if (!isClosed) {
          add(RemoteSevenUpBetReceivedEvent(bet: record, round: round));
        }
      },
    );
  }

  void _startPeriodicTick() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed) {
        add(const TickSevenUpTimerEvent());
      }
    });
  }

  Future<void> _onTickTimer(
    TickSevenUpTimerEvent event,
    Emitter<SevenUpState> emit,
  ) async {
    _tickCounter++;
    if (_tickCounter % 8 == 0) {
      add(const FetchSevenUpGamesControlEvent());
    }

    if (state.isGroupMode) {
      await _emitSyncedGroupClock(emit, allowSettlement: true);
    } else {
      if (state.isRevealing) return;
      final nextElapsed = state.elapsedSeconds + 1;
      int nextPool = state.totalPoolCount;

      if (nextElapsed < state.configuredBetLockSeconds && nextElapsed % 2 == 0) {
        nextPool += _random.nextInt(900) + 250;
      }

      if (nextElapsed >= _roundSeconds) {
        final outcome = DiceRollOutcome(
          die1: _random.nextInt(6) + 1,
          die2: _random.nextInt(6) + 1,
        );
        emit(state.copyWith(
          elapsedSeconds: _roundSeconds,
          speedMultiplier: calculateSpeedForElapsed(_roundSeconds),
          isRevealing: true,
          totalPoolCount: nextPool,
        ));
        await _settleRound(emit, outcome);

        _soloRevealTimer?.cancel();
        _soloRevealTimer = Timer(const Duration(seconds: _revealSeconds), () {
          if (!isClosed) {
            add(const FinishSevenUpSoloRevealEvent());
          }
        });
      } else {
        emit(state.copyWith(
          elapsedSeconds: nextElapsed,
          speedMultiplier: calculateSpeedForElapsed(nextElapsed),
          totalPoolCount: nextPool,
        ));
      }
    }
  }

  void _onFinishSoloReveal(
    FinishSevenUpSoloRevealEvent event,
    Emitter<SevenUpState> emit,
  ) {
    if (state.isGroupMode) return;
    emit(state.copyWith(
      roundNumber: state.roundNumber + 1,
      elapsedSeconds: 0,
      speedMultiplier: 1.0,
      isRevealing: false,
      clearRevealedOutcome: true,
      clearRoundResultBanner: true,
      didWinLastRound: false,
      userBets: const {},
      totalPoolCount: 128000 + _random.nextInt(15000),
    ));
  }

  Future<void> _emitSyncedGroupClock(
    Emitter<SevenUpState> emit, {
    required bool allowSettlement,
  }) async {
    final epochSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final currentRound = epochSeconds ~/ _cycleSeconds;
    final cyclePos = epochSeconds % _cycleSeconds;

    if (currentRound != state.roundNumber) {
      emit(state.copyWith(
        roundNumber: currentRound,
        userBets: const {},
        groupBetsByZone: const {},
        recentGroupActivity: const [],
        clearRevealedOutcome: true,
        clearRoundResultBanner: true,
        didWinLastRound: false,
        isRevealing: false,
        clearGroupWinners: true,
        totalPoolCount: 145000 + (currentRound % 9) * 3200,
      ));
    }

    if (cyclePos < _roundSeconds) {
      final elapsed = cyclePos;
      var updatedGroupBets = Map<String, int>.from(state.groupBetsByZone);
      var updatedActivity = List<GroupBetRecord>.from(state.recentGroupActivity);
      var updatedPool = state.totalPoolCount;

      if (elapsed < state.configuredBetLockSeconds &&
          elapsed % 2 == 0 &&
          state.groupRoomId.startsWith('royal_group')) {
        final simulated = _generateSimulatedGroupBet();
        updatedGroupBets[simulated.itemId] =
            (updatedGroupBets[simulated.itemId] ?? 0) + simulated.amount;
        updatedPool += simulated.amount;
        updatedActivity.insert(0, simulated);
        if (updatedActivity.length > 6) {
          updatedActivity = updatedActivity.sublist(0, 6);
        }
      }

      emit(state.copyWith(
        elapsedSeconds: elapsed,
        speedMultiplier: calculateSpeedForElapsed(elapsed),
        isRevealing: false,
        clearRevealedOutcome: true,
        clearRoundResultBanner: true,
        groupBetsByZone: updatedGroupBets,
        recentGroupActivity: updatedActivity,
        totalPoolCount: updatedPool,
      ));
    } else {
      final outcome = _deterministicGroupOutcome(currentRound, state.groupRoomId);
      emit(state.copyWith(
        elapsedSeconds: _roundSeconds,
        speedMultiplier: calculateSpeedForElapsed(_roundSeconds),
        isRevealing: true,
        revealedOutcome: outcome,
      ));

      if (allowSettlement && _lastProcessedGroupRound != currentRound) {
        _lastProcessedGroupRound = currentRound;
        await _settleRound(emit, outcome);
      }
    }
  }

  DiceRollOutcome _deterministicGroupOutcome(int round, String roomId) {
    int hash = round * 43;
    for (int i = 0; i < roomId.length; i++) {
      hash = (hash * 47 + roomId.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    final rng = Random(hash);
    return DiceRollOutcome(
      die1: rng.nextInt(6) + 1,
      die2: rng.nextInt(6) + 1,
    );
  }

  GroupBetRecord _generateSimulatedGroupBet() {
    const names = ['Tania', 'Prince', 'Zoya', 'Rafi', 'Nadia', 'Siam'];
    final name = names[_random.nextInt(names.length)];
    final zone = kSevenUpZones[_random.nextInt(kSevenUpZones.length)];
    const amounts = [100, 200, 500, 1000];
    final amt = amounts[_random.nextInt(amounts.length)];

    return GroupBetRecord(
      userId: 'group_$name',
      userName: name,
      itemId: zone.id,
      amount: amt,
      isSelf: false,
    );
  }

  Future<void> _settleRound(
    Emitter<SevenUpState> emit,
    DiceRollOutcome outcome,
  ) async {
    final winZone = outcome.winningZone;
    final myBetOnWinner = state.userBets[winZone.id] ?? 0;
    final totalMyBet = state.userBets.values.fold(0, (a, b) => a + b);
    final mult = state.gamesConfig.multiplierFor(
      _gameId,
      winZone.id,
      fallback: winZone.multiplier,
    );
    final multLabel = GamesControlConfig.formatMultiplier(mult);

    final winCoins = (myBetOnWinner * mult).round();
    final wonRound = winCoins > 0;

    String? groupWinnerMsg;
    if (state.isGroupMode) {
      final groupWinners = state.recentGroupActivity
          .where((b) => b.itemId == winZone.id)
          .map((b) => b.userName)
          .toSet()
          .toList();
      if (wonRound) {
        final myName = AuthSessionManager.currentUserName ?? 'You';
        if (!groupWinners.contains(myName)) groupWinners.insert(0, myName);
      }
      if (groupWinners.isNotEmpty) {
        groupWinnerMsg = '🏆 Group Winners: ${groupWinners.take(3).join(', ')}';
      }
    }

    final updatedHistory = [outcome, ...state.rollHistory];
    if (updatedHistory.length > 20) {
      updatedHistory.removeRange(20, updatedHistory.length);
    }

    String resultText;
    if (wonRound) {
      resultText =
          '🎲 ${outcome.die1} + ${outcome.die2} = ${outcome.sum} (${winZone.title}) • Won +$winCoins Coins ($multLabel)!';
    } else if (totalMyBet > 0) {
      resultText =
          '🎲 ${outcome.die1} + ${outcome.die2} = ${outcome.sum} (${winZone.title}) • -$totalMyBet Coins';
    } else {
      resultText =
          '🎲 ${outcome.die1} + ${outcome.die2} = ${outcome.sum} (${winZone.title})';
    }

    final uid = AuthSessionManager.currentUserId;
    final isGuest = uid == null || uid.isEmpty;

    double nextSyncedBalance = state.syncedUserCoinBalance;
    double nextGuestBalance = state.guestFallbackBalance;
    int nextSyncTick = state.profileBalanceSyncTick;

    if (winCoins > 0) {
      if (isGuest) {
        nextGuestBalance += winCoins;
      } else {
        nextSyncedBalance += winCoins;
        nextSyncTick++;
      }
    }

    final currentFinalBalance = isGuest ? nextGuestBalance : nextSyncedBalance;

    emit(state.copyWith(
      revealedOutcome: outcome,
      roundResultBanner: resultText,
      didWinLastRound: wonRound,
      lastGroupWinnersSummary: groupWinnerMsg,
      rollHistory: updatedHistory,
      syncedUserCoinBalance: nextSyncedBalance,
      guestFallbackBalance: nextGuestBalance,
      profileBalanceSyncTick: nextSyncTick,
    ));

    if (winCoins > 0 && !isGuest) {
      await repository.updateUserCoinBalance(
        userId: uid,
        newBalance: nextSyncedBalance,
      );
      await repository.recordGameWinTransaction(
        userId: uid,
        title: '7 Up 7 Down Win (${outcome.sum} · ${winZone.title})',
        winCoins: winCoins,
        gateway: state.isGroupMode ? '7 Up 7 Down (Group)' : '7 Up 7 Down (Solo)',
      );
    }

    if (!wonRound && totalMyBet > 0 && currentFinalBalance < 10) {
      add(const FetchSevenUpRewardedAdsEvent(openDialogAfterFetch: true));
    }
  }

  Future<void> _onPlaceBet(
    PlaceSevenUpBetEvent event,
    Emitter<SevenUpState> emit,
  ) async {
    if (!state.gamesConfig.isGamePlayable(_gameId)) {
      emit(state.copyWith(
        uiFeedbackMessage: '⛔ This game is temporarily paused by Admin.',
        uiFeedbackNeedsAdRefill: false,
        uiFeedbackTick: state.uiFeedbackTick + 1,
      ));
      return;
    }

    if (state.isBettingLocked) {
      emit(state.copyWith(
        uiFeedbackMessage: 'Bet locked! Please wait for dice reveal.',
        uiFeedbackNeedsAdRefill: false,
        uiFeedbackTick: state.uiFeedbackTick + 1,
      ));
      return;
    }

    final betAmount = state.betInputAmount;
    final minBet = state.gamesConfig.minBetFor(_gameId);
    final maxBet = state.gamesConfig.maxBetFor(_gameId);
    if (betAmount <= 0 || betAmount < minBet || betAmount > maxBet) {
      emit(state.copyWith(
        uiFeedbackMessage:
            'Stake must be between $minBet and $maxBet coins (Admin limit).',
        uiFeedbackNeedsAdRefill: false,
        uiFeedbackTick: state.uiFeedbackTick + 1,
      ));
      return;
    }

    final uid = AuthSessionManager.currentUserId;
    final isGuest = uid == null || uid.isEmpty;
    final availableBalance = isGuest
        ? state.guestFallbackBalance
        : state.syncedUserCoinBalance;

    if (availableBalance <= 0 || availableBalance < betAmount) {
      add(const FetchSevenUpRewardedAdsEvent(openDialogAfterFetch: true));
      return;
    }

    final myName = AuthSessionManager.currentUserName ?? 'You';
    final updatedUserBets = Map<String, int>.from(state.userBets);
    updatedUserBets[event.zone.id] =
        (updatedUserBets[event.zone.id] ?? 0) + betAmount;

    final updatedGroupBets = Map<String, int>.from(state.groupBetsByZone);
    var updatedActivity = List<GroupBetRecord>.from(state.recentGroupActivity);

    final betRecord = GroupBetRecord(
      userId: isGuest ? 'local_guest' : uid,
      userName: myName,
      itemId: event.zone.id,
      amount: betAmount,
      isSelf: true,
    );

    if (state.isGroupMode) {
      updatedGroupBets[event.zone.id] =
          (updatedGroupBets[event.zone.id] ?? 0) + betAmount;
      updatedActivity.insert(0, betRecord);
      if (updatedActivity.length > 6) {
        updatedActivity = updatedActivity.sublist(0, 6);
      }
    }

    final newBalance = availableBalance - betAmount;

    emit(state.copyWith(
      userBets: updatedUserBets,
      groupBetsByZone: updatedGroupBets,
      recentGroupActivity: updatedActivity,
      totalPoolCount: state.totalPoolCount + betAmount,
      syncedUserCoinBalance: isGuest ? state.syncedUserCoinBalance : newBalance,
      guestFallbackBalance: isGuest ? newBalance : state.guestFallbackBalance,
      profileBalanceSyncTick:
          isGuest ? state.profileBalanceSyncTick : state.profileBalanceSyncTick + 1,
    ));

    if (!isGuest) {
      await repository.updateUserCoinBalance(
        userId: uid,
        newBalance: newBalance,
      );
    }

    if (state.isGroupMode) {
      await repository.broadcastGroupBet(
        channelName: 'game:7up7down:${state.groupRoomId}',
        bet: betRecord,
        round: state.roundNumber,
      );
    }
  }

  void _onStepBetCoin(
    StepSevenUpBetCoinEvent event,
    Emitter<SevenUpState> emit,
  ) {
    int current = state.betInputAmount;
    int step;
    if (current >= 10000) {
      step = 1000;
    } else if (current >= 1000) {
      step = 500;
    } else {
      step = 50;
    }

    if (event.isIncrement) {
      current += step;
    } else {
      current = max(10, current - step);
    }

    emit(state.copyWith(betInputAmount: current));
  }

  void _onSetPresetCoin(
    SetSevenUpPresetCoinEvent event,
    Emitter<SevenUpState> emit,
  ) {
    emit(state.copyWith(betInputAmount: event.amount));
  }

  void _onUpdateCustomCoinText(
    UpdateSevenUpCustomCoinTextEvent event,
    Emitter<SevenUpState> emit,
  ) {
    final parsed = int.tryParse(event.rawText.trim());
    if (parsed != null && parsed >= 0) {
      emit(state.copyWith(betInputAmount: parsed));
    } else if (event.rawText.trim().isEmpty) {
      emit(state.copyWith(betInputAmount: 0));
    }
  }

  void _onRemoteGroupBetReceived(
    RemoteSevenUpBetReceivedEvent event,
    Emitter<SevenUpState> emit,
  ) {
    if (!state.isGroupMode || event.round != state.roundNumber) return;

    final updatedGroupBets = Map<String, int>.from(state.groupBetsByZone);
    updatedGroupBets[event.bet.itemId] =
        (updatedGroupBets[event.bet.itemId] ?? 0) + event.bet.amount;

    var updatedActivity = List<GroupBetRecord>.from(state.recentGroupActivity);
    updatedActivity.insert(0, event.bet);
    if (updatedActivity.length > 8) {
      updatedActivity = updatedActivity.sublist(0, 8);
    }

    emit(state.copyWith(
      groupBetsByZone: updatedGroupBets,
      recentGroupActivity: updatedActivity,
      totalPoolCount: state.totalPoolCount + event.bet.amount,
    ));
  }

  Future<void> _onFetchRewardedAds(
    FetchSevenUpRewardedAdsEvent event,
    Emitter<SevenUpState> emit,
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
    ClaimSevenUpAdRewardEvent event,
    Emitter<SevenUpState> emit,
  ) async {
    final uid = AuthSessionManager.currentUserId;
    final isGuest = uid == null || uid.isEmpty;

    final currentBalance = isGuest
        ? state.guestFallbackBalance
        : state.syncedUserCoinBalance;
    final updatedBalance = currentBalance + event.ad.rewardCoins;

    emit(state.copyWith(
      syncedUserCoinBalance: isGuest ? state.syncedUserCoinBalance : updatedBalance,
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
    FetchSevenUpGamesControlEvent event,
    Emitter<SevenUpState> emit,
  ) async {
    final config = await repository.fetchGamesControlConfig();
    if (!isClosed) {
      emit(state.copyWith(gamesConfig: config));
    }
  }
}
