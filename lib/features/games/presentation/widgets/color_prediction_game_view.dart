import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../data/repositories/bucket_game_repository_impl.dart';
import '../../domain/entities/color_game_option.dart';
import '../../domain/entities/games_control_config.dart';
import '../bloc/color_game_bloc.dart';
import '../bloc/color_game_event.dart';
import '../bloc/color_game_state.dart';
import 'game_board_chrome.dart';
import 'game_coin_controls_bar.dart';
import 'game_group_picker_sheet.dart';
import 'rewarded_ad_player_dialog.dart';
import 'swirling_bucket_widget.dart';

/// Pure BLoC-driven Presentation Widget for Game #2: 3-Color Bucket Spin (`game.game 2.html`).
/// - Swirling multi-color water bucket + floating ❓ center
/// - After 35s, winning Color + Color Name rises out of the bucket
/// - Solo & Group Modes + Double (1:2 / 1:4.5) payout + Admin-Controlled Rewarded Ads
class ColorPredictionGameView extends StatelessWidget {
  final String? partyRoomId;
  final String? partyRoomName;
  final bool isDrawerMode;

  const ColorPredictionGameView({
    super.key,
    this.partyRoomId,
    this.partyRoomName,
    this.isDrawerMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final initialCoinBalance = context.read<ProfileBloc>().state.profile.coinBalance;

    return BlocProvider<ColorGameBloc>(
      create: (_) => ColorGameBloc(repository: BucketGameRepositoryImpl())
        ..add(InitColorGameEvent(
          partyRoomId: partyRoomId,
          partyRoomName: partyRoomName,
          initialUserCoinBalance: initialCoinBalance,
        )),
      child: _ColorGameViewContent(isDrawerMode: isDrawerMode),
    );
  }
}

class _ColorGameViewContent extends StatefulWidget {
  final bool isDrawerMode;

  const _ColorGameViewContent({required this.isDrawerMode});

