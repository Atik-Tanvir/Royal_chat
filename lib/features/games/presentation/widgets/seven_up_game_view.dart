import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../data/repositories/bucket_game_repository_impl.dart';
import '../../domain/entities/games_control_config.dart';
import '../../domain/entities/seven_up_game_entity.dart';
import '../bloc/seven_up_bloc.dart';
import '../bloc/seven_up_event.dart';
import '../bloc/seven_up_state.dart';
import 'game_board_chrome.dart';
import 'game_coin_controls_bar.dart';
import 'game_group_picker_sheet.dart';
import 'rewarded_ad_player_dialog.dart';
import 'seven_up_dealer_stage.dart';

/// Pure BLoC-driven Presentation Widget for Game #3: 7 UP 7 DOWN (`WhatsApp Video`).
/// - Progressive accelerating speed (gradual 0-40s, faster >40s, ultra-fast >50s)
/// - 3 Casino Felt Zones: 8 ~ 12 (1:1 / 2x), 7 (1:4 / 5x), 2 ~ 6 (1:1 / 2x)
/// - Solo & Group Modes + Real Dice Stats & History + Admin-Controlled Rewarded Ads
class SevenUpGameView extends StatelessWidget {
  final String? partyRoomId;
  final String? partyRoomName;
  final bool isDrawerMode;

  const SevenUpGameView({
    super.key,
    this.partyRoomId,
    this.partyRoomName,
    this.isDrawerMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final initialCoinBalance = context.read<ProfileBloc>().state.profile.coinBalance;

    return BlocProvider<SevenUpBloc>(
      create: (_) => SevenUpBloc(repository: BucketGameRepositoryImpl())
        ..add(InitSevenUpEvent(
          partyRoomId: partyRoomId,
          partyRoomName: partyRoomName,
          initialUserCoinBalance: initialCoinBalance,
        )),
      child: _SevenUpViewContent(isDrawerMode: isDrawerMode),
    );
  }
}

class _SevenUpViewContent extends StatefulWidget {
  final bool isDrawerMode;

  const _SevenUpViewContent({required this.isDrawerMode});

