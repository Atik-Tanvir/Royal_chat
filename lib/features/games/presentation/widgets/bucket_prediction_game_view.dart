import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../data/repositories/bucket_game_repository_impl.dart';
import '../../domain/entities/bucket_game_item.dart';
import '../../domain/entities/games_control_config.dart';
import '../bloc/bucket_game_bloc.dart';
import '../bloc/bucket_game_event.dart';
import '../bloc/bucket_game_state.dart';
import 'game_board_chrome.dart';
import 'game_coin_controls_bar.dart';
import 'game_group_picker_sheet.dart';
import 'rewarded_ad_player_dialog.dart';
import 'swirling_bucket_widget.dart';

/// Pure BLoC-driven Presentation Widget for Game #1: 8-Item Bucket Spin.
/// - 100% English UI
/// - Double Coin (2x) Payout on Win / Auto Account Deduction on Loss
/// - Admin-Controlled Rewarded Ads when coins run out
class BucketPredictionGameView extends StatelessWidget {
  final String? partyRoomId;
  final String? partyRoomName;
  final bool isDrawerMode;

  const BucketPredictionGameView({
    super.key,
    this.partyRoomId,
    this.partyRoomName,
    this.isDrawerMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final initialCoinBalance = context.read<ProfileBloc>().state.profile.coinBalance;

    return BlocProvider<BucketGameBloc>(
      create: (_) => BucketGameBloc(repository: BucketGameRepositoryImpl())
        ..add(InitBucketGameEvent(
          partyRoomId: partyRoomId,
          partyRoomName: partyRoomName,
          initialUserCoinBalance: initialCoinBalance,
        )),
      child: _BucketGameViewContent(isDrawerMode: isDrawerMode),
    );
  }
}

class _BucketGameViewContent extends StatefulWidget {
  final bool isDrawerMode;

  const _BucketGameViewContent({required this.isDrawerMode});

  @override
  State<_BucketGameViewContent> createState() => _BucketGameViewContentState();
}

class _BucketGameViewContentState extends State<_BucketGameViewContent> {
  final TextEditingController _coinInputController =
      TextEditingController(text: '100');

