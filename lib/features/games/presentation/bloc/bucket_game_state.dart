import 'package:equatable/equatable.dart';
import '../../domain/entities/bucket_game_item.dart';
import '../../domain/entities/games_control_config.dart';
import '../../domain/entities/rewarded_ad_item.dart';

class BucketGameState extends Equatable {
  final bool isGroupMode;
  final bool isPartyLockedRoom;
  final String groupRoomId;
  final String groupRoomName;
  final int timeLeft;
  final int roundNumber;
  final bool isRevealing;
  final BucketGameItem? revealedItem;
  final String? roundResultBanner;
  final bool didWinLastRound;
  final Map<String, int> userBets;
  final Map<String, int> groupBetsByItem;
  final List<GroupBetRecord> recentGroupActivity;
  final List<BucketGameItem> winnerHistory;
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

  const BucketGameState({
    this.isGroupMode = false,
    this.isPartyLockedRoom = false,
    this.groupRoomId = 'royal_group_1',
    this.groupRoomName = 'Royal Group #1',
    this.timeLeft = 35,
    this.roundNumber = 1,
    this.isRevealing = false,
    this.revealedItem,
    this.roundResultBanner,
    this.didWinLastRound = false,
    this.userBets = const {},
    this.groupBetsByItem = const {},
    this.recentGroupActivity = const [],
    this.winnerHistory = const [],
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

  BucketGameState copyWith({
    bool? isGroupMode,
    bool? isPartyLockedRoom,
    String? groupRoomId,
    String? groupRoomName,
    int? timeLeft,
    int? roundNumber,
    bool? isRevealing,
    BucketGameItem? revealedItem,
    bool clearRevealedItem = false,
    String? roundResultBanner,
    bool clearRoundResultBanner = false,
    bool? didWinLastRound,
    Map<String, int>? userBets,
    Map<String, int>? groupBetsByItem,
    List<GroupBetRecord>? recentGroupActivity,
    List<BucketGameItem>? winnerHistory,
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
    return BucketGameState(
      isGroupMode: isGroupMode ?? this.isGroupMode,
      isPartyLockedRoom: isPartyLockedRoom ?? this.isPartyLockedRoom,
      groupRoomId: groupRoomId ?? this.groupRoomId,
      groupRoomName: groupRoomName ?? this.groupRoomName,
      timeLeft: timeLeft ?? this.timeLeft,
      roundNumber: roundNumber ?? this.roundNumber,
      isRevealing: isRevealing ?? this.isRevealing,
      revealedItem: clearRevealedItem ? null : (revealedItem ?? this.revealedItem),
      roundResultBanner: clearRoundResultBanner
          ? null
          : (roundResultBanner ?? this.roundResultBanner),
      didWinLastRound: didWinLastRound ?? this.didWinLastRound,
      userBets: userBets ?? this.userBets,
      groupBetsByItem: groupBetsByItem ?? this.groupBetsByItem,
      recentGroupActivity: recentGroupActivity ?? this.recentGroupActivity,
      winnerHistory: winnerHistory ?? this.winnerHistory,
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
        timeLeft,
        roundNumber,
        isRevealing,
        revealedItem,
        roundResultBanner,
        didWinLastRound,
        userBets,
        groupBetsByItem,
        recentGroupActivity,
        winnerHistory,
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