  @override
  State<_ColorGameViewContent> createState() => _ColorGameViewContentState();
}

class _ColorGameViewContentState extends State<_ColorGameViewContent> {
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
            final gameState = context.read<ColorGameBloc>().state;
            if (gameState.syncedUserCoinBalance != profileState.profile.coinBalance) {
              context.read<ColorGameBloc>().add(
                    SyncColorUserBalanceEvent(profileState.profile.coinBalance),
                  );
            }
          },
        ),
        BlocListener<ColorGameBloc, ColorGameState>(
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
        BlocListener<ColorGameBloc, ColorGameState>(
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
        BlocListener<ColorGameBloc, ColorGameState>(
          listenWhen: (prev, curr) =>
              prev.openWatchAdModalTick != curr.openWatchAdModalTick,
          listener: (context, state) {
            final gameBloc = context.read<ColorGameBloc>();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => RewardedAdPlayerDialog(
                config: state.rewardedAdsConfig,
                onClaimReward: (ad) => gameBloc.add(ClaimColorAdRewardEvent(ad)),
              ),
            );
          },
        ),
        BlocListener<ColorGameBloc, ColorGameState>(
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
      child: BlocBuilder<ColorGameBloc, ColorGameState>(
        builder: (context, state) {
          final gameBloc = context.read<ColorGameBloc>();
          final isUrgent = state.timeLeft <= 5 && state.timeLeft > 0;
          final currentUid = AuthSessionManager.currentUserId;
          final balance = (currentUid == null || currentUid.isEmpty)
              ? state.guestFallbackBalance
              : state.syncedUserCoinBalance;

          final revealBadge = state.revealedColor != null
              ? BucketRevealBadge(
                  label: state.revealedColor!.name,
                  accentColor: state.revealedColor!.accentColor,
                  colorSwatch: state.revealedColor!.gradientColors,
                )
              : null;

          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF28061B), Color(0xFF140417), Color(0xFF08020D)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: widget.isDrawerMode
                  ? const BorderRadius.vertical(top: Radius.circular(24))
                  : BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFE879F9).withValues(alpha: 0.72),
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD946EF).withValues(alpha: 0.2),
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
                      final cfg = state.gamesConfig.gameFor('game_color_3');
                      final r = GamesControlConfig.formatMultiplier(
                        cfg.multiplierFor('red', fallback: 2.0),
                      );
                      final v = GamesControlConfig.formatMultiplier(
                        cfg.multiplierFor('violet', fallback: 4.5),
                      );
                      final g = GamesControlConfig.formatMultiplier(
                        cfg.multiplierFor('green', fallback: 2.0),
                      );
                      return GameHeaderBar(
                        title: '🎨 Color Spin (3-Color Arena)',
                        subtitle: '${cfg.roundSeconds}s Live Round • Odds $r / $v / $g',
                        isGroupMode: state.isGroupMode,
                        timeLeft: state.timeLeft,
                        accentColor: const Color(0xFFF472B6),
                        onModeChanged: (toGroup) =>
                            gameBloc.add(SwitchColorGameModeEvent(toGroup)),
                      );
                    },
                  ),
                  if (!state.gamesConfig.isGamePlayable('game_color_3'))
                    const GameFrozenBanner(),
                  GameStatsBar(
                    balance: balance,
                    totalPoolCount: state.totalPoolCount,
                    isLoadingAds: state.isLoadingAds,
                    onWatchAdTap: () => gameBloc.add(
                      const FetchColorRewardedAdsEvent(openDialogAfterFetch: true),
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
                        ChangeColorGroupRoomEvent(roomId: id, roomName: name),
                      ),
                    ),
                    historyBadges: state.winnerHistory.map((opt) {
                      return Container(
                        margin: const EdgeInsets.only(right: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: opt.gradientColors),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          opt.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Center Silver-Chrome Tri-Color Cauldron inside Spectrum Arena Card
                  Container(
                    margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE879F9).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildSideColorPill(
                              color: const Color(0xFFFF2E54),
                              label: 'RED',
                              mult: GamesControlConfig.formatMultiplier(
                                state.gamesConfig.multiplierFor(
                                  'game_color_3',
                                  'red',
                                  fallback: 2.0,
                                ),
                              ),
                            ),
                            SwirlingBucketWidget(
                              size: widget.isDrawerMode ? 124 : 142,
                              theme: BucketVisualTheme.tricolorNeon,
                              isUrgentSpin: isUrgent || state.isRevealing,
                              revealBadge: revealBadge,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildSideColorPill(
                                  color: const Color(0xFF9333EA),
                                  label: 'VIOLET',
                                  mult: GamesControlConfig.formatMultiplier(
                                    state.gamesConfig.multiplierFor(
                                      'game_color_3',
                                      'violet',
                                      fallback: 4.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildSideColorPill(
                                  color: const Color(0xFF10B981),
                                  label: 'GREEN',
                                  mult: GamesControlConfig.formatMultiplier(
                                    state.gamesConfig.multiplierFor(
                                      'game_color_3',
                                      'green',
                                      fallback: 2.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (state.roundResultBanner != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
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
                  ),

                  if (state.isGroupMode && state.recentGroupActivity.isNotEmpty)
                    _buildGroupActivityTicker(state),

                  // 3 Color Betting Zones (RED | VIOLET | GREEN)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: kColorGameOptions
                          .map((opt) =>
                              Expanded(child: _buildColorZoneCard(context, state, opt)))
                          .toList(),
                    ),
                  ),

                  // Coin Controls
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    child: GameCoinControlsBar(
                      controller: _coinInputController,
                      currentAmount: state.betInputAmount,
                      onDecrement: () =>
                          gameBloc.add(const StepColorBetCoinEvent(isIncrement: false)),
                      onIncrement: () =>
                          gameBloc.add(const StepColorBetCoinEvent(isIncrement: true)),
                      onTextChanged: (txt) =>
                          gameBloc.add(UpdateColorCustomCoinTextEvent(txt)),
                      onPresetSelected: (val) =>
                          gameBloc.add(SetColorPresetCoinEvent(val)),
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

  Widget _buildGroupActivityTicker(ColorGameState state) {
    final latest = state.recentGroupActivity.first;
    final opt = kColorGameOptions.firstWhere(
      (e) => e.id == latest.itemId,
      orElse: () => kColorGameOptions.first,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4C1D95).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.campaign_rounded, color: AppColors.goldCoin, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '${latest.userName} bet 🪙 ${latest.amount} on ${opt.emoji} ${opt.name}',
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

  Widget _buildSideColorPill({
    required Color color,
    required String label,
    required String mult,
  }) {
    return Container(
      width: 66,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.65), width: 1.1),
      ),
      child: Column(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            mult,
            style: TextStyle(
              color: color.withValues(alpha: 0.95),
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorZoneCard(
    BuildContext context,
    ColorGameState state,
    ColorGameOption option,
  ) {
    final myBet = state.userBets[option.id] ?? 0;
    final groupBet = state.groupBetsByColor[option.id] ?? 0;
    final isSelected = myBet > 0;
    final isWinner = state.revealedColor?.id == option.id;

    return GestureDetector(
      onTap: () => context.read<ColorGameBloc>().add(PlaceColorBetEvent(option)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 126,
        decoration: BoxDecoration(
          color: const Color(0xFF170822),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isWinner
                ? const Color(0xFFFFD700)
                : isSelected
                    ? option.accentColor
                    : option.accentColor.withValues(alpha: 0.45),
            width: (isWinner || isSelected) ? 2.5 : 1.4,
          ),
          boxShadow: [
            if (isWinner)
              BoxShadow(
                color: option.accentColor.withValues(alpha: 0.8),
                blurRadius: 16,
                spreadRadius: 2,
              )
            else if (isSelected)
              BoxShadow(
                color: option.accentColor.withValues(alpha: 0.55),
                blurRadius: 10,
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (state.isGroupMode && groupBet > 0)
              Positioned(
                top: 5,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '👥$groupBet',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (isWinner)
              const Positioned(
                top: 4,
                left: 6,
                child: Text('🏆', style: TextStyle(fontSize: 13)),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 3D Glowing Color Gemstone Orb (distinct from Game #1 emoji tiles)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: option.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: option.accentColor.withValues(alpha: 0.65),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  option.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  GamesControlConfig.formatWinRatio(
                    state.gamesConfig.multiplierFor(
                      'game_color_3',
                      option.id,
                      fallback: option.multiplier,
                    ),
                  ),
                  style: TextStyle(
                    color: option.accentColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? option.accentColor.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? option.accentColor
                          : Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Text(
                    '🪙 $myBet',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
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
