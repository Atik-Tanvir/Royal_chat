import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../domain/entities/bucket_game_item.dart';
import '../../domain/entities/games_control_config.dart';
import '../../domain/repositories/bucket_game_repository.dart';
import 'bucket_game_event.dart';
import 'bucket_game_state.dart';

class BucketGameBloc extends Bloc<BucketGameEvent, BucketGameState> {
  static const String _gameId = 'game_bucket_8';
  static const int _revealSeconds = 4;

  int get _bettingSeconds =>
      state.gamesConfig.roundSecondsFor(_gameId, fallback: 35);
  int get _lockWindowSeconds => max(
        0,
        _bettingSeconds -
            state.gamesConfig.betLockSecondsFor(_gameId, fallback: 30),
      );
  int get _cycleSeconds => _bettingSeconds + _revealSeconds;

  final BucketGameRepository repository;
  final Random _random = Random();

  Timer? _tickTimer;
  Timer? _soloRevealTimer;
  int? _lastProcessedGroupRound;
  int _tickCounter = 0;

  BucketGameBloc({required this.repository}) : super(const BucketGameState()) {
    on<InitBucketGameEvent>(_onInit);
    on<SyncUserCoinBalanceEvent>(_onSyncUserCoinBalance);
    on<SwitchBucketGameModeEvent>(_onSwitchMode);
    on<ChangeGroupRoomEvent>(_onChangeGroupRoom);
    on<TickBucketTimerEvent>(_onTickTimer);
    on<FinishSoloRevealEvent>(_onFinishSoloReveal);
    on<PlaceBucketBetEvent>(_onPlaceBet);
    on<StepBetCoinEvent>(_onStepBetCoin);
    on<SetPresetBetCoinEvent>(_onSetPresetBetCoin);
    on<UpdateCustomBetCoinTextEvent>(_onUpdateCustomBetCoinText);
    on<RemoteGroupBetReceivedEvent>(_onRemoteGroupBetReceived);
    on<FetchRewardedAdsEvent>(_onFetchRewardedAds);
    on<ClaimAdRewardEvent>(_onClaimAdReward);
    on<FetchBucketGamesControlEvent>(_onFetchGamesControl);
  }

  @override
  Future<void> close() async {
    _tickTimer?.cancel();
    _soloRevealTimer?.cancel();
    await repository.unsubscribeGroupRoom();
    return super.close();
  }