  @override
  void dispose() {
    _coinInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (prev, curr) =>
              prev.profile.coinBalance != curr.profile.coinBalance,
          listener: (context, profileState) {
            final gameState = context.read<BucketGameBloc>().state;
            if (gameState.syncedUserCoinBalance != profileState.profile.coinBalance) {
              context.read<BucketGameBloc>().add(
                    SyncUserCoinBalanceEvent(profileState.profile.coinBalance),
                  );
            }
          },
        ),
        BlocListener<BucketGameBloc, BucketGameState>(
          listenWhen: (prev, curr) =>
              prev.profileBalanceSyncTick != curr.profileBalanceSyncTick,
          listener: (context, state) {
            context.read<ProfileBloc>().add(
                  ProfileBalancesUpdatedFromRealtimeEvent(
                    coinBalance: state.syncedUserCoinBalance,
                  ),
                );
          },
        ),
        BlocListener<BucketGameBloc, BucketGameState>(
          listenWhen: (prev, curr) => prev.betInputAmount != curr.betInputAmount,
          listener: (context, state) {
            final newText = state.betInputAmount.toString();
            if (_coinInputController.text != newText) {
              _coinInputController.text = newText;
              _coinInputController.selection = TextSelection.fromPosition(
                TextPosition(offset: newText.length),
              );
            }
          },
        ),
        BlocListener<BucketGameBloc, BucketGameState>(
          listenWhen: (prev, curr) =>
              prev.openWatchAdModalTick != curr.openWatchAdModalTick,
          listener: (context, state) {
            final gameBloc = context.read<BucketGameBloc>();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => RewardedAdPlayerDialog(
                config: state.rewardedAdsConfig,
                onClaimReward: (ad) => gameBloc.add(ClaimAdRewardEvent(ad)),
              ),
            );
          },
        ),
        BlocListener<BucketGameBloc, BucketGameState>(
          listenWhen: (prev, curr) => prev.uiFeedbackTick != curr.uiFeedbackTick,
          listener: (context, state) {
            final msg = state.uiFeedbackMessage;
            if (msg == null || msg.isEmpty) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: state.uiFeedbackNeedsAdRefill
                    ? Colors.redAccent
                    : const Color(0xFF10B981),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
      child: BlocBuilder<BucketGameBloc, BucketGameState>(
        builder: (context, state) {
          final gameBloc = context.read<BucketGameBloc>();
          final isUrgent = state.timeLeft <= 5 && state.timeLeft > 0;
          final currentUid = AuthSessionManager.currentUserId;
          final balance = (currentUid == null || currentUid.isEmpty)
              ? state.guestFallbackBalance
              : state.syncedUserCoinBalance;

          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF062032), Color(0xFF081426), Color(0xFF040914)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: widget.isDrawerMode
                  ? const BorderRadius.vertical(top: Radius.circular(24))
                  : BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.72),
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                  blurRadius: 18,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: widget.isDrawerMode
                  ? const BorderRadius.vertical(top: Radius.circular(22))
                  : BorderRadius.circular(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Builder(
                    builder: (_) {
                      final bucketCfg = state.gamesConfig.gameFor('game_bucket_8');
                      final mults = kBucketGameItems
                          .map((it) => bucketCfg.multiplierFor(it.id, fallback: 2.0))
                          .toSet()
                          .toList()
                        ..sort();
                      final oddsLabel = mults.length == 1
                          ? 'Win ${GamesControlConfig.formatMultiplier(mults.first)}'
                          : 'Win ${GamesControlConfig.formatMultiplier(mults.first)}-${GamesControlConfig.formatMultiplier(mults.last)}';
                      return GameHeaderBar(
                        title: '🪣 Bucket Spin (8-Item)',
                        subtitle: '$oddsLabel • ${bucketCfg.roundSeconds}s Live Round',
                        isGroupMode: state.isGroupMode,
                        timeLeft: state.timeLeft,
                        accentColor: const Color(0xFF38BDF8),
                        onModeChanged: (toGroup) =>
                            gameBloc.add(SwitchBucketGameModeEvent(toGroup)),
                      );
                    },
                  ),
                  if (!state.gamesConfig.isGamePlayable('game_bucket_8'))
                    const GameFrozenBanner(),
                  GameStatsBar(
                    balance: balance,
                    totalPoolCount: state.totalPoolCount,
                    isLoadingAds: state.isLoadingAds,
                    onWatchAdTap: () => gameBloc.add(
                      const FetchRewardedAdsEvent(openDialogAfterFetch: true),
                    ),
                  ),
                  GameModeAndHistoryStrip(
                    isGroupMode: state.isGroupMode,
                    isPartyLockedRoom: state.isPartyLockedRoom,
                    groupRoomName: state.groupRoomName,
                    roundNumber: state.roundNumber,
                    onGroupTableTap: () => GameGroupPickerSheet.show(
                      context,
                      currentRoomId: state.groupRoomId,
                      onSelectRoom: (id, name) => gameBloc.add(
                        ChangeGroupRoomEvent(roomId: id, roomName: name),
                      ),
                    ),
                    historyBadges: state.winnerHistory.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(item.icon, style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                  ),
                  _buildCenterBucketSection(state, isUrgent),
                  if (state.isGroupMode && state.recentGroupActivity.isNotEmpty)
                    _buildGroupActivityTicker(state),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: _buildEightItemGrid(context, state),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    child: GameCoinControlsBar(
                      controller: _coinInputController,
                      currentAmount: state.betInputAmount,
                      onDecrement: () =>
                          gameBloc.add(const StepBetCoinEvent(isIncrement: false)),
                      onIncrement: () =>
                          gameBloc.add(const StepBetCoinEvent(isIncrement: true)),
                      onTextChanged: (txt) =>
                          gameBloc.add(UpdateCustomBetCoinTextEvent(txt)),
                      onPresetSelected: (val) =>
                          gameBloc.add(SetPresetBetCoinEvent(val)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCenterBucketSection(BucketGameState state, bool isUrgent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 24, 12, 8),
      child: Column(
        children: [
          SwirlingBucketWidget(
            size: widget.isDrawerMode ? 128 : 146,
            theme: BucketVisualTheme.aquaGold,
            isUrgentSpin: isUrgent || state.isRevealing,
            revealedItem: state.revealedItem,
            items: kBucketGameItems,
          ),
          if (state.roundResultBanner != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: state.didWinLastRound
                    ? const Color(0xFF10B981).withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: state.didWinLastRound
                      ? const Color(0xFF34D399)
                      : AppColors.goldCoin.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                state.roundResultBanner!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: state.didWinLastRound
                      ? const Color(0xFF6EE7B7)
                      : AppColors.goldCoin,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          if (state.lastGroupWinnersSummary != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.6),
                ),
              ),
              child: Text(
                state.lastGroupWinnersSummary!,
                style: const TextStyle(
                  color: Color(0xFF6EE7B7),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupActivityTicker(BucketGameState state) {
    final latest = state.recentGroupActivity.first;
    final item = kBucketGameItems.firstWhere(
      (e) => e.id == latest.itemId,
      orElse: () => kBucketGameItems.first,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0369A1).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.campaign_rounded, color: AppColors.goldCoin, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '${latest.userName} bet 🪙 ${latest.amount} on ${item.icon} ${item.nameEn}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEightItemGrid(BuildContext context, BucketGameState state) {
    final topRow = kBucketGameItems.sublist(0, 4);
    final bottomRow = kBucketGameItems.sublist(4, 8);

    return Column(
      children: [
        Row(
          children: topRow
              .map((item) => Expanded(child: _buildItemCard(context, state, item)))
              .toList(),
        ),
        const SizedBox(height: 6),
        Row(
          children: bottomRow
              .map((item) => Expanded(child: _buildItemCard(context, state, item)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    BucketGameState state,
    BucketGameItem item,
  ) {
    final myBet = state.userBets[item.id] ?? 0;
    final groupBet = state.groupBetsByItem[item.id] ?? 0;
    final isSelected = myBet > 0;
    final isWinner = state.revealedItem?.id == item.id;
    final itemMult =
        state.gamesConfig.multiplierFor('game_bucket_8', item.id, fallback: 2.0);
    final multLabel = GamesControlConfig.formatMultiplier(itemMult);

    return GestureDetector(
      onTap: () => context.read<BucketGameBloc>().add(PlaceBucketBetEvent(item)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        height: 80,
        decoration: BoxDecoration(
          color: isWinner
              ? const Color(0xFF10B981).withValues(alpha: 0.32)
              : isSelected
                  ? AppColors.goldCoin.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isWinner
                ? const Color(0xFF34D399)
                : isSelected
                    ? Colors.white
                    : AppColors.goldCoin.withValues(alpha: 0.35),
            width: (isWinner || isSelected) ? 2.0 : 1.2,
          ),
          boxShadow: [
            if (isWinner)
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.55),
                blurRadius: 12,
              )
            else if (isSelected)
              BoxShadow(
                color: AppColors.goldCoin.withValues(alpha: 0.45),
                blurRadius: 8,
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (state.isGroupMode && groupBet > 0)
              Positioned(
                top: 3,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '👥$groupBet',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (isWinner)
              const Positioned(
                top: 2,
                left: 4,
                child: Text('🏆', style: TextStyle(fontSize: 11)),
              )
            else
              Positioned(
                top: 3,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    multLabel,
                    style: const TextStyle(
                      color: Color(0xFF7DD3FC),
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.icon, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 1),
                Text(
                  item.nameEn,
                  style: const TextStyle(
                    color: AppColors.goldCoin,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '🪙 $myBet',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