  @override
  State<_SevenUpViewContent> createState() => _SevenUpViewContentState();
}

class _SevenUpViewContentState extends State<_SevenUpViewContent> {
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
            final gameState = context.read<SevenUpBloc>().state;
            if (gameState.syncedUserCoinBalance != profileState.profile.coinBalance) {
              context.read<SevenUpBloc>().add(
                    SyncSevenUpUserBalanceEvent(profileState.profile.coinBalance),
                  );
            }
          },
        ),
        BlocListener<SevenUpBloc, SevenUpState>(
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
        BlocListener<SevenUpBloc, SevenUpState>(
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
        BlocListener<SevenUpBloc, SevenUpState>(
          listenWhen: (prev, curr) =>
              prev.openWatchAdModalTick != curr.openWatchAdModalTick,
          listener: (context, state) {
            final gameBloc = context.read<SevenUpBloc>();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => RewardedAdPlayerDialog(
                config: state.rewardedAdsConfig,
                onClaimReward: (ad) => gameBloc.add(ClaimSevenUpAdRewardEvent(ad)),
              ),
            );
          },
        ),
        BlocListener<SevenUpBloc, SevenUpState>(
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
      child: BlocBuilder<SevenUpBloc, SevenUpState>(
        builder: (context, state) {
          final gameBloc = context.read<SevenUpBloc>();
          final currentUid = AuthSessionManager.currentUserId;
          final balance = (currentUid == null || currentUid.isEmpty)
              ? state.guestFallbackBalance
              : state.syncedUserCoinBalance;

          final secPadded = state.elapsedSeconds.toString().padLeft(2, '0');

          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2B060D), Color(0xFF180308), Color(0xFF0B0104)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: widget.isDrawerMode
                  ? const BorderRadius.vertical(top: Radius.circular(24))
                  : BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.goldCoin.withValues(alpha: 0.8),
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldCoin.withValues(alpha: 0.18),
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
                      final roundSec = state.configuredRoundSeconds;
                      final upLabel = GamesControlConfig.formatMultiplier(
                        state.gamesConfig.multiplierFor(
                          'game_7up_7down',
                          'up',
                          fallback: 2.0,
                        ),
                      );
                      final sevenLabel = GamesControlConfig.formatMultiplier(
                        state.gamesConfig.multiplierFor(
                          'game_7up_7down',
                          'seven',
                          fallback: 5.0,
                        ),
                      );
                      return GameHeaderBar(
                        title: '🎲 7 Up 7 Down',
                        subtitle:
                            '${roundSec}s Turbo Round • $upLabel & $sevenLabel Payout',
                        isGroupMode: state.isGroupMode,
                        timeLeft: roundSec - state.elapsedSeconds,
                        customTimerText: '${secPadded}s / ${roundSec}s',
                        isUrgentOverride:
                            state.elapsedSeconds >= (roundSec - 6).clamp(5, roundSec),
                        onModeChanged: (toGroup) =>
                            gameBloc.add(SwitchSevenUpModeEvent(toGroup)),
                      );
                    },
                  ),
                  if (!state.gamesConfig.isGamePlayable('game_7up_7down'))
                    const GameFrozenBanner(),
                  GameStatsBar(
                    balance: balance,
                    totalPoolCount: state.totalPoolCount,
                    isLoadingAds: state.isLoadingAds,
                    onWatchAdTap: () => gameBloc.add(
                      const FetchSevenUpRewardedAdsEvent(openDialogAfterFetch: true),
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
                        ChangeSevenUpGroupRoomEvent(roomId: id, roomName: name),
                      ),
                    ),
                    historyBadges: state.rollHistory.take(8).map((roll) {
                      final isSeven = roll.sum == 7;
                      return Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isSeven
                              ? const Color(0xFF10B981)
                              : Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${roll.sum}',
                          style: TextStyle(
                            color: isSeven ? Colors.black : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Top Casino Dealer + Accelerating Dice Shaker Cup Stage
                  SevenUpDealerStage(
                    elapsedSeconds: state.elapsedSeconds,
                    speedMultiplier: state.speedMultiplier,
                    isBettingLocked: state.isBettingLocked,
                    revealedOutcome: state.revealedOutcome,
                  ),

                  if (state.roundResultBanner != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: state.didWinLastRound
                              ? const Color(0xFF10B981).withValues(alpha: 0.25)
                              : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: state.didWinLastRound
                                ? const Color(0xFF34D399)
                                : AppColors.goldCoin.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          state.roundResultBanner!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: state.didWinLastRound
                                ? const Color(0xFF6EE7B7)
                                : AppColors.goldCoin,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  if (state.lastGroupWinnersSummary != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          state.lastGroupWinnersSummary!,
                          style: const TextStyle(
                            color: Color(0xFF6EE7B7),
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  if (state.isGroupMode && state.recentGroupActivity.isNotEmpty)
                    _buildGroupActivityTicker(state),

                  // Signature Simplified Felt Board (8 ~ 12 Top | 2 ~ 6 Bottom | Center 7 Circle)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: _buildSimplifiedFeltBoard(context, state),
                  ),

                  // Bottom Result History Strip (Clearly labeled Read-Only Table like Image 1)
                  _buildDiceStatsAndPipsHistory(context, state),

                  // Coin Controls
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    child: GameCoinControlsBar(
                      controller: _coinInputController,
                      currentAmount: state.betInputAmount,
                      onDecrement: () =>
                          gameBloc.add(const StepSevenUpBetCoinEvent(isIncrement: false)),
                      onIncrement: () =>
                          gameBloc.add(const StepSevenUpBetCoinEvent(isIncrement: true)),
                      onTextChanged: (txt) =>
                          gameBloc.add(UpdateSevenUpCustomCoinTextEvent(txt)),
                      onPresetSelected: (val) =>
                          gameBloc.add(SetSevenUpPresetCoinEvent(val)),
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

  Widget _buildGroupActivityTicker(SevenUpState state) {
    final latest = state.recentGroupActivity.first;
    final zone = kSevenUpZones.firstWhere(
      (z) => z.id == latest.itemId,
      orElse: () => kSevenUpZones.first,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.goldCoin.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.campaign_rounded, color: AppColors.goldCoin, size: 13),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '${latest.userName} bet 🪙 ${latest.amount} on [ ${zone.title} ]',
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

  Widget _buildSimplifiedFeltBoard(BuildContext context, SevenUpState state) {
    final upZone = kSevenUpZones[0]; // 8 ~ 12 (1:1)
    final sevenZone = kSevenUpZones[1]; // 7 (1:4)
    final downZone = kSevenUpZones[2]; // 2 ~ 6 (1:1)

    return SizedBox(
      height: 196,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Expanded(
                child: _buildHalfZoneCard(
                  context: context,
                  state: state,
                  zone: upZone,
                  isTop: true,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: _buildHalfZoneCard(
                  context: context,
                  state: state,
                  zone: downZone,
                  isTop: false,
                ),
              ),
            ],
          ),
          _buildCenterSevenMedallion(context, state, sevenZone),
        ],
      ),
    );
  }

  Widget _buildHalfZoneCard({
    required BuildContext context,
    required SevenUpState state,
    required SevenUpZone zone,
    required bool isTop,
  }) {
    final myBet = state.userBets[zone.id] ?? 0;
    final groupBet = state.groupBetsByZone[zone.id] ?? 0;
    final isSelected = myBet > 0;
    final isWinner = state.revealedOutcome?.zoneId == zone.id;

    final borderColor = isWinner
        ? const Color(0xFF34D399)
        : isSelected
            ? Colors.white
            : isTop
                ? const Color(0xFFD97706)
                : const Color(0xFFA3E635);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.read<SevenUpBloc>().add(PlaceSevenUpBetEvent(zone)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.fromLTRB(12, isTop ? 6 : 6, 12, isTop ? 6 : 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isTop
                ? const [Color(0xFF6E2D24), Color(0xFF471814)]
                : const [Color(0xFF5F5B12), Color(0xFF3C3B09)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(isTop ? 20 : 6),
            bottom: Radius.circular(isTop ? 6 : 20),
          ),
          border: Border.all(
            color: borderColor,
            width: (isWinner || isSelected) ? 2.4 : 1.6,
          ),
          boxShadow: [
            if (isWinner)
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.55),
                blurRadius: 12,
              )
            else if (isSelected)
              BoxShadow(
                color: AppColors.goldCoin.withValues(alpha: 0.4),
                blurRadius: 8,
              ),
          ],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isWinner) ...[
                    const Text('🏆', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                  ],
                  _buildStakeChip(myBet),
                ],
              ),
            ),
            Align(
              alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    zone.title,
                    style: const TextStyle(
                      color: AppColors.goldCoin,
                      fontSize: 20,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 5)],
                    ),
                  ),
                  Text(
                    GamesControlConfig.formatMultiplier(
                      state.gamesConfig.multiplierFor(
                        'game_7up_7down',
                        zone.id,
                        fallback: zone.multiplier,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (state.isGroupMode && groupBet > 0)
              Align(
                alignment: Alignment.centerRight,
                child: _buildGroupStakeBadge(groupBet),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterSevenMedallion(
    BuildContext context,
    SevenUpState state,
    SevenUpZone sevenZone,
  ) {
    final myBet = state.userBets[sevenZone.id] ?? 0;
    final groupBet = state.groupBetsByZone[sevenZone.id] ?? 0;
    final isSelected = myBet > 0;
    final isWinner = state.revealedOutcome?.zoneId == sevenZone.id;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () =>
          context.read<SevenUpBloc>().add(PlaceSevenUpBetEvent(sevenZone)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [Color(0xFF8B2E1E), Color(0xFF47120D)],
          ),
          border: Border.all(
            color: isWinner
                ? const Color(0xFF34D399)
                : isSelected
                    ? Colors.white
                    : AppColors.goldCoin,
            width: (isWinner || isSelected) ? 3.0 : 2.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isWinner ? const Color(0xFF10B981) : Colors.black)
                  .withValues(alpha: 0.7),
              blurRadius: 12,
              spreadRadius: isWinner ? 3 : 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isWinner ? '🏆 7' : '7',
              style: const TextStyle(
                color: AppColors.goldCoin,
                fontSize: 24,
                height: 1.0,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
              ),
            ),
            Text(
              GamesControlConfig.formatMultiplier(
                state.gamesConfig.multiplierFor(
                  'game_7up_7down',
                  sevenZone.id,
                  fallback: sevenZone.multiplier,
                ),
              ),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (myBet > 0) ...[
              const SizedBox(height: 2),
              _buildStakeChip(myBet),
            ] else if (state.isGroupMode && groupBet > 0) ...[
              const SizedBox(height: 2),
              _buildGroupStakeBadge(groupBet),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStakeChip(int amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '🪙 $amount',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGroupStakeBadge(int groupBet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.goldCoin.withValues(alpha: 0.4)),
      ),
      child: Text(
        '👥$groupBet',
        style: const TextStyle(
          color: AppColors.goldCoin,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDiceStatsAndPipsHistory(
    BuildContext context,
    SevenUpState state,
  ) {
    final history = state.rollHistory;
    final total = history.isEmpty ? 1 : history.length;
    final downCount = history.where((r) => r.zoneId == 'down').length;
    final upCount = history.where((r) => r.zoneId == 'up').length;
    final sevenCount = history.where((r) => r.zoneId == 'seven').length;

    final downPct = ((downCount / total) * 100).round();
    final upPct = ((upCount / total) * 100).round();
    final sevenPct = ((sevenCount / total) * 100).round();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.goldCoin.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          // Clear Read-Only Stats Header (prevents thinking bottom strip is clickable bets)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'LAST RESULTS (History)',
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  '2~6: $downPct%  •  ',
                  style: const TextStyle(
                    color: Color(0xFF15803D),
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '8~12: $upPct%  •  ',
                  style: const TextStyle(
                    color: Color(0xFFB45309),
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '7: $sevenPct%',
                  style: const TextStyle(
                    color: Color(0xFFB91C1C),
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Compact White Result Table Strip (Matches Image 1 bottom strip)
          SizedBox(
            height: 54,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: history.length,
              itemBuilder: (context, idx) {
                final roll = history[idx];
                final isLatest = idx == 0;
                final isSeven = roll.sum == 7;

                return GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            'Result History only: Rolled 🎲 ${roll.die1}+${roll.die2} = ${roll.sum} (${roll.winningZone.title}). Tap 8 ~ 12, 7, or 2 ~ 6 above to bet!',
                          ),
                          backgroundColor: const Color(0xFF1F2937),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                  },
                  child: Container(
                    width: 31,
                    decoration: BoxDecoration(
                      color: isLatest
                          ? const Color(0xFFDCFCE7)
                          : Colors.white,
                      border: Border(
                        right: const BorderSide(color: Color(0xFFE5E7EB)),
                        top: isLatest
                            ? const BorderSide(color: Color(0xFF22C55E), width: 2)
                            : BorderSide.none,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          '${roll.sum}',
                          style: TextStyle(
                            color: isSeven
                                ? const Color(0xFFB91C1C)
                                : const Color(0xFF111827),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        DiceFaceWidget(value: roll.die1, size: 15),
                        DiceFaceWidget(value: roll.die2, size: 15),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
