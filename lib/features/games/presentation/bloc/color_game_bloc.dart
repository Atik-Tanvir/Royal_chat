import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../domain/entities/bucket_game_item.dart';
import '../../domain/entities/color_game_option.dart';
import '../../domain/entities/games_control_config.dart';
import '../../domain/repositories/bucket_game_repository.dart';
import 'color_game_event.dart';
import 'color_game_state.dart';

class ColorGameBloc extends Bloc<ColorGameEvent, ColorGameState> {
  static const String _gameId = 'game_color_3';
  static const int _revealSeconds = 4;

  int get _bettingSeconds =>
      state.gamesConfig.roundSecondsFor(_gameId, fallback: 20);
  int get _lockWindowSeconds => max(
        0,
        _bettingSeconds -
            state.gamesConfig.betLockSecondsFor(_gameId, fallback: 15),
      );
  int get _cycleSeconds => _bettingSeconds + _revealSeconds;

  final BucketGameRepository repository;
  final Random _random = Random();

  Timer? _tickTimer;
  Timer? _soloRevealTimer;
  int? _lastProcessedGroupRound;
  int _tickCounter = 0;

  ColorGameBloc({required this.repository}) : super(const ColorGameState()) {
    on<InitColorGameEvent>(_onInit);
    on<SyncColorUserBalanceEvent>(_onSyncUserBalance);
    on<SwitchColorGameModeEvent>(_onSwitchMode);
    on<ChangeColorGroupRoomEvent>(_onChangeGroupRoom);
    on<TickColorTimerEvent>(_onTickTimer);
    on<FinishColorSoloRevealEvent>(_onFinishSoloReveal);
    on<PlaceColorBetEvent>(_onPlaceBet);
    on<StepColorBetCoinEvent>(_onStepBetCoin);
    on<SetColorPresetCoinEvent>(_onSetPresetCoin);
    on<UpdateColorCustomCoinTextEvent>(_onUpdateCustomCoinText);
    on<RemoteColorGroupBetReceivedEvent>(_onRemoteGroupBetReceived);
    on<FetchColorRewardedAdsEvent>(_onFetchRewardedAds);
    on<ClaimColorAdRewardEvent>(_onClaimAdReward);
    on<FetchColorGamesControlEvent>(_onFetchGamesControl);
  }

  @override
  Future<void> close() async {
    _tickTimer?.cancel();
    _soloRevealTimer?.cancel();
    await repository.unsubscribeGroupRoom();
    return super.close();
  }

  void _onInit(InitColorGameEvent event, Emitter<ColorGameState> emit) {
    final isGroup = event.partyRoomId != null;
    final roomId = event.partyRoomId ?? 'royal_group_1';
    final roomName = event.partyRoomName ?? 'Royal Group #1';

    final initialHistory = [
      kColorGameOptions[0], // RED
      kColorGameOptions[2], // GREEN
      kColorGameOptions[1], // VIOLET
      kColorGameOptions[2], // GREEN
      kColorGameOptions[0], // RED
    ];

    emit(state.copyWith(
      isGroupMode: isGroup,
      isPartyLockedRoom: event.partyRoomId != null,
      groupRoomId: roomId,
      groupRoomName: roomName,
      syncedUserCoinBalance: event.initialUserCoinBalance,
      winnerHistory: initialHistory,
      clearRoundResultBanner: true,
    ));

    if (isGroup) {
      _subscribeRoom(roomId);
      _emitSyncedGroupClock(emit, allowSettlement: false);
    }

    _startPeriodicTick();
    add(const FetchColorRewardedAdsEvent(openDialogAfterFetch: false));
    add(const FetchColorGamesControlEvent());
  }

  void _onSyncUserBalance(
    SyncColorUserBalanceEvent event,
    Emitter<ColorGameState> emit,
  ) {
    emit(state.copyWith(syncedUserCoinBalance: event.coinBalance));
  }

  Future<void> _onSwitchMode(
    SwitchColorGameModeEvent event,
    Emitter<ColorGameState> emit,
  ) async {
    if (state.isGroupMode == event.isGroupMode) return;

    _tickTimer?.cancel();
    _soloRevealTimer?.cancel();
    await repository.unsubscribeGroupRoom();
    _lastProcessedGroupRound = null;

    emit(state.copyWith(
      isGroupMode: event.isGroupMode,
      userBets: const {},
      groupBetsByColor: const {},
      recentGroupActivity: const [],
      clearRevealedColor: true,
      clearRoundResultBanner: true,
      isRevealing: false,
      clearGroupWinners: true,
      totalPoolCount: event.isGroupMode ? 152400 : 131251,
      timeLeft: _bettingSeconds,
    ));

    if (event.isGroupMode) {
      _subscribeRoom(state.groupRoomId);
      _emitSyncedGroupClock(emit, allowSettlement: false);
    }

    _startPeriodicTick();
  }