  void _onInit(InitBucketGameEvent event, Emitter<BucketGameState> emit) {
    final isGroup = event.partyRoomId != null;
    final roomId = event.partyRoomId ?? 'royal_group_1';
    final roomName = event.partyRoomName ?? 'Royal Group #1';

    final initialHistory = [
      kBucketGameItems[5], // Crown
      kBucketGameItems[4], // Diamond
      kBucketGameItems[0], // Bucket
      kBucketGameItems[6], // Gift
      kBucketGameItems[2], // Flower
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
    add(const FetchRewardedAdsEvent(openDialogAfterFetch: false));
    add(const FetchBucketGamesControlEvent());
  }

  void _onSyncUserCoinBalance(
    SyncUserCoinBalanceEvent event,
    Emitter<BucketGameState> emit,
  ) {
    emit(state.copyWith(syncedUserCoinBalance: event.coinBalance));
  }

  Future<void> _onSwitchMode(
    SwitchBucketGameModeEvent event,
    Emitter<BucketGameState> emit,
  ) async {
    if (state.isGroupMode == event.isGroupMode) return;

    _tickTimer?.cancel();
    _soloRevealTimer?.cancel();
    await repository.unsubscribeGroupRoom();
    _lastProcessedGroupRound = null;

    emit(state.copyWith(
      isGroupMode: event.isGroupMode,
      userBets: const {},
      groupBetsByItem: const {},
      recentGroupActivity: const [],
      clearRevealedItem: true,
      clearRoundResultBanner: true,
      isRevealing: false,
      clearGroupWinners: true,
      totalPoolCount: event.isGroupMode ? 148500 : 131251,
      timeLeft: _bettingSeconds,
    ));

    if (event.isGroupMode) {
      _subscribeRoom(state.groupRoomId);
      _emitSyncedGroupClock(emit, allowSettlement: false);
    }

    _startPeriodicTick();
  }

  Future<void> _onChangeGroupRoom(
    ChangeGroupRoomEvent event,
    Emitter<BucketGameState> emit,
  ) async {
    await repository.unsubscribeGroupRoom();
    _lastProcessedGroupRound = null;

    emit(state.copyWith(
      groupRoomId: event.roomId,
      groupRoomName: event.roomName,
      userBets: const {},
      groupBetsByItem: const {},
      recentGroupActivity: const [],
      clearRevealedItem: true,
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
      channelName: 'game:bucket8:$roomId',
      onRemoteBetReceived: (record, round) {
        if (!isClosed) {
          add(RemoteGroupBetReceivedEvent(bet: record, round: round));
        }
      },
    );
  }

  void _startPeriodicTick() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed) {
        add(const TickBucketTimerEvent());
      }
    });
  }

  Future<void> _onTickTimer(
    TickBucketTimerEvent event,
    Emitter<BucketGameState> emit,
  ) async {
    _tickCounter++;
    if (_tickCounter % 8 == 0) {
      add(const FetchBucketGamesControlEvent());
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
        final winItem = kBucketGameItems[_random.nextInt(kBucketGameItems.length)];
        emit(state.copyWith(
          timeLeft: 0,
          isRevealing: true,
          totalPoolCount: nextPool,
        ));
        await _settleRound(emit, winItem);

        _soloRevealTimer?.cancel();
        _soloRevealTimer = Timer(const Duration(seconds: _revealSeconds), () {
          if (!isClosed) {
            add(const FinishSoloRevealEvent());
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
    FinishSoloRevealEvent event,
    Emitter<BucketGameState> emit,
  ) {
    if (state.isGroupMode) return;
    emit(state.copyWith(
      roundNumber: state.roundNumber + 1,
      timeLeft: _bettingSeconds,
      isRevealing: false,
      clearRevealedItem: true,
      clearRoundResultBanner: true,
      didWinLastRound: false,
      userBets: const {},
      totalPoolCount: 128000 + _random.nextInt(15000),
    ));
  }

  Future<void> _emitSyncedGroupClock(
    Emitter<BucketGameState> emit, {
    required bool allowSettlement,
  }) async {
    final epochSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final currentRound = epochSeconds ~/ _cycleSeconds;
    final cyclePos = epochSeconds % _cycleSeconds;

    if (currentRound != state.roundNumber) {
      emit(state.copyWith(
        roundNumber: currentRound,
        userBets: const {},
        groupBetsByItem: const {},
        recentGroupActivity: const [],
        clearRevealedItem: true,
        clearRoundResultBanner: true,
        didWinLastRound: false,
        isRevealing: false,
        clearGroupWinners: true,
        totalPoolCount: 142000 + (currentRound % 9) * 3400,
      ));
    }

    if (cyclePos < _bettingSeconds) {
      final remaining = _bettingSeconds - cyclePos;
      var updatedGroupBets = Map<String, int>.from(state.groupBetsByItem);
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
        clearRevealedItem: true,
        clearRoundResultBanner: true,
        groupBetsByItem: updatedGroupBets,
        recentGroupActivity: updatedActivity,
        totalPoolCount: updatedPool,
      ));
    } else {
      final winItem = _deterministicGroupWinner(currentRound, state.groupRoomId);
      emit(state.copyWith(
        timeLeft: 0,
        isRevealing: true,
        revealedItem: winItem,
      ));

      if (allowSettlement && _lastProcessedGroupRound != currentRound) {
        _lastProcessedGroupRound = currentRound;
        await _settleRound(emit, winItem);
      }
    }
  }

  BucketGameItem _deterministicGroupWinner(int round, String roomId) {
    int hash = round * 31;
    for (int i = 0; i < roomId.length; i++) {
      hash = (hash * 37 + roomId.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return kBucketGameItems[Random(hash).nextInt(kBucketGameItems.length)];
  }

  GroupBetRecord _generateSimulatedGroupBet() {
    const names = ['Tania', 'Prince', 'Zoya', 'Rafi', 'Nadia', 'Siam'];
    final name = names[_random.nextInt(names.length)];
    final item = kBucketGameItems[_random.nextInt(kBucketGameItems.length)];
    const amounts = [100, 200, 500, 1000];
    final amt = amounts[_random.nextInt(amounts.length)];

    return GroupBetRecord(
      userId: 'group_$name',
      userName: name,
      itemId: item.id,
      amount: amt,
      isSelf: false,
    );
  }

  Future<void> _settleRound(
    Emitter<BucketGameState> emit,
    BucketGameItem winItem,
  ) async {
    final myBetOnWinner = state.userBets[winItem.id] ?? 0;
    final totalMyBet = state.userBets.values.fold(0, (a, b) => a + b);
    final mult = state.gamesConfig.multiplierFor(_gameId, winItem.id, fallback: 2.0);
    final multLabel = GamesControlConfig.formatMultiplier(mult);

    final winCoins = (myBetOnWinner * mult).round();
    final wonRound = winCoins > 0;

    String? groupWinnerMsg;
    if (state.isGroupMode) {
      final groupWinners = state.recentGroupActivity
          .where((b) => b.itemId == winItem.id)
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

    final updatedHistory = [winItem, ...state.winnerHistory];
    if (updatedHistory.length > 10) {
      updatedHistory.removeRange(10, updatedHistory.length);
    }

    String resultText;
    if (wonRound) {
      resultText =
          '🎉 Winner: ${winItem.icon} ${winItem.nameEn}! +$winCoins Coins ($multLabel)';
    } else if (totalMyBet > 0) {
      resultText = 'Winner: ${winItem.icon} ${winItem.nameEn} • -$totalMyBet Coins';
    } else {
      resultText = 'Winner: ${winItem.icon} ${winItem.nameEn}';
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
      revealedItem: winItem,
      roundResultBanner: resultText,
      didWinLastRound: wonRound,
      lastGroupWinnersSummary: groupWinnerMsg,
      winnerHistory: updatedHistory,
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
        title: 'Bucket Spin Win (${winItem.icon} ${winItem.nameEn} $multLabel)',
        winCoins: winCoins,
        gateway: state.isGroupMode ? 'Bucket Spin (Group)' : 'Bucket Spin (Solo)',
      );
    }

    // If user lost all coins (balance < 10), auto-trigger Watch Ad prompt
    if (!wonRound && totalMyBet > 0 && currentFinalBalance < 10) {
      add(const FetchRewardedAdsEvent(openDialogAfterFetch: true));
    }
  }

  Future<void> _onPlaceBet(
    PlaceBucketBetEvent event,
    Emitter<BucketGameState> emit,
  ) async {
    if (!state.gamesConfig.isGamePlayable(_gameId)) {
      emit(state.copyWith(
        uiFeedbackMessage: '⛔ This game is temporarily paused by Admin.',
        uiFeedbackNeedsAdRefill: false,
        uiFeedbackTick: state.uiFeedbackTick + 1,
      ));
      return;
    }

    if (state.timeLeft <= _lockWindowSeconds || state.isRevealing) {
      emit(state.copyWith(
        uiFeedbackMessage: 'Round closing! Please wait for the next round.',
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
      add(const FetchRewardedAdsEvent(openDialogAfterFetch: true));
      return;
    }

    final myName = AuthSessionManager.currentUserName ?? 'You';
    final updatedUserBets = Map<String, int>.from(state.userBets);
    updatedUserBets[event.item.id] =
        (updatedUserBets[event.item.id] ?? 0) + betAmount;

    final updatedGroupBets = Map<String, int>.from(state.groupBetsByItem);
    var updatedActivity = List<GroupBetRecord>.from(state.recentGroupActivity);

    final betRecord = GroupBetRecord(
      userId: isGuest ? 'local_guest' : uid,
      userName: myName,
      itemId: event.item.id,
      amount: betAmount,
      isSelf: true,
    );

    if (state.isGroupMode) {
      updatedGroupBets[event.item.id] =
          (updatedGroupBets[event.item.id] ?? 0) + betAmount;
      updatedActivity.insert(0, betRecord);
      if (updatedActivity.length > 6) {
        updatedActivity = updatedActivity.sublist(0, 6);
      }
    }

    final newBalance = availableBalance - betAmount;

    emit(state.copyWith(
      userBets: updatedUserBets,
      groupBetsByItem: updatedGroupBets,
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
        channelName: 'game:bucket8:${state.groupRoomId}',
        bet: betRecord,
        round: state.roundNumber,
      );
    }
  }

  void _onStepBetCoin(
    StepBetCoinEvent event,
    Emitter<BucketGameState> emit,
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

  void _onSetPresetBetCoin(
    SetPresetBetCoinEvent event,
    Emitter<BucketGameState> emit,
  ) {
    emit(state.copyWith(betInputAmount: event.amount));
  }

  void _onUpdateCustomBetCoinText(
    UpdateCustomBetCoinTextEvent event,
    Emitter<BucketGameState> emit,
  ) {
    final parsed = int.tryParse(event.rawText.trim());
    if (parsed != null && parsed >= 0) {
      emit(state.copyWith(betInputAmount: parsed));
    } else if (event.rawText.trim().isEmpty) {
      emit(state.copyWith(betInputAmount: 0));
    }
  }

  void _onRemoteGroupBetReceived(
    RemoteGroupBetReceivedEvent event,
    Emitter<BucketGameState> emit,
  ) {
    if (!state.isGroupMode || event.round != state.roundNumber) return;

    final updatedGroupBets = Map<String, int>.from(state.groupBetsByItem);
    updatedGroupBets[event.bet.itemId] =
        (updatedGroupBets[event.bet.itemId] ?? 0) + event.bet.amount;

    var updatedActivity = List<GroupBetRecord>.from(state.recentGroupActivity);
    updatedActivity.insert(0, event.bet);
    if (updatedActivity.length > 8) {
      updatedActivity = updatedActivity.sublist(0, 8);
    }

    emit(state.copyWith(
      groupBetsByItem: updatedGroupBets,
      recentGroupActivity: updatedActivity,
      totalPoolCount: state.totalPoolCount + event.bet.amount,
    ));
  }

  Future<void> _onFetchRewardedAds(
    FetchRewardedAdsEvent event,
    Emitter<BucketGameState> emit,
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
    ClaimAdRewardEvent event,
    Emitter<BucketGameState> emit,
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
    FetchBucketGamesControlEvent event,
    Emitter<BucketGameState> emit,
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