  Future<void> _onChangeGroupRoom(
    ChangeColorGroupRoomEvent event,
    Emitter<ColorGameState> emit,
  ) async {
    await repository.unsubscribeGroupRoom();
    _lastProcessedGroupRound = null;

    emit(state.copyWith(
      groupRoomId: event.roomId,
      groupRoomName: event.roomName,
      userBets: const {},
      groupBetsByColor: const {},
      recentGroupActivity: const [],
      clearRevealedColor: true,
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
      channelName: 'game:color3:$roomId',
      onRemoteBetReceived: (record, round) {
        if (!isClosed) {
          add(RemoteColorGroupBetReceivedEvent(bet: record, round: round));
        }
      },
    );
  }

  void _startPeriodicTick() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed) {
        add(const TickColorTimerEvent());
      }
    });
  }

  Future<void> _onTickTimer(
    TickColorTimerEvent event,
    Emitter<ColorGameState> emit,
  ) async {
    _tickCounter++;
    if (_tickCounter % 8 == 0) {
      add(const FetchColorGamesControlEvent());
    }

    if (state.isGroupMode) {
      await _emitSyncedGroupClock(emit, allowSettlement: true);
    } else {
      if (state.isRevealing) return;
      final nextTime = state.timeLeft - 1;
      int nextPool = state.totalPoolCount;

      if (nextTime > 5 && nextTime % 3 == 0) {
        nextPool += _random.nextInt(800) + 200;
      }

      if (nextTime <= 0) {
        final winColor =
            kColorOutcomePool[_random.nextInt(kColorOutcomePool.length)];
        emit(state.copyWith(
          timeLeft: 0,
          isRevealing: true,
          totalPoolCount: nextPool,
        ));
        await _settleRound(emit, winColor);

        _soloRevealTimer?.cancel();
        _soloRevealTimer = Timer(const Duration(seconds: _revealSeconds), () {
          if (!isClosed) {
            add(const FinishColorSoloRevealEvent());
          }
        });
      } else {
        emit(state.copyWith(
          timeLeft: nextTime,
          totalPoolCount: nextPool,
        ));
      }
    }
  }

  void _onFinishSoloReveal(
    FinishColorSoloRevealEvent event,
    Emitter<ColorGameState> emit,
  ) {
    if (state.isGroupMode) return;
    emit(state.copyWith(
      roundNumber: state.roundNumber + 1,
      timeLeft: _bettingSeconds,
      isRevealing: false,
      clearRevealedColor: true,
      clearRoundResultBanner: true,
      didWinLastRound: false,
      userBets: const {},
      totalPoolCount: 128000 + _random.nextInt(15000),
    ));
  }

  Future<void> _emitSyncedGroupClock(
    Emitter<ColorGameState> emit, {
    required bool allowSettlement,
  }) async {
    final epochSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final currentRound = epochSeconds ~/ _cycleSeconds;
    final cyclePos = epochSeconds % _cycleSeconds;

    if (currentRound != state.roundNumber) {
      emit(state.copyWith(
        roundNumber: currentRound,
        userBets: const {},
        groupBetsByColor: const {},
        recentGroupActivity: const [],
        clearRevealedColor: true,
        clearRoundResultBanner: true,
        didWinLastRound: false,
        isRevealing: false,
        clearGroupWinners: true,
        totalPoolCount: 145000 + (currentRound % 9) * 3200,
      ));
    }

    if (cyclePos < _bettingSeconds) {
      final remaining = _bettingSeconds - cyclePos;
      var updatedGroupBets = Map<String, int>.from(state.groupBetsByColor);
      var updatedActivity = List<GroupBetRecord>.from(state.recentGroupActivity);
      var updatedPool = state.totalPoolCount;

      if (remaining > 5 &&
          remaining % 4 == 0 &&
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
        timeLeft: remaining,
        isRevealing: false,
        clearRevealedColor: true,
        clearRoundResultBanner: true,
        groupBetsByColor: updatedGroupBets,
        recentGroupActivity: updatedActivity,
        totalPoolCount: updatedPool,
      ));
    } else {
      final winColor = _deterministicGroupWinner(currentRound, state.groupRoomId);
      emit(state.copyWith(
        timeLeft: 0,
        isRevealing: true,
        revealedColor: winColor,
      ));

      if (allowSettlement && _lastProcessedGroupRound != currentRound) {
        _lastProcessedGroupRound = currentRound;
        await _settleRound(emit, winColor);
      }
    }
  }

  ColorGameOption _deterministicGroupWinner(int round, String roomId) {
    int hash = round * 37;
    for (int i = 0; i < roomId.length; i++) {
      hash = (hash * 41 + roomId.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return kColorOutcomePool[Random(hash).nextInt(kColorOutcomePool.length)];
  }

  GroupBetRecord _generateSimulatedGroupBet() {
    const names = ['Tania', 'Prince', 'Zoya', 'Rafi', 'Nadia', 'Siam'];
    final name = names[_random.nextInt(names.length)];
    final colorOption =
        kColorGameOptions[_random.nextInt(kColorGameOptions.length)];
    const amounts = [100, 200, 500, 1000];
    final amt = amounts[_random.nextInt(amounts.length)];

    return GroupBetRecord(
      userId: 'group_$name',
      userName: name,
      itemId: colorOption.id,
      amount: amt,
      isSelf: false,
    );
  }

  Future<void> _settleRound(
    Emitter<ColorGameState> emit,
    ColorGameOption winColor,
  ) async {
    final myBetOnWinner = state.userBets[winColor.id] ?? 0;
    final totalMyBet = state.userBets.values.fold(0, (a, b) => a + b);
    final mult = state.gamesConfig.multiplierFor(
      _gameId,
      winColor.id,
      fallback: winColor.multiplier,
    );
    final multLabel = GamesControlConfig.formatMultiplier(mult);

    final grossWinCoins = (myBetOnWinner * mult).round();
    final wonRound = grossWinCoins > 0;

    int adminCutCoins = 0;
    int netWinCoins = grossWinCoins;
    final adminCommissionPercent = state.gamesConfig.adminCommissionPercentFor(
      _gameId,
      fallback: 5.0,
    );

    if (wonRound && adminCommissionPercent > 0) {
      adminCutCoins = (grossWinCoins * (adminCommissionPercent / 100.0)).round();
      netWinCoins = max(0, grossWinCoins - adminCutCoins);
    }

    String? groupWinnerMsg;
    if (state.isGroupMode) {
      final groupWinners = state.recentGroupActivity
          .where((b) => b.itemId == winColor.id)
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

    final updatedHistory = [winColor, ...state.winnerHistory];
    if (updatedHistory.length > 10) {
      updatedHistory.removeRange(10, updatedHistory.length);
    }

    final adminPctText = adminCommissionPercent % 1 == 0
        ? adminCommissionPercent.toInt().toString()
        : adminCommissionPercent.toStringAsFixed(1);

    String resultText;
    if (wonRound) {
      if (adminCutCoins > 0) {
        resultText =
            '🎉 Winner: ${winColor.emoji} ${winColor.name}! +$netWinCoins Coins ($multLabel • Admin fee: -$adminCutCoins [$adminPctText%])';
      } else {
        resultText =
            '🎉 Winner: ${winColor.emoji} ${winColor.name}! +$netWinCoins Coins ($multLabel)';
      }
    } else if (totalMyBet > 0) {
      resultText =
          'Winner: ${winColor.emoji} ${winColor.name} • -$totalMyBet Coins';
    } else {
      resultText = 'Winner: ${winColor.emoji} ${winColor.name}';
    }

    final uid = AuthSessionManager.currentUserId;
    final isGuest = uid == null || uid.isEmpty;

    double nextSyncedBalance = state.syncedUserCoinBalance;
    double nextGuestBalance = state.guestFallbackBalance;
    int nextSyncTick = state.profileBalanceSyncTick;

    if (netWinCoins > 0) {
      if (isGuest) {
        nextGuestBalance += netWinCoins;
      } else {
        nextSyncedBalance += netWinCoins;
        nextSyncTick++;
      }
    }

    final currentFinalBalance = isGuest ? nextGuestBalance : nextSyncedBalance;

    emit(state.copyWith(
      revealedColor: winColor,
      roundResultBanner: resultText,
      didWinLastRound: wonRound,
      lastGroupWinnersSummary: groupWinnerMsg,
      winnerHistory: updatedHistory,
      syncedUserCoinBalance: nextSyncedBalance,
      guestFallbackBalance: nextGuestBalance,
      profileBalanceSyncTick: nextSyncTick,
    ));

    if (netWinCoins > 0 && !isGuest) {
      await repository.updateUserCoinBalance(
        userId: uid,
        newBalance: nextSyncedBalance,
      );
      final txTitle = adminCutCoins > 0
          ? 'Color Spin Win (${winColor.emoji} ${winColor.name} $multLabel • Net +$netWinCoins, Admin Cut -$adminCutCoins [$adminPctText%])'
          : 'Color Spin Win (${winColor.emoji} ${winColor.name} $multLabel)';
      await repository.recordGameWinTransaction(
        userId: uid,
        title: txTitle,
        winCoins: netWinCoins,
        gateway: state.isGroupMode ? 'Color Spin (Group)' : 'Color Spin (Solo)',
      );
    }

    if (!wonRound && totalMyBet > 0 && currentFinalBalance < 10) {
      add(const FetchColorRewardedAdsEvent(openDialogAfterFetch: true));
    }
  }

  Future<void> _onPlaceBet(
    PlaceColorBetEvent event,
    Emitter<ColorGameState> emit,
  ) async {
    if (!state.gamesConfig.isGamePlayable(_gameId)) {
      emit(state.copyWith(
        uiFeedbackMessage: '⛔ This game is temporarily paused by Admin.',
        uiFeedbackNeedsAdRefill: false,
        uiFeedbackTick: state.uiFeedbackTick + 1,
      ));
      return;
    }

    if (state.timeLeft <= 5 || state.timeLeft <= _lockWindowSeconds || state.isRevealing) {
      emit(state.copyWith(
        uiFeedbackMessage: '🔒 Betting is closed! Final draw in progress...',
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
      add(const FetchColorRewardedAdsEvent(openDialogAfterFetch: true));
      return;
    }

    final myName = AuthSessionManager.currentUserName ?? 'You';
    final updatedUserBets = Map<String, int>.from(state.userBets);
    updatedUserBets[event.option.id] =
        (updatedUserBets[event.option.id] ?? 0) + betAmount;

    final updatedGroupBets = Map<String, int>.from(state.groupBetsByColor);
    var updatedActivity = List<GroupBetRecord>.from(state.recentGroupActivity);

    final betRecord = GroupBetRecord(
      userId: isGuest ? 'local_guest' : uid,
      userName: myName,
      itemId: event.option.id,
      amount: betAmount,
      isSelf: true,
    );

    if (state.isGroupMode) {
      updatedGroupBets[event.option.id] =
          (updatedGroupBets[event.option.id] ?? 0) + betAmount;
      updatedActivity.insert(0, betRecord);
      if (updatedActivity.length > 6) {
        updatedActivity = updatedActivity.sublist(0, 6);
      }
    }

    final newBalance = availableBalance - betAmount;

    emit(state.copyWith(
      userBets: updatedUserBets,
      groupBetsByColor: updatedGroupBets,
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
        channelName: 'game:color3:${state.groupRoomId}',
        bet: betRecord,
        round: state.roundNumber,
      );
    }
  }

  void _onStepBetCoin(
    StepColorBetCoinEvent event,
    Emitter<ColorGameState> emit,
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
    SetColorPresetCoinEvent event,
    Emitter<ColorGameState> emit,
  ) {
    emit(state.copyWith(betInputAmount: event.amount));
  }

  void _onUpdateCustomCoinText(
    UpdateColorCustomCoinTextEvent event,
    Emitter<ColorGameState> emit,
  ) {
    final parsed = int.tryParse(event.rawText.trim());
    if (parsed != null && parsed >= 0) {
      emit(state.copyWith(betInputAmount: parsed));
    } else if (event.rawText.trim().isEmpty) {
      emit(state.copyWith(betInputAmount: 0));
    }
  }

  void _onRemoteGroupBetReceived(
    RemoteColorGroupBetReceivedEvent event,
    Emitter<ColorGameState> emit,
  ) {
    if (!state.isGroupMode || event.round != state.roundNumber) return;

    final updatedGroupBets = Map<String, int>.from(state.groupBetsByColor);
    updatedGroupBets[event.bet.itemId] =
        (updatedGroupBets[event.bet.itemId] ?? 0) + event.bet.amount;

    var updatedActivity = List<GroupBetRecord>.from(state.recentGroupActivity);
    updatedActivity.insert(0, event.bet);
    if (updatedActivity.length > 8) {
      updatedActivity = updatedActivity.sublist(0, 8);
    }

    emit(state.copyWith(
      groupBetsByColor: updatedGroupBets,
      recentGroupActivity: updatedActivity,
      totalPoolCount: state.totalPoolCount + event.bet.amount,
    ));
  }

  Future<void> _onFetchRewardedAds(
    FetchColorRewardedAdsEvent event,
    Emitter<ColorGameState> emit,
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
    ClaimColorAdRewardEvent event,
    Emitter<ColorGameState> emit,
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
    FetchColorGamesControlEvent event,
    Emitter<ColorGameState> emit,
  ) async {
    final config = await repository.fetchGamesControlConfig();
    if (isClosed) return;
    final configuredRoundSec = config.roundSecondsFor(_gameId, fallback: 35);
    final nextTimeLeft = (!state.isGroupMode && state.timeLeft > configuredRoundSec)
        ? configuredRoundSec
        : state.timeLeft;
    emit(state.copyWith(
      gamesConfig: config,
      timeLeft: nextTimeLeft,
    ));
  }
}
